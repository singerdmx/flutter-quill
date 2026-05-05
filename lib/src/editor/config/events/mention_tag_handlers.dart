import 'dart:async';

import 'package:flutter/material.dart';

import '../../../controller/quill_controller.dart';
import '../../../document/attribute.dart';
import '../../../document/style.dart';
import '../../widgets/mention_tag_overlay.dart';
import '../mention_tag_config.dart';

/// Result of resolving which #[query] / $[query] slice in the document should
/// be replaced when a suggestion is picked (see [_resolveLiveTagReplaceContext]).
typedef _LiveTagReplaceContext = ({
  int triggerPos,
  String triggerChar,
  int deleteLength,
});

/// State for managing mention/tag overlay
class MentionTagState {
  MentionTagState({
    required this.config,
    required this.controller,
    this.onVisibilityChanged,
  });

  MentionTagConfig config;
  final QuillController controller;
  final void Function(
          bool visible, String query, bool isMention, String tagTrigger)?
      onVisibilityChanged;
  MentionTagOverlay? overlayWidget;
  final ValueKey _overlayKey = const ValueKey(
      'mention_tag_overlay'); // Stable key to preserve widget state
  String currentQuery = '';
  bool isMention = false;
  int triggerPosition = -1;
  String tagTriggerChar = '#'; // Track which tag trigger was used (# or $)
  int _itemCount = 0; // Track number of items in overlay
  Timer? _searchDebounceTimer; // Debounce timer for search
  String? _pendingQuery; // Query waiting to be applied after debounce

  void updateConfig(MentionTagConfig newConfig) {
    config = newConfig;
  }

  void showOverlay(bool isMentionMode, int position, String query,
      {String? tagTrigger}) {
    isMention = isMentionMode;
    triggerPosition = position;
    currentQuery = query;
    if (tagTrigger != null) {
      tagTriggerChar = tagTrigger;
    }

    // Cancel any pending debounce timer
    _searchDebounceTimer?.cancel();

    // Create widget immediately (no debounce for initial show)
    overlayWidget = MentionTagOverlay(
      key: _overlayKey, // Stable key preserves state across rebuilds
      query: query,
      isMention: isMentionMode,
      tagTrigger: tagTriggerChar,
      defaultMentionColor: config.defaultMentionColor,
      defaultHashTagColor: config.defaultHashTagColor,
      defaultDollarTagColor: config.defaultDollarTagColor,
      onSelectMention: _handleMentionSelected,
      onSelectTag: _handleTagSelected,
      mentionSearch: config.mentionSearch,
      tagSearch: config.tagSearch,
      dollarSearch: config.dollarSearch,
      maxHeight: config.maxHeight,
      mentionItemBuilder: config.mentionItemBuilder,
      tagItemBuilder: config.tagItemBuilder,
      customData: config.customData,
      onLoadMoreMentions: config.onLoadMoreMentions,
      onLoadMoreTags: config.onLoadMoreTags,
      onLoadMoreDollarTags: config.onLoadMoreDollarTags,
      loadMoreIndicatorBuilder: config.loadMoreIndicatorBuilder,
      suggestionListPadding: config.suggestionListPadding,
      decoration: config.decoration,
      onItemCountChanged: _handleItemCountChanged,
    );
    // Always notify visibility change to ensure wrapper rebuilds
    onVisibilityChanged?.call(true, query, isMentionMode, tagTriggerChar);
  }

  void updateQuery(String query) {
    // Update query without recreating widget
    if (currentQuery == query) return;

    currentQuery = query;

    // Cancel any pending debounce timer
    _searchDebounceTimer?.cancel();

    // Debounce widget update to avoid rapid rebuilds
    final queryToUpdate = query;
    _searchDebounceTimer = Timer(const Duration(milliseconds: 150), () {
      if (currentQuery == queryToUpdate && overlayWidget != null) {
        // Update the existing widget's query by recreating with same key
        // The stable key ensures Flutter reuses the state and calls didUpdateWidget
        overlayWidget = MentionTagOverlay(
          key: _overlayKey, // Same stable key preserves state
          query: queryToUpdate,
          isMention: isMention,
          tagTrigger: tagTriggerChar,
          defaultMentionColor: config.defaultMentionColor,
          defaultHashTagColor: config.defaultHashTagColor,
          defaultDollarTagColor: config.defaultDollarTagColor,
          onSelectMention: _handleMentionSelected,
          onSelectTag: _handleTagSelected,
          mentionSearch: config.mentionSearch,
          tagSearch: config.tagSearch,
          dollarSearch: config.dollarSearch,
          maxHeight: config.maxHeight,
          mentionItemBuilder: config.mentionItemBuilder,
          tagItemBuilder: config.tagItemBuilder,
          customData: config.customData,
          onLoadMoreMentions: config.onLoadMoreMentions,
          onLoadMoreTags: config.onLoadMoreTags,
          onLoadMoreDollarTags: config.onLoadMoreDollarTags,
          loadMoreIndicatorBuilder: config.loadMoreIndicatorBuilder,
          suggestionListPadding: config.suggestionListPadding,
          decoration: config.decoration,
          onItemCountChanged: _handleItemCountChanged,
        );
        // Notify visibility change to ensure wrapper rebuilds with updated widget
        // Use a flag to indicate this is just an update, not a show/hide
        onVisibilityChanged?.call(
            true, queryToUpdate, isMention, tagTriggerChar);
      }
    });
  }

  void hideOverlay() {
    _searchDebounceTimer?.cancel();
    _searchDebounceTimer = null;
    _pendingQuery = null;
    overlayWidget = null;
    currentQuery = '';
    triggerPosition = -1;
    tagTriggerChar = '#';
    _itemCount = 0;
    onVisibilityChanged?.call(false, '', false, '#');
  }

  /// Refresh the suggestion list with current query
  /// Call this when the underlying data has changed and you want to update the list
  void refreshList() {
    if (overlayWidget != null) {
      // Recreate widget with same query but updated search callbacks
      // This will trigger didUpdateWidget which will detect the callback change and refresh
      // Works even with empty query (when showing all data)
      overlayWidget = MentionTagOverlay(
        key: _overlayKey,
        query: currentQuery,
        isMention: isMention,
        tagTrigger: tagTriggerChar,
        defaultMentionColor: config.defaultMentionColor,
        defaultHashTagColor: config.defaultHashTagColor,
        defaultDollarTagColor: config.defaultDollarTagColor,
        onSelectMention: _handleMentionSelected,
        onSelectTag: _handleTagSelected,
        mentionSearch: config.mentionSearch,
        tagSearch: config.tagSearch,
        dollarSearch: config.dollarSearch,
        maxHeight: config.maxHeight,
        mentionItemBuilder: config.mentionItemBuilder,
        tagItemBuilder: config.tagItemBuilder,
        customData: config.customData,
        onLoadMoreMentions: config.onLoadMoreMentions,
        onLoadMoreTags: config.onLoadMoreTags,
        onLoadMoreDollarTags: config.onLoadMoreDollarTags,
        loadMoreIndicatorBuilder: config.loadMoreIndicatorBuilder,
        suggestionListPadding: config.suggestionListPadding,
        decoration: config.decoration,
        onItemCountChanged: _handleItemCountChanged,
      );
      onVisibilityChanged?.call(true, currentQuery, isMention, tagTriggerChar);
    }
  }

  void _handleItemCountChanged(int count) {
    if (_itemCount == count) return;

    _itemCount = count;
    if (overlayWidget == null) return;

    onVisibilityChanged?.call(
      count > 0,
      currentQuery,
      isMention,
      tagTriggerChar,
    );
  }

  void _handleMentionSelected(MentionItem item) {
    if (triggerPosition == -1) return;

    final selectedTriggerPosition = triggerPosition;
    final selectedQuery = currentQuery;

    // Snapshot document and caret before hideOverlay: hiding the overlay can
    // rebuild the editor and move selection. If we then scan for '@' using the
    // new caret, we can hit the wrong mention when multiple @ exist on a line.
    final plainText = controller.document.toPlainText();
    final caretBeforeHide = controller.selection.baseOffset;
    final actualPosition = _resolveTriggerPosition(
      '@',
      plainText,
      selectedTriggerPosition,
      caretForFallback: caretBeforeHide,
    );
    if (actualPosition < 0 || actualPosition >= plainText.length) {
      hideOverlay();
      return;
    }

    // Calculate how much to delete from the stored trigger/query. This stays
    // stable even if tapping a paginated suggestion changes editor selection.
    final deleteLength = _queryLengthFromTrigger(
      plainText,
      actualPosition,
      selectedQuery,
      caretForFallback: caretBeforeHide,
    );

    hideOverlay();
    final mentionText = '@${item.name}';
    final shouldAppendSpace = config.appendSpaceAfterSelection;
    final insertedText = shouldAppendSpace ? '$mentionText ' : mentionText;
    final attribute = _mentionAttributeForItem(item);

    // Apply synchronously so the next typed character cannot inherit stale style.
    _resetToggledStyleSilently();
    controller
      ..replaceText(
        actualPosition,
        deleteLength,
        insertedText,
        TextSelection.collapsed(offset: actualPosition + insertedText.length),
        shouldNotifyListeners: false,
      )
      ..formatText(
        actualPosition,
        mentionText.length,
        attribute,
        shouldNotifyListeners: false,
      );
    if (config.tagStyle.isNotEmpty) {
      _applyInlineStyleWithoutNotify(
        actualPosition,
        mentionText.length,
        config.tagStyle,
      );
    }
    if (shouldAppendSpace) {
      _clearTagStyleFromTrailingSpace(actualPosition + mentionText.length);
    }
    _resetToggledStyleSilently();
    _resetTypingStyleAfterSelection();
    controller.notifyListeners();
    scheduleMicrotask(() {
      _ensureTokenAttribute(
        actualPosition,
        mentionText,
        Attribute.mention.key,
        attribute,
      );
    });
    config.onMentionSelected?.call(item);
  }

  void _handleTagSelected(TagItem item) {
    // Tag selection after pagination or suggestion refresh must not assume
    // [triggerPosition] / [currentQuery] still match the editor: resolve the
    // active #/$ token from live plain text and caret first, using cache only
    // as a hint when the caret is unreliable (e.g. focus moved on tap).
    final plainText = controller.document.toPlainText();
    final caret = _selectionEndForTagReplace();

    final resolved = _resolveLiveTagReplaceContext(
      plainText: plainText,
      caret: caret,
      preferredTrigger: tagTriggerChar,
      hintTriggerPosition: triggerPosition,
    );
    if (resolved == null) {
      hideOverlay();
      return;
    }

    final actualPosition = resolved.triggerPos;
    final triggerChar = resolved.triggerChar;
    final deleteLength = resolved.deleteLength;
    if (deleteLength <= 0 || actualPosition < 0) {
      hideOverlay();
      return;
    }

    hideOverlay();

    // Format tag text
    String tagText;
    if (triggerChar == '\$') {
      // Keep raw text as-is for $ tags (no numeric formatting)
      tagText = '\$${item.name}';
    } else {
      // For # tags, use as is
      tagText = '$triggerChar${item.name}';
    }

    final shouldAppendSpace = config.appendSpaceAfterSelection;
    final insertedText = shouldAppendSpace ? '$tagText ' : tagText;
    final attribute = triggerChar == '\$'
        ? _currencyAttributeForItem(item)
        : _tagAttributeForItem(item);

    // Apply synchronously so the next typed character cannot inherit stale style.
    _resetToggledStyleSilently();
    controller.replaceText(
      actualPosition,
      deleteLength,
      insertedText,
      TextSelection.collapsed(offset: actualPosition + insertedText.length),
      shouldNotifyListeners: false,
    );
    controller.formatText(
      actualPosition,
      tagText.length,
      attribute,
      shouldNotifyListeners: false,
    );
    if (config.tagStyle.isNotEmpty) {
      _applyInlineStyleWithoutNotify(
        actualPosition,
        tagText.length,
        config.tagStyle,
      );
    }
    if (shouldAppendSpace) {
      _clearTagStyleFromTrailingSpace(actualPosition + tagText.length);
    }
    _resetToggledStyleSilently();
    _resetTypingStyleAfterSelection();
    controller.notifyListeners();
    scheduleMicrotask(() {
      _ensureTokenAttribute(
        actualPosition,
        tagText,
        attribute.key,
        attribute,
      );
    });
    config.onTagSelected?.call(item);
  }

  MentionAttribute _mentionAttributeForItem(MentionItem item) {
    return MentionAttribute(value: {
      'id': item.id,
      'name': item.name,
      if (item.avatarUrl != null) 'avatarUrl': item.avatarUrl,
      if (item.customData != null) 'customData': item.customData,
      'color': config.defaultMentionColor,
    });
  }

  TagAttribute _tagAttributeForItem(TagItem item) {
    return TagAttribute(value: {
      'id': item.id,
      'name': item.name,
      if (item.count != null) 'count': item.count,
      'color': config.defaultHashTagColor,
    });
  }

  CurrencyAttribute _currencyAttributeForItem(TagItem item) {
    return CurrencyAttribute(value: {
      'id': item.id,
      'name': item.name,
      if (item.count != null) 'count': item.count,
      'color': config.defaultDollarTagColor,
    });
  }

  void _ensureTokenAttribute(
    int offset,
    String tokenText,
    String attributeKey,
    Attribute attribute,
  ) {
    final plainText = controller.document.toPlainText();
    if (offset < 0 || offset + tokenText.length > plainText.length) return;
    if (plainText.substring(offset, offset + tokenText.length) != tokenText) {
      return;
    }

    final style = controller.document.collectStyle(offset, tokenText.length);
    final current = style.attributes[attributeKey];
    if (_attributeValuesEqual(current?.value, attribute.value)) return;

    controller.formatText(offset, tokenText.length, attribute);
  }

  bool _attributeValuesEqual(dynamic left, dynamic right) {
    if (left == right) return true;
    if (left is Map && right is Map) {
      if (left.length != right.length) return false;
      for (final key in left.keys) {
        if (!right.containsKey(key) || left[key] != right[key]) {
          return false;
        }
      }
      return true;
    }
    return false;
  }

  void _resetToggledStyleSilently() {
    controller.toggledStyle = const Style();
  }

  /// Caret end used when mapping a tag pick to document coordinates. Preference
  /// is collapsed offset; when not collapsed, use the extent farthest in the
  /// document (e.g. IME or selection quirks during overlay interaction).
  int _selectionEndForTagReplace() {
    final sel = controller.selection;
    if (!sel.isValid) return 0;
    return sel.extentOffset > sel.baseOffset
        ? sel.extentOffset
        : sel.baseOffset;
  }

  /// Locates the active tag trigger and how many code units to replace using
  /// [plainText] only. [currentQuery] / [triggerPosition] are not trusted for
  /// span length after pagination or overlay rebuilds—they are hints only.
  _LiveTagReplaceContext? _resolveLiveTagReplaceContext({
    required String plainText,
    required int caret,
    required String preferredTrigger,
    required int hintTriggerPosition,
  }) {
    if (plainText.isEmpty) return null;
    final c = caret.clamp(0, plainText.length);
    final triggers = preferredTrigger == r'$'
        ? <String>[r'$', '#']
        : <String>['#', r'$'];

    _LiveTagReplaceContext? best;
    int bestDistance = 1 << 30;

    for (final trigger in triggers) {
      final candidates = <int?>[
        _findTagTriggerBackward(plainText, c, trigger),
        _tagTriggerFromHint(plainText, hintTriggerPosition, trigger),
      ];

      for (final pos in candidates) {
        if (pos == null || pos < 0 || pos >= plainText.length) continue;
        final ch = plainText[pos];
        if (ch != '#' && ch != r'$') continue;

        final deleteLength = _tagDeleteLengthFromLiveDoc(plainText, pos, ch, c);
        if (deleteLength <= 0) continue;

        // Prefer trigger closest to caret. This keeps replacements anchored to
        // what the user is actively editing even if cached trigger/query drift.
        final distance = (c - pos).abs();
        if (best == null || distance < bestDistance) {
          best = (triggerPos: pos, triggerChar: ch, deleteLength: deleteLength);
          bestDistance = distance;
        }
      }
    }

    return best;
  }

  /// Finds [triggerChar] at word start by scanning backward from [caret].
  int? _findTagTriggerBackward(
    String plainText,
    int caret,
    String triggerChar,
  ) {
    if (caret <= 0) return null;

    var pos = caret - 1;
    while (pos >= 0) {
      final c = plainText[pos];
      if (c == '\n') return null;
      if (c == triggerChar) {
        if (pos == 0 ||
            plainText[pos - 1] == ' ' ||
            plainText[pos - 1] == '\n') {
          return pos;
        }
      }
      pos--;
    }
    return null;
  }

  int? _tagTriggerFromHint(
    String plainText,
    int hintPos,
    String triggerChar,
  ) {
    if (hintPos < 0 || hintPos >= plainText.length) return null;
    if (plainText[hintPos] != triggerChar) return null;
    if (hintPos > 0) {
      final before = plainText[hintPos - 1];
      if (before != ' ' && before != '\n') return null;
    }
    return hintPos;
  }

  /// First index *after* the in-progress tag body (exclusive), given the
  /// trigger at [triggerPos].
  int _tagPartialTokenEndExclusive(
    String plainText,
    int triggerPos,
    String triggerChar,
  ) {
    var end = triggerPos + 1;
    if (triggerChar == '#') {
      while (end < plainText.length) {
        final c = plainText[end];
        if (c == ' ' || c == '\n' || c == '\t') break;
        end++;
      }
    } else {
      while (end < plainText.length && plainText[end] != '\n') {
        end++;
      }
    }
    return end;
  }

  /// First index strictly after [from] within the same line (before `\n` or eof).
  int _lineExclusiveEndBeforeNewline(String plainText, int from) {
    if (from < 0 || from > plainText.length) return plainText.length;
    var i = from;
    while (i < plainText.length && plainText[i] != '\n') {
      i++;
    }
    return i;
  }

  /// Length from [triggerPos] through the tag slice to replace.
  ///
  /// Uses a forward grammar pass (#'s body stops at ASCII whitespace unless
  /// [caret] extends past that—for multi-word previews like `#Demo Tes`) and
  /// never crosses a newline.
  int _tagDeleteLengthFromLiveDoc(
    String plainText,
    int triggerPos,
    String triggerChar,
    int caret,
  ) {
    final maxSpan = plainText.length - triggerPos;
    if (maxSpan <= 0) return 0;

    final scanEnd =
        _tagPartialTokenEndExclusive(plainText, triggerPos, triggerChar);
    final lineEnd = _lineExclusiveEndBeforeNewline(plainText, triggerPos);

    var endExclusive = scanEnd;
    if (caret > triggerPos && caret <= lineEnd) {
      final cappedCaret = caret.clamp(triggerPos + 1, lineEnd);
      endExclusive = cappedCaret > endExclusive ? cappedCaret : endExclusive;
    }

    final len = endExclusive - triggerPos;
    return len.clamp(1, maxSpan);
  }

  int _resolveTriggerPosition(
    String triggerChar,
    String plainText,
    int selectedTriggerPosition, {
    required int caretForFallback,
  }) {
    if (selectedTriggerPosition >= 0 &&
        selectedTriggerPosition < plainText.length &&
        plainText[selectedTriggerPosition] == triggerChar) {
      return selectedTriggerPosition;
    }

    final selectionOffset = caretForFallback;
    var searchPos = selectionOffset - 1;
    while (searchPos >= 0 && searchPos < plainText.length) {
      if (plainText[searchPos] == triggerChar) {
        return searchPos;
      }
      if (plainText[searchPos] == '\n') {
        break;
      }
      searchPos--;
    }

    return selectedTriggerPosition;
  }

  int _queryLengthFromTrigger(
    String plainText,
    int actualPosition,
    String query, {
    required int caretForFallback,
  }) {
    final queryEnd = actualPosition + 1 + query.length;
    if (actualPosition >= 0 &&
        queryEnd <= plainText.length &&
        plainText.substring(actualPosition + 1, queryEnd) == query) {
      return 1 + query.length;
    }

    final selectionOffset = caretForFallback;
    if (selectionOffset > actualPosition) {
      return selectionOffset - actualPosition;
    }

    return 1;
  }

  /// Ensure next typed character uses default style after selecting a token.
  void _resetTypingStyleAfterSelection() {
    controller.toggledStyle = const Style();
  }

  void _applyInlineStyleWithoutNotify(int offset, int length, Style style) {
    for (final attr in style.values) {
      if (!attr.isInline) continue;
      controller.formatText(
        offset,
        length,
        attr,
        shouldNotifyListeners: false,
      );
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

    for (final attr in config.tagStyle.values) {
      if (!attr.isInline || attr.value == null) continue;
      clearByKey[attr.key] = Attribute.clone(attr, null);
    }

    return clearByKey;
  }

  Iterable<Attribute> _tokenStyleClearAttributesForStyle(Style style) {
    final candidates = _tokenStyleClearCandidates();
    return style.attributes.keys
        .where(candidates.containsKey)
        .map((key) => candidates[key]!);
  }

  void _clearTagStyleFromTrailingSpace(int offset) {
    final style = controller.document.collectStyle(offset, 1);
    for (final attr in _tokenStyleClearAttributesForStyle(style)) {
      controller.formatText(
        offset,
        1,
        attr,
        shouldNotifyListeners: false,
      );
    }
  }

  bool handleKeyEvent(KeyEvent event) {
    // Keyboard navigation is handled by the overlay widget itself
    // This method can be extended if needed
    return false;
  }

  void dispose() {
    hideOverlay();
  }
}

/// Handler for @ character to trigger mention overlay
bool handleMentionTrigger(QuillController controller) {
  final selection = controller.selection;
  if (!selection.isCollapsed) return false;

  final plainText = controller.document.toPlainText();
  if (plainText.isEmpty || selection.baseOffset == 0) return false;

  // Check if @ was just typed
  final charBefore =
      selection.baseOffset > 0 ? plainText[selection.baseOffset - 1] : null;

  if (charBefore != '@') return false;

  // Check if there's a space or newline before @ (start of word)
  if (selection.baseOffset > 1) {
    final charBeforeAt = plainText[selection.baseOffset - 2];
    if (charBeforeAt != ' ' && charBeforeAt != '\n') {
      return false;
    }
  }

  return true;
}

/// Handler for # character to trigger tag overlay
bool handleTagTrigger(QuillController controller) {
  final selection = controller.selection;
  if (!selection.isCollapsed) return false;

  final plainText = controller.document.toPlainText();
  if (plainText.isEmpty || selection.baseOffset == 0) return false;

  // Check if # was just typed
  final charBefore =
      selection.baseOffset > 0 ? plainText[selection.baseOffset - 1] : null;

  if (charBefore != '#') return false;

  // Check if there's a space or newline before # (start of word)
  if (selection.baseOffset > 1) {
    final charBeforeHash = plainText[selection.baseOffset - 2];
    if (charBeforeHash != ' ' && charBeforeHash != '\n') {
      return false;
    }
  }

  return true;
}

/// Handler for $ character to trigger tag overlay
bool handleDollarTagTrigger(QuillController controller) {
  final selection = controller.selection;
  if (!selection.isCollapsed) return false;

  final plainText = controller.document.toPlainText();
  if (plainText.isEmpty || selection.baseOffset == 0) return false;

  // Check if $ was just typed
  final charBefore =
      selection.baseOffset > 0 ? plainText[selection.baseOffset - 1] : null;

  if (charBefore != '\$') return false;

  // Check if there's a space or newline before $ (start of word)
  if (selection.baseOffset > 1) {
    final charBeforeDollar = plainText[selection.baseOffset - 2];
    if (charBeforeDollar != ' ' && charBeforeDollar != '\n') {
      return false;
    }
  }

  return true;
}

/// Extract query text after @, #, or $
String extractQuery(QuillController controller, bool isMention,
    {String? tagTrigger}) {
  final selection = controller.selection;
  final plainText = controller.document.toPlainText();

  if (selection.baseOffset == 0) return '';

  var startPos = selection.baseOffset - 1;
  final triggerChar = isMention ? '@' : (tagTrigger ?? '#');

  // Find the trigger character
  while (startPos >= 0 && plainText[startPos] != triggerChar) {
    // For mentions and $ tags allow spaces in the query (names with spaces).
    // For # tags, a space ends the query.
    if ((!isMention && triggerChar == '#' && plainText[startPos] == ' ') ||
        plainText[startPos] == '\n') {
      return '';
    }
    startPos--;
  }

  if (startPos < 0 || plainText[startPos] != triggerChar) {
    return '';
  }

  // Extract text after trigger
  final query = plainText.substring(startPos + 1, selection.baseOffset);
  return query;
}
