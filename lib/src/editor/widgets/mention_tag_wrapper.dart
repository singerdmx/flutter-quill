import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../controller/quill_controller.dart';
import '../../document/document.dart';
import '../../document/structs/doc_change.dart';
import '../config/events/mention_tag_handlers.dart';
import '../config/mention_tag_config.dart';
import '../config/mention_tag_controller.dart';

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

class _MentionTagWrapperState extends State<MentionTagWrapper> {
  MentionTagState? _mentionTagState;
  StreamSubscription<DocChange>? _changeSubscription;
  bool _isOverlayVisible = false;
  String _currentQuery = '';
  bool _isMention = false;
  String _tagTrigger = '#';

  @override
  void initState() {
    super.initState();
    _mentionTagState = MentionTagState(
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
            });
          }
        });
      },
    );

    // Set up the refresh callback if controller is provided
    widget.mentionTagController?.setRefreshCallback(() {
      refreshSuggestionList();
    });

    // Listen to document changes to detect @, #, and $ triggers
    _changeSubscription = widget.controller.document.changes.listen((change) {
      if (change.source == ChangeSource.local) {
        _checkForMentionOrTag();
      }
    });
  }

  @override
  void dispose() {
    _changeSubscription?.cancel();
    _mentionTagState?.dispose();
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

    if (mentionResult != null) {
      // We're in a mention context
      final mentionQuery = mentionResult.query;
      final mentionPosition = mentionResult.position;
      if (_isOverlayVisible && _isMention) {
        _mentionTagState?.updateQuery(mentionQuery);
      } else {
        _showOverlay(true, mentionPosition, mentionQuery);
      }
      return;
    }

    // Check for # tag context
    if (tagHashResult != null) {
      // We're in a # tag context
      final tagQuery = tagHashResult.query;
      final tagPosition = tagHashResult.position;
      if (_isOverlayVisible && !_isMention && _tagTrigger == '#') {
        _mentionTagState?.updateQuery(tagQuery);
      } else {
        _showOverlay(false, tagPosition, tagQuery, tagTrigger: '#');
      }
      return;
    }

    // Check for $ tag context
    if (tagDollarResult != null) {
      // We're in a $ tag context
      final tagQuery = tagDollarResult.query;
      final tagPosition = tagDollarResult.position;
      if (_isOverlayVisible && !_isMention && _tagTrigger == '\$') {
        _mentionTagState?.updateQuery(tagQuery);
      } else {
        _showOverlay(false, tagPosition, tagQuery, tagTrigger: '\$');
      }
      return;
    }

    // Not in any mention/tag context, hide overlay if it exists
    if (_isOverlayVisible) {
      _hideOverlay();
    }
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
      if (plainText[pos] == ' ' || plainText[pos] == '\n') {
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

  void _showOverlay(bool isMention, int position, String query,
      {String? tagTrigger}) {
    if (!mounted) return;

    _mentionTagState?.showOverlay(isMention, position, query,
        tagTrigger: tagTrigger ?? '#');
  }

  void _hideOverlay() {
    _mentionTagState?.hideOverlay();
  }

  /// Refresh the suggestion list when data changes
  /// Call this method when your data source has been updated
  void refreshSuggestionList() {
    _mentionTagState?.refreshList();
  }

  @override
  Widget build(BuildContext context) {
    final overlayWidget = _mentionTagState?.overlayWidget;

    return KeyboardListener(
        focusNode: FocusNode(),
        onKeyEvent: (event) {
          if (_mentionTagState?.handleKeyEvent(event) == true) {
            return;
          }
        },
        child: Column(children: [
          // Editor widget - takes available space
          Expanded(child: widget.child),
          // Show suggestion list below editor when visible with smooth animation
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (Widget child, Animation<double> animation) {
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
        ]));
  }
}
