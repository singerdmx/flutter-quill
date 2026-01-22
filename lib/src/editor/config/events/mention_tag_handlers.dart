import 'dart:async';

import 'package:flutter/material.dart';

import '../../../controller/quill_controller.dart';
import '../../../document/attribute.dart';
import '../../widgets/mention_tag_overlay.dart';
import '../mention_tag_config.dart';

/// State for managing mention/tag overlay
class MentionTagState {
  MentionTagState({
    required this.config,
    required this.controller,
    this.onVisibilityChanged,
  });

  final MentionTagConfig config;
  final QuillController controller;
  final void Function(bool visible, String query, bool isMention, String tagTrigger)? onVisibilityChanged;
  MentionTagOverlay? overlayWidget;
  final ValueKey _overlayKey = const ValueKey('mention_tag_overlay'); // Stable key to preserve widget state
  String currentQuery = '';
  bool isMention = false;
  int triggerPosition = -1;
  String tagTriggerChar = '#'; // Track which tag trigger was used (# or $)
  int _itemCount = 0; // Track number of items in overlay
  Timer? _searchDebounceTimer; // Debounce timer for search
  String? _pendingQuery; // Query waiting to be applied after debounce


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
      decoration: config.decoration,
      onItemCountChanged: (count) {
        _itemCount = count;
      },
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
          decoration: config.decoration,
          onItemCountChanged: (count) {
            _itemCount = count;
          },
        );
        // Notify visibility change to ensure wrapper rebuilds with updated widget
        // Use a flag to indicate this is just an update, not a show/hide
        onVisibilityChanged?.call(true, queryToUpdate, isMention, tagTriggerChar);
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
        decoration: config.decoration,
        onItemCountChanged: (count) {
          _itemCount = count;
        },
      );
      onVisibilityChanged?.call(true, currentQuery, isMention, tagTriggerChar);
    }
  }

  void _handleMentionSelected(MentionItem item) {
    if (triggerPosition == -1) return;

    // Hide overlay first with smooth animation
    hideOverlay();

    // Find the actual position in document
    final plainText = controller.document.toPlainText();
    var actualPosition = triggerPosition;

    // Search backwards from cursor to find @
    var searchPos = controller.selection.baseOffset - 1;
    while (searchPos >= 0 && searchPos < plainText.length) {
      if (plainText[searchPos] == '@') {
        actualPosition = searchPos;
        break;
      }
      if (plainText[searchPos] == ' ' || plainText[searchPos] == '\n') {
        break;
      }
      searchPos--;
    }

    // Calculate how much to delete
    final deleteLength = controller.selection.baseOffset - actualPosition;

    // Insert mention text with attribute after a small delay to allow animation
    Future.delayed(const Duration(milliseconds: 100), () {
      final mentionText = '@${item.name}';
      controller.replaceText(
        actualPosition,
        deleteLength,
        mentionText,
        TextSelection.collapsed(offset: actualPosition + mentionText.length),
      );

      // Apply mention attribute
      controller.formatText(
        actualPosition,
        mentionText.length,
        MentionAttribute(value: {
          'id': item.id,
          'name': item.name,
          if (item.avatarUrl != null) 'avatarUrl': item.avatarUrl,
          if (item.color != null) 'color': item.color,
        }),
      );

      config.onMentionSelected?.call(item);
    });
  }

  void _handleTagSelected(TagItem item) {
    if (triggerPosition == -1) return;

    // Hide overlay first with smooth animation
    hideOverlay();

    // Find the actual position in document
    final plainText = controller.document.toPlainText();
    var actualPosition = triggerPosition;

    // Search backwards from cursor to find # or $
    var searchPos = controller.selection.baseOffset - 1;
    String? triggerChar;
    while (searchPos >= 0 && searchPos < plainText.length) {
      if (plainText[searchPos] == '#' || plainText[searchPos] == '\$') {
        actualPosition = searchPos;
        triggerChar = plainText[searchPos];
        break;
      }
      if (plainText[searchPos] == ' ' || plainText[searchPos] == '\n') {
        break;
      }
      searchPos--;
    }

    // Use the detected trigger character, default to # if not found
    triggerChar ??= '#';

    // Calculate how much to delete
    final deleteLength = controller.selection.baseOffset - actualPosition;

    // Format tag text - for $ tags, format as currency if name is numeric
    String tagText;
    if (triggerChar == '\$') {
      // Try to parse as number and format as currency
      final numericValue = double.tryParse(item.name);
      if (numericValue != null) {
        // Format with commas for thousands
        final formattedValue = numericValue.toStringAsFixed(
            numericValue.truncateToDouble() == numericValue ? 0 : 2);
        final parts = formattedValue.split('.');
        final integerPart = parts[0];
        final decimalPart = parts.length > 1 ? parts[1] : '';

        // Add commas for thousands
        String formattedInteger = '';
        for (int i = integerPart.length - 1; i >= 0; i--) {
          if ((integerPart.length - 1 - i) % 3 == 0 &&
              i < integerPart.length - 1) {
            formattedInteger = ',$formattedInteger';
          }
          formattedInteger = integerPart[i] + formattedInteger;
        }

        tagText =
            '\$$formattedInteger${decimalPart.isNotEmpty ? '.$decimalPart' : ''}';
      } else {
        // Not numeric, just use name as is
        tagText = '\$${item.name}';
      }
    } else {
      // For # tags, use as is
      tagText = '$triggerChar${item.name}';
    }

    // Insert tag text with attribute after a small delay to allow animation
    Future.delayed(const Duration(milliseconds: 100), () {
      controller.replaceText(
        actualPosition,
        deleteLength,
        tagText,
        TextSelection.collapsed(offset: actualPosition + tagText.length),
      );

      // Apply tag attribute - use CurrencyAttribute for $ tags, TagAttribute for # tags
      if (triggerChar == '\$') {
        controller.formatText(
          actualPosition,
          tagText.length,
          CurrencyAttribute(value: {
            'id': item.id,
            'name': item.name,
            if (item.count != null) 'count': item.count,
            if (item.color != null) 'color': item.color,
          }),
        );
      } else {
        controller.formatText(
          actualPosition,
          tagText.length,
          TagAttribute(value: {
            'id': item.id,
            'name': item.name,
            if (item.count != null) 'count': item.count,
            if (item.color != null) 'color': item.color,
          }),
        );
      }

      config.onTagSelected?.call(item);
    });
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
    if (plainText[startPos] == ' ' || plainText[startPos] == '\n') {
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
