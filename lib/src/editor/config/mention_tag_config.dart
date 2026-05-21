import 'package:flutter/material.dart';

import '../../document/style.dart';
import '../widgets/mention_tag_overlay.dart';

/// Configuration for mention and tag functionality
@immutable
class MentionTagConfig {
  const MentionTagConfig({
    required this.mentionSearch,
    required this.tagSearch,
    required this.dollarSearch,
    this.maxHeight = 200,
    this.itemHeight = 48,
    this.appendSpaceAfterSelection = true,
    this.defaultMentionColor = '#FF0000',
    this.defaultHashTagColor = '#FF0000',
    this.defaultDollarTagColor = '#FF0000',
    this.tagStyle = const Style(),
    this.onMentionSelected,
    this.onTagSelected,
    this.mentionItemBuilder,
    this.tagItemBuilder,
    this.customData,
    this.onLoadMoreMentions,
    this.onLoadMoreTags,
    this.onLoadMoreDollarTags,
    this.loadMoreIndicatorBuilder,
    this.suggestionListPadding = EdgeInsets.zero,
    this.decoration,
    this.onTagTypingChanged,
  });

  /// Optional callback invoked when the user enters or leaves "tag typing" mode.
  /// Called with [true] when the user is typing a tag or mention (e.g. after @, #, or \$)
  /// and the suggestion overlay is active; called with [false] when they are not.
  /// Use for UI (e.g. hide toolbar when [true]). The editor scrolls automatically so the
  /// cursor stays above the suggestion overlay; you do not need to trigger scroll here.
  final void Function(bool isTypingTag)? onTagTypingChanged;

  /// Callback to search for users when @ is typed
  final MentionSearchCallback mentionSearch;

  /// Callback to search for tags when # is typed
  final TagSearchCallback tagSearch;

  /// Callback to search for currency tags when $ is typed
  final TagSearchCallback dollarSearch;

  /// Maximum height of the mention/tag overlay
  final double maxHeight;

  /// Height of each item in the overlay
  final double itemHeight;

  /// Whether to append a trailing space when selecting a mention/tag.
  /// This keeps typing natural after an item is inserted from suggestions.
  final bool appendSpaceAfterSelection;

  /// Default color for @mentions (e.g. '#FF0000'). Required.
  final String defaultMentionColor;

  /// Default color for #tags (e.g. '#FF0000'). Required.
  final String defaultHashTagColor;

  /// Default color for $ currency tags (e.g. '#FF0000'). Required.
  final String defaultDollarTagColor;

  /// Inline style applied to @mentions, #tags, and $tags inside the editor.
  ///
  /// Example: `Style.attr({Attribute.bold.key: Attribute.bold})`.
  final Style tagStyle;

  /// Optional callback when a mention is selected
  final void Function(MentionItem)? onMentionSelected;

  /// Optional callback when a tag is selected
  final void Function(TagItem)? onTagSelected;

  /// Optional custom builder for mention items
  /// If provided, this will be used instead of the default mention item widget
  final MentionItemBuilder? mentionItemBuilder;

  /// Optional custom builder for tag items
  /// If provided, this will be used instead of the default tag item widget
  final TagItemBuilder? tagItemBuilder;

  /// Optional custom data that can be passed to builders
  /// This allows users to pass additional context or data for their custom requirements
  final dynamic customData;

  /// Optional callback to load more mentions when user scrolls to bottom
  /// Parameters: (query, currentItems, currentPage)
  /// Should return a list of new items to append, or empty list if no more items
  final Future<List<MentionItem>> Function(String query, List<MentionItem> currentItems, int currentPage)? onLoadMoreMentions;

  /// Optional callback to load more tags when user scrolls to bottom
  /// Parameters: (query, currentItems, currentPage)
  /// Should return a list of new items to append, or empty list if no more items
  final Future<List<TagItem>> Function(String query, List<TagItem> currentItems, int currentPage)? onLoadMoreTags;

  /// Optional callback to load more dollar tags when user scrolls to bottom
  /// Parameters: (query, currentItems, currentPage)
  /// Should return a list of new items to append, or empty list if no more items
  final Future<List<TagItem>> Function(String query, List<TagItem> currentItems, int currentPage)? onLoadMoreDollarTags;

  /// Optional builder for the "load more" indicator at the bottom of the list.
  /// If not provided, a default circular progress indicator is shown.
  final Widget Function(BuildContext context, bool isMention, String tagTrigger)? loadMoreIndicatorBuilder;

  /// Padding for the suggestion list content.
  final EdgeInsetsGeometry suggestionListPadding;

  /// Optional decoration for the suggestion overlay view
  /// If not provided, defaults to card color with rounded corners and border
  final BoxDecoration? decoration;
}
