import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../controller/quill_controller.dart';
import '../../document/attribute.dart';
import '../../document/document.dart';
import '../../document/structs/doc_change.dart';
import '../../document/style.dart';
import '../config/events/mention_tag_handlers.dart';
import '../config/mention_tag_config.dart';
import '../config/mention_tag_controller.dart';
import '../widgets/mention_tag_overlay.dart';

/// v6
/// Wrapper widget that adds mention/tag functionality to QuillEditor
class MentionTagWrapper extends StatefulWidget {
  const MentionTagWrapper({
    required this.controller,
    required this.child,
    required this.config,
    this.mentionTagController,
    super.key,
  });

  final QuillController controller;
  final Widget child;
  final MentionTagConfig config;

  /// Optional controller to refresh the suggestion list
  /// If provided, you can call [MentionTagController.refresh] to update the list
  final MentionTagController? mentionTagController;

  @override
  State<MentionTagWrapper> createState() => _MentionTagWrapperState();
}

/// Result of query extraction for a trigger character
class _TriggerQueryResult {
  final String query;
  final int position;

  _TriggerQueryResult(this.query, this.position);
}

class _ActiveTriggerResult {
  final String trigger;
  final _TriggerQueryResult result;

  _ActiveTriggerResult(this.trigger, this.result);
}

class _HashTagRange {
  final int start;
  final int length;
  final String name;

  _HashTagRange(this.start, this.length, this.name);
}

class _MentionTagWrapperState extends State<MentionTagWrapper> {
  MentionTagState? _mentionTagState;
  StreamSubscription<DocChange>? _changeSubscription;

  /// [Document] instance we attached [changes] to; must update when
  /// [QuillController.document] is replaced (same controller, new [Document]).
  Document? _documentListened;

  bool _isOverlayVisible = false;
  bool? _lastTagTypingNotified; // null until first callback
  String _currentQuery = '';
  bool _isMention = false;
  String _tagTrigger = '#';
  int _currentTriggerPosition = -1;
  Timer? _tagCheckDebounceTimer;
  String _lastCheckedTagQuery = '';
  Timer? _mentionSpaceDebounceTimer;
  bool _isApplyingHashTagColor = false;
  bool _isClearingTokenStyleLeak = false;

  /// Workaround for Flutter issue where RenderUiKitView can receive pointer
  /// events before layout (NEEDS-LAYOUT). Block pointer events to the editor
  /// for one frame when overlay visibility changes (and on first frame) so
  /// layout can complete. See https://github.com/flutter/flutter/issues/167849
  bool _blockPointerEventsForLayout = true;

  @override
  void initState() {
    super.initState();
    // Unblock after first layout so the editor can receive input.
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (mounted && _blockPointerEventsForLayout) {
        setState(() => _blockPointerEventsForLayout = false);
      }
    });
    _mentionTagState = _newMentionTagState();

    _attachMentionTagController(widget.mentionTagController);

    _changeSubscription = _subscribeToDocumentChanges();
    widget.controller.addListener(_onControllerNotification);
  }

  void _attachMentionTagController(MentionTagController? controller) {
    controller?.setRefreshCallback(refreshSuggestionList);
  }

  MentionTagState _newMentionTagState() {
    return MentionTagState(
      config: widget.config,
      controller: widget.controller,
      onVisibilityChanged: (visible, query, isMention, tagTrigger) {
        // Defer setState to after build phase to avoid calling during build
        SchedulerBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              _isOverlayVisible = visible;
              _currentQuery = query;
              _isMention = isMention;
              _tagTrigger = tagTrigger;
              // Block pointer events for one frame to avoid RenderUiKitView
              // receiving events before layout (Flutter framework issue).
              _blockPointerEventsForLayout = true;
            });
            if (visible) {
              // Scroll so cursor stays above suggestion view (immediate + delayed fallback)
              _scrollEditorToShowCaretAboveOverlay();
            }
            // Notify only when isTypingTag changes
            if (_lastTagTypingNotified != visible) {
              _lastTagTypingNotified = visible;
              widget.config.onTagTypingChanged?.call(visible);
            }
            // Unblock pointer events after next frame so layout can complete.
            SchedulerBinding.instance.addPostFrameCallback((_) {
              if (mounted && _blockPointerEventsForLayout) {
                setState(() => _blockPointerEventsForLayout = false);
              }
            });
          }
        });
      },
    );
  }

  /// [didUpdateWidget] cannot detect a swapped [Document] when the parent keeps
  /// the same [QuillController]: both `oldWidget` and `widget` read the current
  /// document from that instance. Re-subscribe whenever the controller notifies
  /// and the [Document] identity changed (e.g. after `controller.document = ...`).
  void _onControllerNotification() {
    if (!mounted) return;
    if (identical(_documentListened, widget.controller.document)) {
      return;
    }
    _changeSubscription?.cancel();
    _changeSubscription = _subscribeToDocumentChanges();
  }

  /// Subscribes to the current [Document.changes] stream.
  ///
  /// When [QuillController.document] is replaced (e.g. loading saved Delta JSON),
  /// the stream instance changes; callers must re-subscribe or mention/tag
  /// detection stops receiving events.
  StreamSubscription<DocChange> _subscribeToDocumentChanges() {
    _documentListened = widget.controller.document;
    return widget.controller.document.changes.listen((change) {
      if (change.source == ChangeSource.local) {
        if (!_isClearingTokenStyleLeak) {
          _clearTokenStyleFromInsertedText(change);
        }
        _checkForMentionEditRemoval(change);
        _checkForCurrencyEditRemoval(change);
        _checkForTagTriggerDeletion(change);
        _checkForHashTagsInChange(change);
        // [QuillController.replaceText] updates selection after [Document.compose]
        // emits. Running here sees a stale caret (e.g. offset 0 after typing `#` at
        // the start), so triggers never open the suggestion overlay.
        scheduleMicrotask(() {
          if (!mounted) return;
          _checkForMentionOrTag();
        });
      }
    });
  }

  @override
  void didUpdateWidget(MentionTagWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);
    final controllerChanged = oldWidget.controller != widget.controller;
    final configChanged = oldWidget.config != widget.config;

    if (oldWidget.mentionTagController != widget.mentionTagController) {
      oldWidget.mentionTagController?.setRefreshCallback(null);
      _attachMentionTagController(widget.mentionTagController);
    }

    if (controllerChanged) {
      oldWidget.controller.removeListener(_onControllerNotification);
      widget.controller.addListener(_onControllerNotification);
      _changeSubscription?.cancel();
      _changeSubscription = _subscribeToDocumentChanges();
    }

    if (controllerChanged) {
      _mentionTagState?.dispose();
      _mentionTagState = _newMentionTagState();
      if (_isOverlayVisible) {
        _showOverlay(
          _isMention,
          _currentTriggerPosition,
          _currentQuery,
          tagTrigger: _tagTrigger,
        );
      }
    } else if (configChanged) {
      _mentionTagState?.updateConfig(widget.config);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerNotification);
    _changeSubscription?.cancel();
    _tagCheckDebounceTimer?.cancel();
    _mentionSpaceDebounceTimer?.cancel();
    _mentionTagState?.dispose();
    widget.mentionTagController?.setRefreshCallback(null);
    super.dispose();
  }

  void _checkForMentionOrTag() {
    if (!mounted) return;
    final selection = widget.controller.selection;
    if (!selection.isCollapsed) {
      _hideOverlay();
      return;
    }

    final plainText = widget.controller.document.toPlainText();
    if (plainText.isEmpty || selection.baseOffset == 0) {
      _hideOverlay();
      return;
    }

    // If user pressed enter right after a #tag, clear the tag style so
    // the next line doesn't inherit the hash tag color.
    _clearHashTagStyleOnNewline();

    // If user typed a mention manually (no suggestion selection), apply mention
    // attribute (and thus color) when they hit space. Supports names with spaces
    // like "@john doe ".
    _checkForMentionAfterSpace();

    // If user typed a $ tag manually, apply currency attribute when they hit
    // space (same behavior as mentions).
    _checkForDollarAfterSpace();

    // Check if space was just typed after a # tag trigger
    _checkForTagAfterSpace();

    // Check for @ mention
    if (handleMentionTrigger(widget.controller)) {
      final query = extractQuery(widget.controller, true);
      if (_isOverlayVisible && _isMention) {
        _mentionTagState?.updateQuery(query);
      } else {
        _showOverlay(true, selection.baseOffset - 1, query);
      }
      return;
    }

    // Check for # tag
    if (handleTagTrigger(widget.controller)) {
      final query = extractQuery(widget.controller, false);
      if (_isOverlayVisible && !_isMention && _tagTrigger == '#') {
        _mentionTagState?.updateQuery(query);
      } else {
        _showOverlay(false, selection.baseOffset - 1, query, tagTrigger: '#');
      }
      return;
    }

    // Check for $ tag
    if (handleDollarTagTrigger(widget.controller)) {
      final query = extractQuery(widget.controller, false, tagTrigger: '\$');
      if (_isOverlayVisible && !_isMention && _tagTrigger == '\$') {
        _mentionTagState?.updateQuery(query);
      } else {
        _showOverlay(false, selection.baseOffset - 1, query, tagTrigger: '\$');
      }
      return;
    }

    // Check if we're still in a mention/tag context
    // This handles the case where overlay was hidden but user is editing within a tag/mention
    final mentionResult = _getCurrentQueryForTrigger('@');
    final tagHashResult = _getCurrentQueryForTrigger('#');
    final tagDollarResult = _getCurrentQueryForTrigger('\$');

    final activeTrigger =
        _pickActiveTrigger(mentionResult, tagHashResult, tagDollarResult);
    if (activeTrigger == null) {
      // Not in any mention/tag context, hide overlay if it exists
      if (_isOverlayVisible) {
        _hideOverlay();
      }
      return;
    }

    if (activeTrigger.trigger == '@') {
      final mentionQuery = activeTrigger.result.query;
      final mentionPosition = activeTrigger.result.position;
      final mentionRangeLength = mentionQuery.length + 1;
      // Don't show overlay when query is only whitespace (e.g. " " after " @");
      // allow empty query "" when user just typed @.
      if (mentionQuery.isNotEmpty && mentionQuery.trim().isEmpty) {
        if (_isOverlayVisible && _isMention) _hideOverlay();
        return;
      }
      if (_rangeContainsAttribute(
        mentionPosition,
        mentionRangeLength,
        Attribute.mention.key,
      )) {
        if (_isOverlayVisible && _isMention) _hideOverlay();
        return;
      }
      if (_isOverlayVisible && _isMention) {
        _mentionTagState?.updateQuery(mentionQuery);
      } else {
        _showOverlay(true, mentionPosition, mentionQuery);
      }
      return;
    }

    // Check for # tag context (original # logic: color while typing)
    if (activeTrigger.trigger == '#') {
      final tagQuery = activeTrigger.result.query;
      final tagPosition = activeTrigger.result.position;
      // Don't show overlay when query is only whitespace (e.g. " " after " #").
      if (tagQuery.isNotEmpty && tagQuery.trim().isEmpty) {
        if (_isOverlayVisible && !_isMention && _tagTrigger == '#') {
          _hideOverlay();
        }
        return;
      }
      // Hide overlay when query ends with space (e.g. after selecting a tag from list).
      if (tagQuery.endsWith(' ')) {
        if (_isOverlayVisible && !_isMention && _tagTrigger == '#') {
          _hideOverlay();
        }
        return;
      }
      if (_isOverlayVisible && !_isMention && _tagTrigger == '#') {
        _mentionTagState?.updateQuery(tagQuery);
      } else {
        _showOverlay(false, tagPosition, tagQuery, tagTrigger: '#');
      }
      if (tagQuery.isNotEmpty) {
        _applyDefaultHashTagColor(tagPosition, tagQuery);
        return;
      }
      if (tagQuery != _lastCheckedTagQuery && tagQuery.isNotEmpty) {
        _checkAndApplyTypedTag('#', tagQuery, tagPosition);
      }
      return;
    }

    // Check for $ tag context
    if (activeTrigger.trigger == '\$') {
      final tagQuery = activeTrigger.result.query;
      final tagPosition = activeTrigger.result.position;
      final tagRangeLength = tagQuery.length + 1;
      // Don't show overlay when query is only whitespace (e.g. " " after " $").
      if (tagQuery.isNotEmpty && tagQuery.trim().isEmpty) {
        if (_isOverlayVisible && !_isMention && _tagTrigger == '\$') {
          _hideOverlay();
        }
        return;
      }
      if (_rangeContainsAttribute(
        tagPosition,
        tagRangeLength,
        Attribute.currency.key,
      )) {
        if (_isOverlayVisible && !_isMention && _tagTrigger == '\$') {
          _hideOverlay();
        }
        return;
      }
      if (_isOverlayVisible && !_isMention && _tagTrigger == '\$') {
        _mentionTagState?.updateQuery(tagQuery);
      } else {
        _showOverlay(false, tagPosition, tagQuery, tagTrigger: '\$');
      }
      return;
    }
  }

  _ActiveTriggerResult? _pickActiveTrigger(
    _TriggerQueryResult? mention,
    _TriggerQueryResult? hash,
    _TriggerQueryResult? dollar,
  ) {
    _ActiveTriggerResult? best;
    void consider(String trigger, _TriggerQueryResult? result) {
      if (result == null) return;
      if (best == null || result.position > best!.result.position) {
        best = _ActiveTriggerResult(trigger, result);
      }
    }

    consider('@', mention);
    consider('#', hash);
    consider('\$', dollar);
    return best;
  }

  String? _getCurrentQuery() {
    final selection = widget.controller.selection;
    final plainText = widget.controller.document.toPlainText();

    if (selection.baseOffset == 0) return null;

    var pos = selection.baseOffset - 1;
    final triggerChar = _mentionTagState?.isMention == true ? '@' : '#';

    // Find trigger character
    while (pos >= 0 && plainText[pos] != triggerChar) {
      if (plainText[pos] == ' ' || plainText[pos] == '\n') {
        return null;
      }
      pos--;
    }

    if (pos < 0 || plainText[pos] != triggerChar) {
      return null;
    }

    // Extract query
    final query = plainText.substring(pos + 1, selection.baseOffset);
    return query;
  }

  /// Get current query for a specific trigger character, checking if we're in that context
  _TriggerQueryResult? _getCurrentQueryForTrigger(String triggerChar) {
    final selection = widget.controller.selection;
    final plainText = widget.controller.document.toPlainText();

    if (selection.baseOffset == 0) return null;

    var pos = selection.baseOffset - 1;

    // Find trigger character
    while (pos >= 0 && plainText[pos] != triggerChar) {
      // For mentions and $ tags, allow spaces in the query (names with spaces).
      // For # tags, a space ends the query.
      if ((triggerChar == '#' && plainText[pos] == ' ') ||
          (triggerChar == '@' &&
              (plainText[pos] == '#' || plainText[pos] == '\$')) ||
          plainText[pos] == '\n') {
        return null;
      }
      pos--;
    }

    if (pos < 0 || plainText[pos] != triggerChar) {
      return null;
    }

    // Check if there's a space or newline before the trigger (start of word)
    if (pos > 0) {
      final charBeforeTrigger = plainText[pos - 1];
      if (charBeforeTrigger != ' ' && charBeforeTrigger != '\n') {
        return null;
      }
    }

    // Extract query
    final query = plainText.substring(pos + 1, selection.baseOffset);
    return _TriggerQueryResult(query, pos);
  }

  bool _rangeContainsAttribute(int start, int length, String attributeKey) {
    if (start < 0 || length <= 0) return false;
    final plainText = widget.controller.document.toPlainText();
    if (start >= plainText.length) return false;
    final safeLength = (start + length).clamp(0, plainText.length) - start;
    if (safeLength <= 0) return false;
    for (var offset = start; offset < start + safeLength; offset++) {
      final style = widget.controller.document.collectStyle(offset, 1);
      if (style.attributes.containsKey(attributeKey)) {
        return true;
      }
    }
    return false;
  }

  void _showOverlay(bool isMention, int position, String query,
      {String? tagTrigger}) {
    if (!mounted) return;

    _currentTriggerPosition = position;
    _mentionTagState?.showOverlay(isMention, position, query,
        tagTrigger: tagTrigger ?? '#');
  }

  void _hideOverlay() {
    _currentTriggerPosition = -1;
    _mentionTagState?.hideOverlay();
  }

  /// Delay before requesting a second scroll when overlay is shown (fallback when layout needs more time).
  static const Duration _scrollAfterOverlayDelay = Duration(milliseconds: 200);

  /// Requests the editor to scroll so the cursor stays visible above the suggestion overlay.
  /// Called when the overlay is shown: triggers an immediate scroll request and a delayed one as fallback.
  void _scrollEditorToShowCaretAboveOverlay() {
    if (!mounted) return;
    // Immediate: same as doing it in onTagTypingChanged(true) — works when overlay just became visible
    widget.controller.requestShowCaretOnScreen = true;
    widget.controller.notifyListeners();
    // Delayed fallback: after layout has settled (overlay height, keyboard, etc.)
    Future.delayed(_scrollAfterOverlayDelay, () {
      if (!mounted) return;
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        widget.controller.requestShowCaretOnScreen = true;
        widget.controller.notifyListeners();
      });
    });
  }

  /// Refresh the suggestion list when data changes
  /// Call this method when your data source has been updated
  void refreshSuggestionList() {
    _mentionTagState?.refreshList();
  }

  void _clearTokenStyleFromInsertedText(DocChange change) {
    var afterOffset = 0;

    for (final op in change.change.toList()) {
      if (op.isRetain) {
        afterOffset += op.length ?? 0;
        continue;
      }

      if (op.isInsert) {
        final insertLen = (op.data is String) ? (op.data as String).length : 1;
        final insertPosition = afterOffset;
        afterOffset += insertLen;

        if (op.data is! String || insertLen <= 0) continue;
        if (!_isAfterTokenBoundary(insertPosition)) continue;

        _clearTokenStyleFromRange(insertPosition, insertLen);
        continue;
      }

      if (op.isDelete) {
        continue;
      }
    }
  }

  bool _isAfterTokenBoundary(int position) {
    if (position <= 0) return false;
    if (_positionHasTokenAttribute(position - 1)) return true;

    final plainText = widget.controller.document.toPlainText();
    if (position > plainText.length) return false;
    final previousChar = plainText[position - 1];
    if (previousChar != ' ' && previousChar != '\n') return false;

    return position > 1 && _positionHasTokenAttribute(position - 2);
  }

  bool _positionHasTokenAttribute(int position) {
    final plainText = widget.controller.document.toPlainText();
    if (position < 0 || position >= plainText.length) return false;

    final style = widget.controller.document.collectStyle(position, 1);
    return style.attributes.containsKey(Attribute.mention.key) ||
        style.attributes.containsKey(Attribute.tag.key) ||
        style.attributes.containsKey(Attribute.currency.key);
  }

  void _clearTokenStyleFromRange(int start, int length) {
    final attrsToClear = _tokenStyleClearAttributesForRange(start, length);
    if (attrsToClear.isEmpty) {
      widget.controller.toggledStyle = const Style();
      return;
    }

    _isClearingTokenStyleLeak = true;
    try {
      for (final attr in attrsToClear) {
        widget.controller.formatText(
          start,
          length,
          attr,
          shouldNotifyListeners: false,
        );
      }
      widget.controller.toggledStyle = const Style();
      widget.controller.notifyListeners();
    } finally {
      _isClearingTokenStyleLeak = false;
    }
  }

  /// If user deletes the trigger character `@` / `#` / `$`, remove the related
  /// inline attribute (mention/tag/currency) so the color is removed too.
  void _checkForTagTriggerDeletion(DocChange change) {
    final selection = widget.controller.selection;
    if (!selection.isCollapsed) return;

    // Reconstruct the plain text BEFORE the change so we can know what was deleted.
    final beforeDoc = Document.fromDelta(change.before);
    final beforeText = beforeDoc.toPlainText();
    final afterText = widget.controller.document.toPlainText();
    if (beforeText.isEmpty || afterText.isEmpty) return;

    var beforeOffset = 0;
    var afterOffset = 0;

    for (final op in change.change.toList()) {
      if (op.isRetain) {
        final n = op.length ?? 0;
        beforeOffset += n;
        afterOffset += n;
        continue;
      }

      if (op.isInsert) {
        final insertedLen =
            (op.data is String) ? (op.data as String).length : 1;
        afterOffset += insertedLen;
        continue;
      }

      if (op.isDelete) {
        final deleteLen = op.length ?? 0;
        if (deleteLen <= 0) continue;

        final end = (beforeOffset + deleteLen).clamp(0, beforeText.length);
        final deletedText = beforeText.substring(beforeOffset, end);

        // If the trigger was deleted, remove the attribute span starting at the
        // corresponding position in the AFTER document.
        if (deletedText.contains('@')) {
          _removeInlineAttributeSpanAt(afterOffset,
              attributeKey: Attribute.mention.key);
          if (afterOffset > 0) {
            _removeInlineAttributeSpanAt(afterOffset - 1,
                attributeKey: Attribute.mention.key);
          }
        }
        if (deletedText.contains('#')) {
          _removeInlineAttributeSpanAt(afterOffset,
              attributeKey: Attribute.tag.key);
          if (afterOffset > 0) {
            _removeInlineAttributeSpanAt(afterOffset - 1,
                attributeKey: Attribute.tag.key);
          }
        }
        if (deletedText.contains('\$')) {
          _removeInlineAttributeSpanAt(afterOffset,
              attributeKey: Attribute.currency.key);
          if (afterOffset > 0) {
            _removeInlineAttributeSpanAt(afterOffset - 1,
                attributeKey: Attribute.currency.key);
          }
        }
        beforeOffset += deleteLen;
      }
    }
  }

  /// Remove mention attribute if user edits within an existing mention.
  void _checkForMentionEditRemoval(DocChange change) {
    final selection = widget.controller.selection;
    if (!selection.isCollapsed) return;

    final beforeDoc = Document.fromDelta(change.before);
    final beforeText = beforeDoc.toPlainText();
    if (beforeText.isEmpty) return;

    var beforeOffset = 0;
    var afterOffset = 0;

    for (final op in change.change.toList()) {
      if (op.isRetain) {
        final n = op.length ?? 0;
        beforeOffset += n;
        afterOffset += n;
        continue;
      }

      if (op.isInsert) {
        final insertLen = (op.data is String) ? (op.data as String).length : 1;
        final insertPos = afterOffset;
        afterOffset += insertLen;

        // If inserted text ends up inside a mention, remove the mention attribute.
        _removeInlineAttributeSpanAt(insertPos,
            attributeKey: Attribute.mention.key,
            onlyIfHasAttributeAtPosition: true);
        continue;
      }

      if (op.isDelete) {
        final deleteLen = op.length ?? 0;
        if (deleteLen <= 0) continue;

        final hasMentionInDeletedRange = _deletedRangeHasAttribute(
          beforeDoc,
          beforeOffset,
          deleteLen,
          Attribute.mention.key,
        );

        if (hasMentionInDeletedRange) {
          _removeInlineAttributeSpanAt(afterOffset,
              attributeKey: Attribute.mention.key);
          if (afterOffset > 0) {
            _removeInlineAttributeSpanAt(afterOffset - 1,
                attributeKey: Attribute.mention.key);
          }
        }

        beforeOffset += deleteLen;
      }
    }
  }

  void _checkForCurrencyEditRemoval(DocChange change) {
    final selection = widget.controller.selection;
    if (!selection.isCollapsed) return;

    final beforeDoc = Document.fromDelta(change.before);
    final beforeText = beforeDoc.toPlainText();
    if (beforeText.isEmpty) return;

    var beforeOffset = 0;
    var afterOffset = 0;

    for (final op in change.change.toList()) {
      if (op.isRetain) {
        final n = op.length ?? 0;
        beforeOffset += n;
        afterOffset += n;
        continue;
      }

      if (op.isInsert) {
        final insertLen = (op.data is String) ? (op.data as String).length : 1;
        final insertPos = afterOffset;
        afterOffset += insertLen;

        _removeInlineAttributeSpanAt(insertPos,
            attributeKey: Attribute.currency.key,
            onlyIfHasAttributeAtPosition: true);
        continue;
      }

      if (op.isDelete) {
        final deleteLen = op.length ?? 0;
        if (deleteLen <= 0) continue;

        final hasCurrencyInDeletedRange = _deletedRangeHasAttribute(
          beforeDoc,
          beforeOffset,
          deleteLen,
          Attribute.currency.key,
        );

        if (hasCurrencyInDeletedRange) {
          _removeInlineAttributeSpanAt(afterOffset,
              attributeKey: Attribute.currency.key);
          if (afterOffset > 0) {
            _removeInlineAttributeSpanAt(afterOffset - 1,
                attributeKey: Attribute.currency.key);
          }
        }

        beforeOffset += deleteLen;
      }
    }
  }

  bool _deletedRangeHasAttribute(
    Document beforeDoc,
    int start,
    int len,
    String attributeKey,
  ) {
    if (len <= 0) return false;
    final text = beforeDoc.toPlainText();
    if (text.isEmpty) return false;

    final end = (start + len).clamp(0, text.length);
    for (var i = start; i < end; i++) {
      final style = beforeDoc.collectStyle(i, 1);
      if (style.attributes.containsKey(attributeKey)) {
        return true;
      }
    }
    return false;
  }

  void _removeInlineAttributeSpanAt(
    int position, {
    required String attributeKey,
    bool onlyIfHasAttributeAtPosition = false,
  }) {
    if (position < 0) return;

    final plainText = widget.controller.document.toPlainText();
    if (plainText.isEmpty || position >= plainText.length) return;

    final style = widget.controller.document.collectStyle(position, 1);
    final hasAttr = style.attributes.containsKey(attributeKey);
    if (onlyIfHasAttributeAtPosition && !hasAttr) return;
    if (!hasAttr) return;

    // Find the full contiguous span where this attribute exists.
    var start = position;
    while (start > 0) {
      final prevStyle = widget.controller.document.collectStyle(start - 1, 1);
      if (!prevStyle.attributes.containsKey(attributeKey)) break;
      start--;
    }

    var end = position + 1;
    while (end < plainText.length) {
      final nextStyle = widget.controller.document.collectStyle(end, 1);
      if (!nextStyle.attributes.containsKey(attributeKey)) break;
      end++;
    }

    final len = end - start;
    if (len <= 0) return;

    // Remove by setting the attribute value to null.
    if (attributeKey == Attribute.mention.key) {
      widget.controller.formatText(start, len, MentionAttribute(value: null));
    } else if (attributeKey == Attribute.tag.key) {
      widget.controller.formatText(start, len, TagAttribute(value: null));
    } else if (attributeKey == Attribute.currency.key) {
      widget.controller.formatText(start, len, CurrencyAttribute(value: null));
    }
  }

  void _checkForMentionAfterSpace() {
    final selection = widget.controller.selection;
    final plainText = widget.controller.document.toPlainText();

    if (selection.baseOffset == 0 || plainText.isEmpty) return;

    // Only when the last typed char is a space.
    final charBefore =
        selection.baseOffset > 0 ? plainText[selection.baseOffset - 1] : null;
    if (charBefore != ' ') return;

    // Avoid doing work repeatedly on consecutive spaces.
    if (selection.baseOffset > 1 &&
        plainText[selection.baseOffset - 2] == ' ') {
      return;
    }

    final mentionEnd = selection.baseOffset - 1; // exclude the space
    if (mentionEnd <= 0) return;

    // If the trailing space follows an already formatted token, this is likely
    // from suggestion selection; do not re-run mention lookup.
    final styleBeforeSpace =
        widget.controller.document.collectStyle(mentionEnd - 1, 1);
    if (styleBeforeSpace.attributes.containsKey(Attribute.tag.key) ||
        styleBeforeSpace.attributes.containsKey(Attribute.currency.key) ||
        styleBeforeSpace.attributes.containsKey(Attribute.mention.key)) {
      return;
    }

    // Scan backwards to find an '@' which is at start-of-word.
    int? atPos;
    for (var i = mentionEnd - 1; i >= 0; i--) {
      final ch = plainText[i];
      if (ch == '\n') {
        return; // don't cross lines
      }
      // If a #/$ token appears between caret and @, this trailing space belongs
      // to that token flow; do not treat it as finishing a mention.
      if (ch == '#' || ch == '\$') {
        return;
      }
      if (ch == '@') {
        if (i == 0 || plainText[i - 1] == ' ' || plainText[i - 1] == '\n') {
          atPos = i;
        }
        break;
      }
    }
    if (atPos == null) return;

    final rawName = plainText.substring(atPos + 1, mentionEnd);
    final name = _normalizeWhitespace(rawName);
    if (name.isEmpty) return;

    // Only apply mention on space when the text after @ is the mention name only.
    // Allow single word "@john " or one space in name "@User 1 ".
    // Skip when there's extra text after (e.g. "@User 1 hello ") to avoid calling mentionSearch.
    final words = rawName.trim().split(RegExp(r'\s+'));
    if (words.length > 2) return;

    final mentionLen = mentionEnd - atPos; // include '@' + raw (with spaces)

    // If this range is already a mention (e.g. user selected from overlay), do not
    // schedule any search — avoids mentionSearch being called when typing after selection.
    final style = widget.controller.document.collectStyle(atPos, mentionLen);
    if (style.attributes.containsKey(Attribute.mention.key)) return;

    // Apply mention (and tag color) when user types space after @name.
    // Debounce so we only call mentionSearch once when they finish with space.
    _mentionSpaceDebounceTimer?.cancel();
    final expectedAt = atPos;
    final expectedName = name;
    final expectedLen = mentionLen;

    _mentionSpaceDebounceTimer = Timer(const Duration(milliseconds: 150), () {
      if (!mounted) return;
      final currentText = widget.controller.document.toPlainText();
      final currentSel = widget.controller.selection;
      if (currentSel.baseOffset == 0 ||
          currentSel.baseOffset > currentText.length) {
        return;
      }
      if (currentText[currentSel.baseOffset - 1] != ' ') {
        return;
      }
      if (expectedAt < 0 || expectedAt >= currentText.length) return;
      final currentEnd = currentSel.baseOffset - 1;
      if (currentEnd <= expectedAt) return;
      final currentRaw = currentText.substring(expectedAt + 1, currentEnd);
      if (_normalizeWhitespace(currentRaw).toLowerCase() !=
          expectedName.toLowerCase()) {
        return;
      }

      // If it's already a mention, don't re-apply.
      final style =
          widget.controller.document.collectStyle(expectedAt, expectedLen);
      if (style.attributes.containsKey(Attribute.mention.key)) return;

      _applyMentionIfFound(expectedName, expectedAt, expectedLen);
    });
  }

  void _checkForDollarAfterSpace() {
    final selection = widget.controller.selection;
    final plainText = widget.controller.document.toPlainText();

    if (selection.baseOffset == 0 || plainText.isEmpty) return;

    // Only when the last typed char is a space.
    final charBefore =
        selection.baseOffset > 0 ? plainText[selection.baseOffset - 1] : null;
    if (charBefore != ' ') return;

    // Avoid doing work repeatedly on consecutive spaces.
    if (selection.baseOffset > 1 &&
        plainText[selection.baseOffset - 2] == ' ') {
      return;
    }

    final end = selection.baseOffset - 1; // exclude the space

    // Scan backwards to find a '$' which is at start-of-word.
    int? dollarPos;
    for (var i = end - 1; i >= 0; i--) {
      final ch = plainText[i];
      if (ch == '\n') {
        return; // don't cross lines
      }
      if (ch == '\$') {
        if (i == 0 || plainText[i - 1] == ' ' || plainText[i - 1] == '\n') {
          dollarPos = i;
        }
        break;
      }
    }
    if (dollarPos == null) return;

    final raw = plainText.substring(dollarPos + 1, end);
    final name = _normalizeWhitespace(raw);
    if (name.isEmpty) return;

    // Only apply when the text after $ is the tag name only (at most 2 words, like @).
    final words = raw.trim().split(RegExp(r'\s+'));
    if (words.length > 2) return;

    // If this range already has currency attribute, don't schedule search.
    final len = end - dollarPos; // include '$' + raw (with spaces)
    final style = widget.controller.document.collectStyle(dollarPos, len);
    if (style.attributes.containsKey(Attribute.currency.key)) return;

    _tagCheckDebounceTimer?.cancel();
    final expectedPos = dollarPos;
    final expectedName = name;
    final expectedLen = len;

    _tagCheckDebounceTimer = Timer(const Duration(milliseconds: 150), () {
      if (!mounted) return;
      final currentText = widget.controller.document.toPlainText();
      final currentSel = widget.controller.selection;
      if (currentSel.baseOffset == 0 ||
          currentSel.baseOffset > currentText.length) {
        return;
      }
      if (currentText[currentSel.baseOffset - 1] != ' ') {
        return;
      }
      if (expectedPos < 0 || expectedPos >= currentText.length) return;
      final currentEnd = currentSel.baseOffset - 1;
      if (currentEnd <= expectedPos) return;
      final currentRaw = currentText.substring(expectedPos + 1, currentEnd);
      if (_normalizeWhitespace(currentRaw).toLowerCase() !=
          expectedName.toLowerCase()) {
        return;
      }

      final style =
          widget.controller.document.collectStyle(expectedPos, expectedLen);
      if (style.attributes.containsKey(Attribute.currency.key)) return;

      _applyTagIfFound('\$', expectedName, expectedPos);
    });
  }

  void _applyMentionIfFound(String name, int atPos, int mentionLen) {
    widget.config.mentionSearch(name).then((mentions) {
      if (!mounted) return;

      MentionItem? match;
      for (final m in mentions) {
        if (_normalizeWhitespace(m.name).toLowerCase() ==
            _normalizeWhitespace(name).toLowerCase()) {
          match = m;
          break;
        }
      }

      // If any mention name is "typedName " + more (e.g. "User 1"), don't auto-apply
      // on space — user may be typing the longer name. Check full list via mentionSearch('').
      final nameLower = _normalizeWhitespace(name).toLowerCase();
      if (match != null) {
        // Always check full list so we see "User 1" even if mentionSearch("User") didn't return it.
        widget.config.mentionSearch('').then((all) {
          if (!mounted) return;
          final hasLonger = all.any((m) {
            final n = _normalizeWhitespace(m.name).toLowerCase();
            return n != nameLower && n.startsWith('$nameLower ');
          });
          if (hasLonger) return; // Don't set color; user may be typing "User 1"
          _applyMentionAttribute(match!, atPos, mentionLen);
        }).catchError((_) {
          if (mounted) _applyMentionAttribute(match!, atPos, mentionLen);
        });
        return;
      }

      if (match == null) {
        // Fallback: ask for all and try exact match.
        widget.config.mentionSearch('').then((all) {
          if (!mounted) return;
          MentionItem? m2;
          for (final m in all) {
            if (_normalizeWhitespace(m.name).toLowerCase() ==
                _normalizeWhitespace(name).toLowerCase()) {
              m2 = m;
              break;
            }
          }
          if (m2 != null) {
            final nameLower = _normalizeWhitespace(name).toLowerCase();
            final hasLonger = all.any((m) {
              final n = _normalizeWhitespace(m.name).toLowerCase();
              return n != nameLower && n.startsWith('$nameLower ');
            });
            if (hasLonger) return; // Don't apply; user may be typing "User 1"
            _applyMentionAttribute(m2, atPos, mentionLen);
          }
          // If not in list, don't treat as tag — leave as plain text (no color).
        });
        return;
      }
    }).catchError((_) {
      // On error, don't apply — only treat as tag when found in list.
    });
  }

  void _applyMentionAttribute(MentionItem item, int atPos, int mentionLen) {
    final canonicalText = '@${item.name}';
    var finalLen = mentionLen;
    final plainText = widget.controller.document.toPlainText();
    if (atPos + mentionLen <= plainText.length) {
      final currentText = plainText.substring(atPos, atPos + mentionLen);
      if (currentText != canonicalText) {
        final selection = widget.controller.selection;
        final diff = canonicalText.length - mentionLen;
        final updatedSelection = selection.copyWith(
          baseOffset: selection.baseOffset >= atPos
              ? selection.baseOffset + diff
              : selection.baseOffset,
          extentOffset: selection.extentOffset >= atPos
              ? selection.extentOffset + diff
              : selection.extentOffset,
        );
        widget.controller.replaceText(
          atPos,
          mentionLen,
          canonicalText,
          updatedSelection,
        );
        finalLen = canonicalText.length;
      }
    }
    widget.controller.formatText(
      atPos,
      finalLen,
      MentionAttribute(value: {
        'id': item.id,
        'name': item.name,
        if (item.avatarUrl != null) 'avatarUrl': item.avatarUrl,
        'color': widget.config.defaultMentionColor,
      }),
    );
    _applyConfiguredTagStyle(atPos, finalLen);
  }

  /// Check if space was just typed after a tag trigger and apply tag attribute
  void _checkForTagAfterSpace() {
    final selection = widget.controller.selection;
    final plainText = widget.controller.document.toPlainText();

    if (selection.baseOffset == 0 || plainText.isEmpty) return;

    // Check if the character before cursor is a space
    final charBefore =
        selection.baseOffset > 0 ? plainText[selection.baseOffset - 1] : null;

    if (charBefore != ' ') return;

    // Look backwards to find tag trigger (# or $)
    var pos = selection.baseOffset - 2; // Skip the space
    if (pos < 0) return;

    String? triggerChar;
    int? triggerPos;

    // Find the trigger character
    while (pos >= 0) {
      if (plainText[pos] == '#' || plainText[pos] == '\$') {
        triggerChar = plainText[pos];
        triggerPos = pos;
        break;
      }
      if (plainText[pos] == ' ' || plainText[pos] == '\n') {
        // Hit a word boundary, no tag found
        return;
      }
      pos--;
    }

    if (triggerChar == null || triggerPos == null) return;

    // Check if there's a space or newline before the trigger (start of word)
    if (triggerPos > 0) {
      final charBeforeTrigger = plainText[triggerPos - 1];
      if (charBeforeTrigger != ' ' && charBeforeTrigger != '\n') {
        return;
      }
    }

    // Extract tag name (between trigger and space)
    final tagName =
        plainText.substring(triggerPos + 1, selection.baseOffset - 1);
    if (tagName.isEmpty) return;

    // Check if this text already has a tag attribute
    final style =
        widget.controller.document.collectStyle(triggerPos, tagName.length + 1);
    final hasTag = style.attributes.containsKey(Attribute.tag.key);
    final hasCurrency = style.attributes.containsKey(Attribute.currency.key);

    // If already has tag/currency attribute, don't re-apply
    if (hasTag || hasCurrency) return;

    // Only handle # tags here. $ tags are handled by _checkForDollarAfterSpace.
    if (triggerChar != '#') return;

    final color = widget.config.defaultHashTagColor;
    if (color == null) return;

    // Determine if user ended the tag with a boundary (space or newline).
    final boundaryPos = selection.baseOffset - 1;
    final boundaryChar = plainText[boundaryPos];
    final hasBoundary = boundaryChar == ' ' || boundaryChar == '\n';

    // Apply color across the tag text only (exclude the boundary).
    _applyDefaultHashTagColor(triggerPos, tagName);

    // After user finishes a #tag with space, hide the suggestion overlay.
    if (_isOverlayVisible && !_isMention && _tagTrigger == '#') {
      _hideOverlay();
    }
  }

  void _clearHashTagStyleOnNewline() {
    final selection = widget.controller.selection;
    final plainText = widget.controller.document.toPlainText();
    if (selection.baseOffset < 2 || plainText.isEmpty) return;

    final charBefore = plainText[selection.baseOffset - 1];
    if (charBefore != '\n') return;

    final beforeNewlinePos = selection.baseOffset - 2;
    if (beforeNewlinePos < 0) return;

    final style = widget.controller.document.collectStyle(beforeNewlinePos, 1);
    if (!style.attributes.containsKey(Attribute.tag.key)) {
      return;
    }

    // Remove tag attribute from the newline and clear toggled style.
    widget.controller.formatText(
      selection.baseOffset - 1,
      1,
      TagAttribute(value: null),
    );
    widget.controller.formatSelection(TagAttribute(value: null));
  }

  void _checkForHashTagsInChange(DocChange change) {
    if (_isApplyingHashTagColor) return;
    final color = widget.config.defaultHashTagColor;

    int offset = 0;
    final ranges = <_HashTagRange>[];

    for (final op in change.change.toList()) {
      if (op.isRetain) {
        offset += op.length ?? 0;
        continue;
      }
      if (op.isInsert) {
        if (op.data is String) {
          final text = op.data as String;
          // Skip single-character inserts that are unlikely to be paste.
          if (text.length > 1 || text.contains('\n')) {
            _collectHashTags(text, offset, ranges);
          }
          offset += text.length;
        } else {
          offset += 1;
        }
        continue;
      }
      if (op.isDelete) {
        continue;
      }
    }

    if (ranges.isEmpty) return;

    _isApplyingHashTagColor = true;
    try {
      for (final range in ranges) {
        final style =
            widget.controller.document.collectStyle(range.start, range.length);
        if (style.attributes.containsKey(Attribute.tag.key)) {
          continue;
        }
        widget.controller.formatText(
          range.start,
          range.length,
          TagAttribute(value: {
            'name': range.name,
            'color': color,
          }),
        );
        _applyConfiguredTagStyle(range.start, range.length);
      }
    } finally {
      _isApplyingHashTagColor = false;
    }
  }

  void _collectHashTags(
      String insertedText, int baseOffset, List<_HashTagRange> ranges) {
    if (insertedText.isEmpty) return;
    final fullText = widget.controller.document.toPlainText();
    for (int i = 0; i < insertedText.length; i++) {
      if (insertedText[i] != '#') continue;
      final globalPos = baseOffset + i;
      if (globalPos >= fullText.length) continue;
      if (globalPos > 0 && !_isBoundary(fullText[globalPos - 1])) {
        continue;
      }
      int end = globalPos + 1;
      while (end < fullText.length && !_isBoundary(fullText[end])) {
        end++;
      }
      final name = fullText.substring(globalPos + 1, end);
      if (name.isEmpty) continue;
      ranges.add(_HashTagRange(globalPos, name.length + 1, name));
    }
  }

  bool _isBoundary(String ch) {
    return ch == ' ' || ch == '\n' || ch == '\t';
  }

  /// Check if typed tag name matches any tag in the list and apply color
  void _checkAndApplyTypedTag(
      String triggerChar, String tagQuery, int tagPosition) {
    if (tagQuery.isEmpty) return;

    // Update last checked query
    _lastCheckedTagQuery = tagQuery;

    // Cancel any pending debounce timer
    _tagCheckDebounceTimer?.cancel();

    // Debounce the check to avoid excessive searches while typing
    _tagCheckDebounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return;

      // Re-check if we're still in the same tag context
      final currentResult = triggerChar == '#'
          ? _getCurrentQueryForTrigger('#')
          : _getCurrentQueryForTrigger('\$');

      if (currentResult == null || currentResult.query != tagQuery) {
        // Query changed, don't apply
        return;
      }

      // Check if this text already has a tag attribute
      final style = widget.controller.document
          .collectStyle(tagPosition, tagQuery.length + 1);
      final hasTag = style.attributes.containsKey(Attribute.tag.key);
      final hasCurrency = style.attributes.containsKey(Attribute.currency.key);

      // If already has tag/currency attribute, don't re-apply
      if (hasTag || hasCurrency) return;

      // Search for matching tag and apply attribute
      _applyTagIfFound(triggerChar, tagQuery, tagPosition);
    });
  }

  /// Search for tag in the list and apply attribute if found
  void _applyTagIfFound(String triggerChar, String tagName, int tagPosition) {
    // Use the appropriate search callback
    final searchCallback = triggerChar == '\$'
        ? widget.config.dollarSearch
        : widget.config.tagSearch;

    if (searchCallback == null) return;

    // Get the actual text in the document to determine the correct length
    final plainText = widget.controller.document.toPlainText();

    // Find the end of the tag text (either space, newline, or end of document)
    var tagEndPos = tagPosition + 1 + tagName.length;
    if (tagEndPos < plainText.length) {
      final charAtEnd = plainText[tagEndPos];
      if (charAtEnd != ' ' && charAtEnd != '\n') {
        // Tag might be longer, find the actual end
        while (tagEndPos < plainText.length &&
            plainText[tagEndPos] != ' ' &&
            plainText[tagEndPos] != '\n') {
          tagEndPos++;
        }
      }
    }

    final actualTagLength = tagEndPos - tagPosition;

    // Search for the tag (use the tag name as query for better performance)
    final tagNameLower = tagName.toLowerCase();
    searchCallback(tagName).then((tags) {
      if (!mounted) return;

      TagItem? matchingTag;
      for (final tag in tags) {
        if (tag.name.toLowerCase() == tagNameLower) {
          matchingTag = tag;
          break;
        }
      }

      // If no match found, try full list.
      if (matchingTag == null) {
        searchCallback('').then((allTags) {
          if (!mounted) return;
          TagItem? match;
          for (final tag in allTags) {
            if (tag.name.toLowerCase() == tagNameLower) {
              match = tag;
              break;
            }
          }
          if (match != null) {
            if (triggerChar == '\$') {
              _tryApplyTag(
                triggerChar,
                match,
                tagPosition,
                actualTagLength,
                tagNameLower,
                allTags,
              );
            } else {
              _applyTagAttribute(
                  triggerChar, match, tagPosition, actualTagLength);
            }
          } else if (triggerChar == '#') {
            // #: type # then text → apply tag color even when not in list.
            _applyTagAttribute(
              triggerChar,
              TagItem(id: '', name: tagName),
              tagPosition,
              actualTagLength,
            );
          }
          // $ not in list: don't treat as tag.
        }).catchError((_) {});
        return;
      }

      // Have a match.
      if (triggerChar == '\$') {
        // $: check full list for longer name (same as @).
        searchCallback('').then((allTags) {
          if (!mounted) return;
          _tryApplyTag(
            triggerChar,
            matchingTag!,
            tagPosition,
            actualTagLength,
            tagNameLower,
            allTags,
          );
        }).catchError((_) {
          if (mounted) {
            _applyTagAttribute(
                triggerChar, matchingTag!, tagPosition, actualTagLength);
          }
        });
      } else {
        // #: apply directly (no longer-name check, original # logic).
        _applyTagAttribute(
            triggerChar, matchingTag!, tagPosition, actualTagLength);
      }
    }).catchError((_) {});
  }

  /// Apply $ tag only if no longer name exists in list (same logic as @). Not used for #.
  void _tryApplyTag(
    String triggerChar,
    TagItem matchingTag,
    int tagPosition,
    int actualTagLength,
    String tagNameLower,
    List<TagItem> allTags,
  ) {
    final hasLonger = allTags.any((t) {
      final n = t.name.toLowerCase();
      return n != tagNameLower && n.startsWith('$tagNameLower ');
    });
    if (hasLonger) return; // Don't apply; user may be typing "User 1"
    _applyTagAttribute(triggerChar, matchingTag, tagPosition, actualTagLength);
  }

  /// Apply tag attribute to the specified range
  void _applyTagAttribute(
      String triggerChar, TagItem matchingTag, int tagPosition, int tagLength) {
    final canonicalText = _buildCanonicalTagText(triggerChar, matchingTag);
    var finalLen = tagLength;
    final plainText = widget.controller.document.toPlainText();
    if (tagPosition + tagLength <= plainText.length) {
      final currentText =
          plainText.substring(tagPosition, tagPosition + tagLength);
      if (currentText != canonicalText) {
        final selection = widget.controller.selection;
        final diff = canonicalText.length - tagLength;
        final updatedSelection = selection.copyWith(
          baseOffset: selection.baseOffset >= tagPosition
              ? selection.baseOffset + diff
              : selection.baseOffset,
          extentOffset: selection.extentOffset >= tagPosition
              ? selection.extentOffset + diff
              : selection.extentOffset,
        );
        widget.controller.replaceText(
          tagPosition,
          tagLength,
          canonicalText,
          updatedSelection,
        );
        finalLen = canonicalText.length;
      }
    }
    if (triggerChar == '\$') {
      widget.controller.formatText(
        tagPosition,
        finalLen,
        CurrencyAttribute(value: {
          'id': matchingTag.id,
          'name': matchingTag.name,
          if (matchingTag.count != null) 'count': matchingTag.count,
          'color': widget.config.defaultDollarTagColor,
        }),
      );
    } else {
      widget.controller.formatText(
        tagPosition,
        finalLen,
        TagAttribute(value: {
          'id': matchingTag.id,
          'name': matchingTag.name,
          if (matchingTag.count != null) 'count': matchingTag.count,
          'color': widget.config.defaultHashTagColor,
        }),
      );
    }
    _applyConfiguredTagStyle(tagPosition, finalLen);
  }

  void _applyDefaultHashTagColor(int tagPosition, String tagName) {
    if (tagName.isEmpty) return;
    final color = widget.config.defaultHashTagColor;

    final length = tagName.length + 1; // include '#'
    if (_hasHashTagAttribute(tagPosition, length, tagName, color)) return;

    widget.controller.formatText(
      tagPosition,
      length,
      TagAttribute(value: {
        'name': tagName,
        'color': color,
      }),
    );
    _applyConfiguredTagStyle(tagPosition, length);
  }

  void _applyConfiguredTagStyle(int start, int length) {
    if (start < 0 || length <= 0) return;
    if (widget.config.tagStyle.isEmpty) return;
    widget.controller.formatTextStyle(start, length, widget.config.tagStyle);
    _clearTagInlineStyleFromCursor(start, length);
  }

  /// Prevent inline tag style (e.g. font-weight) from leaking into normal
  /// typing when the cursor is already after the styled tag span.
  void _clearTagInlineStyleFromCursor(int start, int length) {
    final selection = widget.controller.selection;
    if (!selection.isCollapsed) return;

    final cursorOffset = selection.baseOffset;
    final tagEnd = start + length;
    if (cursorOffset < tagEnd) {
      // Keep inline style while user edits inside the tag span.
      return;
    }

    var clearedAny = false;
    final previousOffset = cursorOffset - 1;
    if (previousOffset >= tagEnd && previousOffset >= 0) {
      final attrsToClear = _tokenStyleClearAttributesForRange(
        previousOffset,
        1,
      );
      for (final attr in attrsToClear) {
        widget.controller.formatText(
          previousOffset,
          1,
          attr,
          shouldNotifyListeners: false,
        );
        clearedAny = true;
      }
    }

    widget.controller.toggledStyle = const Style();
    if (clearedAny) {
      widget.controller.notifyListeners();
    }
  }

  Map<String, Attribute> _tokenStyleClearCandidates() {
    final clearByKey = <String, Attribute>{
      Attribute.mention.key: const MentionAttribute(value: null),
      Attribute.tag.key: const TagAttribute(value: null),
      Attribute.currency.key: const CurrencyAttribute(value: null),
      Attribute.bold.key: Attribute.clone(Attribute.bold, null),
      Attribute.italic.key: Attribute.clone(Attribute.italic, null),
      Attribute.underline.key: Attribute.clone(Attribute.underline, null),
      Attribute.strikeThrough.key:
          Attribute.clone(Attribute.strikeThrough, null),
      Attribute.font.key: Attribute.clone(Attribute.font, null),
      Attribute.fontWeight.key: const FontWeightAttribute(null),
      Attribute.size.key: Attribute.clone(Attribute.size, null),
      Attribute.color.key: Attribute.clone(Attribute.color, null),
      Attribute.background.key: Attribute.clone(Attribute.background, null),
    };

    for (final attr in widget.config.tagStyle.attributes.values) {
      if (!attr.isInline || attr.value == null) continue;
      clearByKey[attr.key] = Attribute.clone(attr, null);
    }

    return clearByKey;
  }

  List<Attribute> _tokenStyleClearAttributesForRange(int start, int length) {
    if (start < 0 || length <= 0) return const [];

    final plainText = widget.controller.document.toPlainText();
    if (plainText.isEmpty || start >= plainText.length) return const [];

    final end = (start + length).clamp(0, plainText.length);
    final candidates = _tokenStyleClearCandidates();
    final keysToClear = <String>{};

    for (var offset = start; offset < end; offset++) {
      final style = widget.controller.document.collectStyle(offset, 1);
      for (final key in style.attributes.keys) {
        if (candidates.containsKey(key)) {
          keysToClear.add(key);
        }
      }
    }

    return keysToClear.map((key) => candidates[key]!).toList(growable: false);
  }

  bool _hasHashTagAttribute(
      int tagPosition, int length, String tagName, String color) {
    final style = widget.controller.document.collectStyle(tagPosition, length);
    final attr = style.attributes[Attribute.tag.key];
    if (attr?.value is! Map) return false;
    final map = attr!.value as Map;
    final name = map['name']?.toString();
    final attrColor = map['color']?.toString();
    return name == tagName && attrColor == color;
  }

  String _buildCanonicalTagText(String triggerChar, TagItem item) {
    if (triggerChar == '\$') {
      // Keep raw text as-is for $ tags (no numeric formatting)
      return '\$${item.name}';
    }
    return '#${item.name}';
  }

  String _normalizeWhitespace(String value) {
    // Trim and collapse any runs of whitespace into a single space.
    return value.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  @override
  Widget build(BuildContext context) {
    final overlayWidget = _mentionTagState?.overlayWidget;

    return LayoutBuilder(
      builder: (context, constraints) {
        final editor = IgnorePointer(
          ignoring: _blockPointerEventsForLayout,
          child: widget.child,
        );

        return Column(
          mainAxisSize: constraints.hasBoundedHeight
              ? MainAxisSize.max
              : MainAxisSize.min,
          children: [
            // Fill bounded parents, but allow natural height in ListView or
            // other unbounded-height parents.
            if (constraints.hasBoundedHeight)
              Expanded(child: editor)
            else
              editor,
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SizeTransition(
                    sizeFactor: animation,
                    axisAlignment: -1.0,
                    child: child,
                  ),
                );
              },
              child: (_isOverlayVisible && overlayWidget != null)
                  ? overlayWidget
                  : const SizedBox.shrink(key: ValueKey('empty')),
            ),
          ],
        );
      },
    );
  }
}
