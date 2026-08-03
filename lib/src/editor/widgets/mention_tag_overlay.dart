import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../common/utils/color.dart';

/// Represents a user mention item
class MentionItem {
  // Custom data for additional requirements

  const MentionItem({
    required this.id,
    required this.name,
    this.avatarUrl,
    this.customData,
  });
  final String id;
  final String name;
  final String? avatarUrl;
  final dynamic customData;

}

/// Represents a hashtag item
class TagItem {
  // Custom data for additional requirements

  const TagItem({
    required this.id,
    required this.name,
    this.count,
    this.customData,
    this.color,
  });
  final String id;
  final String name;
  final int? count;
  final dynamic customData;

  /// Optional hex color for the token when selected; falls back to
  /// [MentionTagConfig.defaultHashTagColor] or [MentionTagConfig.defaultDollarTagColor].
  final String? color;
}

/// Callback for fetching users based on query
typedef MentionSearchCallback = Future<List<MentionItem>> Function(
    String query);

/// Callback for fetching tags based on query
typedef TagSearchCallback = Future<List<TagItem>> Function(String query);

/// Builder for custom mention item widget
/// [customData] can be null if not needed
typedef MentionItemBuilder = Widget Function(
  BuildContext context,
  MentionItem item,
  bool isSelected,
  VoidCallback onTap,
  dynamic customData,
);

/// Builder for custom tag item widget
/// [customData] can be null if not needed
typedef TagItemBuilder = Widget Function(
  BuildContext context,
  TagItem item,
  bool isSelected,
  VoidCallback onTap,
  dynamic customData,
);

/// Builder for the "load more" indicator at the bottom of the list
typedef LoadMoreIndicatorBuilder = Widget Function(
  BuildContext context,
  bool isMention,
  String tagTrigger,
);

/// Overlay widget that shows mention/tag list above keyboard
class MentionTagOverlay extends StatefulWidget {
  const MentionTagOverlay({
    required this.query,
    required this.isMention,
    required this.onSelectMention,
    required this.onSelectTag,
    required this.mentionSearch,
    required this.tagSearch,
    required this.dollarSearch,
    this.maxHeight = 200,
    this.tagTrigger = '#',
    this.defaultMentionColor = '#FF0000',
    this.defaultHashTagColor = '#FF0000',
    this.defaultDollarTagColor = '#FF0000',
    this.onItemCountChanged,
    this.mentionItemBuilder,
    this.tagItemBuilder,
    this.customData,
    this.onLoadMoreMentions,
    this.onLoadMoreTags,
    this.onLoadMoreDollarTags,
    this.loadMoreIndicatorBuilder,
    this.suggestionListPadding = EdgeInsets.zero,
    this.decoration,
    super.key,
  });

  final String query;
  final bool isMention;
  final void Function(MentionItem) onSelectMention;
  final void Function(TagItem) onSelectTag;
  final MentionSearchCallback mentionSearch;
  final TagSearchCallback tagSearch;
  final TagSearchCallback dollarSearch;
  final double maxHeight;
  final String tagTrigger; // Tag trigger character (# or $)
  /// Default color for @mentions (e.g. '#FF0000'). Required.
  final String defaultMentionColor;

  /// Default color for #tags (e.g. '#FF0000'). Required.
  final String defaultHashTagColor;

  /// Default color for $ currency tags (e.g. '#FF0000'). Required.
  final String defaultDollarTagColor;
  final void Function(int)?
      onItemCountChanged; // Callback when item count changes
  final MentionItemBuilder?
      mentionItemBuilder; // Custom builder for mention items
  final TagItemBuilder? tagItemBuilder; // Custom builder for tag items
  final dynamic customData; // Custom data passed to builders
  final Future<List<MentionItem>> Function(
          String query, List<MentionItem> currentItems, int currentPage)?
      onLoadMoreMentions;
  final Future<List<TagItem>> Function(
          String query, List<TagItem> currentItems, int currentPage)?
      onLoadMoreTags;
  final Future<List<TagItem>> Function(
          String query, List<TagItem> currentItems, int currentPage)?
      onLoadMoreDollarTags;
  final LoadMoreIndicatorBuilder? loadMoreIndicatorBuilder;
  final EdgeInsetsGeometry suggestionListPadding;
  final BoxDecoration? decoration; // Custom decoration for the suggestion view

  @override
  State<MentionTagOverlay> createState() => _MentionTagOverlayState();
}

class _MentionTagOverlayState extends State<MentionTagOverlay> {
  List<MentionItem> _mentions = [];
  List<TagItem> _tags = [];
  bool _isLoading = false;
  bool _isLoadingMore = false; // Track if loading more items
  bool _hasMoreItems = true; // Track if there are more items to load
  int _currentPage = 0; // Track current page for pagination
  int _selectedIndex = 0;
  Timer? _searchDebounceTimer;
  Timer? _loadingIndicatorTimer; // Timer to delay showing loading indicator
  String _lastSearchedQuery = '';
  int _searchGeneration = 0;
  int _listVersion = 0; // Track list changes for animation
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _lastSearchedQuery = widget.query;
    _scrollController.addListener(_onScroll);
    _searchWithQuery(widget.query);
  }

  @override
  void dispose() {
    _searchDebounceTimer?.cancel();
    _loadingIndicatorTimer?.cancel();
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (!position.hasContentDimensions) return;

    // When shrink-wrapped content fits entirely in [maxScrollExtent], scrolling
    // never moves the viewport and listeners may not reveal "near bottom"; that
    // case is handled by [_scheduleViewportFillCheck] after data loads.

    final maxExtent = position.maxScrollExtent;
    if (maxExtent <= 0) return;

    if (position.pixels >= maxExtent - 100) {
      _loadMore();
    }
  }

  /// If the suggestion list fits without scrolling but more pages exist,
  /// automatically load pages until content overflows or the list exhausts.
  void _scheduleViewportFillCheck() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(_maybeLoadMoreForShortViewport());
    });
  }

  Future<void> _maybeLoadMoreForShortViewport() async {
    if (!mounted || _isLoadingMore || _isLoading || !_hasMoreItems) return;
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position;
    if (!position.hasContentDimensions) return;
    if (position.maxScrollExtent > 0) return;

    final canLoadMore = widget.isMention
        ? widget.onLoadMoreMentions != null
        : (widget.tagTrigger == '\$'
            ? widget.onLoadMoreDollarTags != null
            : widget.onLoadMoreTags != null);
    if (!canLoadMore) return;

    await _loadMore();
    if (!mounted) return;

    _scheduleViewportFillCheck();
  }

  Future<void> _loadMore() async {
    // Don't load more if already loading, no more items, or no callback provided
    if (_isLoadingMore || !_hasMoreItems) return;
    final query = widget.query;
    final isMentionLoad = widget.isMention;
    final tagTrigger = widget.tagTrigger;

    bool isCurrentLoad() {
      return mounted &&
          widget.query == query &&
          widget.isMention == isMentionLoad &&
          widget.tagTrigger == tagTrigger;
    }

    setState(() {
      _isLoadingMore = true;
    });

    try {
      if (isMentionLoad) {
        // Handle mentions
        if (widget.onLoadMoreMentions == null) {
          if (mounted) {
            setState(() {
              _isLoadingMore = false;
              _hasMoreItems = false;
            });
          }
          return;
        }

        final newItems = await widget.onLoadMoreMentions!(
            query, _mentions, _currentPage + 1);

        if (isCurrentLoad()) {
          setState(() {
            if (newItems.isEmpty) {
              _hasMoreItems = false;
            } else {
              // Append new items, avoiding duplicates
              final existingIds = _mentions
                  .map((e) => e.id)
                  .where((id) => id.isNotEmpty)
                  .toSet();
              final uniqueNewItems = newItems
                  .where(
                    (item) => item.id.isEmpty || !existingIds.contains(item.id),
                  )
                  .toList();
              _mentions = [..._mentions, ...uniqueNewItems];
              _currentPage++;
              // If we got fewer items than requested, assume no more items
              _hasMoreItems = uniqueNewItems.isNotEmpty;
            }
            _isLoadingMore = false;
            _listVersion++; // Trigger animation
          });

          // The overlay owns pagination state; its setState above is enough to
          // render appended rows. Notifying the wrapper here can recreate the
          // overlay widget during pagination and leave the visible list stale.
        }
      } else {
        // Handle tags
        final loadMoreCallback = tagTrigger == '\$'
            ? widget.onLoadMoreDollarTags
            : widget.onLoadMoreTags;

        if (loadMoreCallback == null) {
          if (mounted) {
            setState(() {
              _isLoadingMore = false;
              _hasMoreItems = false;
            });
          }
          return;
        }

        final newItems = await loadMoreCallback(query, _tags, _currentPage + 1);

        if (isCurrentLoad()) {
          setState(() {
            if (newItems.isEmpty) {
              _hasMoreItems = false;
            } else {
              // Append new items, avoiding duplicates
              final existingIds =
                  _tags.map((e) => e.id).where((id) => id.isNotEmpty).toSet();
              final uniqueNewItems = newItems
                  .where(
                    (item) => item.id.isEmpty || !existingIds.contains(item.id),
                  )
                  .toList();
              _tags = [..._tags, ...uniqueNewItems];
              _currentPage++;
              // If we got fewer items than requested, assume no more items
              _hasMoreItems = uniqueNewItems.isNotEmpty;
            }
            _isLoadingMore = false;
            _listVersion++; // Trigger animation
          });

          // The overlay owns pagination state; its setState above is enough to
          // render appended rows. Notifying the wrapper here can recreate the
          // overlay widget during pagination and leave the visible list stale.
        }
      }
    } catch (e) {
      if (isCurrentLoad()) {
        setState(() {
          _isLoadingMore = false;
          _hasMoreItems = false; // Stop trying if error occurs
        });
      }
    }
  }

  @override
  void didUpdateWidget(MentionTagOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only search if query actually changed and we haven't already searched for this query
    // Always debounce-search when [query] changes. Do not skip because
    // widget.query == _lastSearchedQuery: after load-more + an intermediate
    // query, returning to the same string would leave _lastSearchedQuery equal
    // to the new query while _tags/_mentions still reflect the intermediate
    // search, so taps would not apply the selected item correctly.
    if (oldWidget.query != widget.query) {
      _selectedIndex = 0;
      // Debounce search to avoid rapid reloads
      _searchDebounceTimer?.cancel();
      final queryToSearch = widget.query; // Capture current query
      _searchDebounceTimer = Timer(const Duration(milliseconds: 150), () {
        // Only search if query hasn't changed since we scheduled this search
        if (mounted && widget.query == queryToSearch) {
          _lastSearchedQuery = queryToSearch;
          _searchWithQuery(queryToSearch);
        }
      });
    }
  }

  /// Refresh the list by re-searching with the current query
  /// This is useful when the underlying data source has changed
  /// Call this method to force an update even if the query hasn't changed
  void refresh() {
    _lastSearchedQuery = ''; // Reset to force refresh
    _searchDebounceTimer?.cancel();
    _searchWithQuery(widget.query);
  }

  Future<void> _searchWithQuery(String query) async {
    // Allow empty query to show all results when trigger is first typed
    // This enables showing all data immediately when user types #, @, or $
    final generation = ++_searchGeneration;
    final isMentionSearch = widget.isMention;
    final tagTrigger = widget.tagTrigger;

    bool isCurrentSearch() {
      return mounted &&
          generation == _searchGeneration &&
          widget.query == query &&
          widget.isMention == isMentionSearch &&
          widget.tagTrigger == tagTrigger;
    }

    // Reset pagination state when searching
    _currentPage = 0;
    _hasMoreItems = true;
    _isLoadingMore = false;

    // After load-more the list can be scrolled far down; a new search replaces
    // items with a shorter list while keeping the old offset, which breaks taps
    // and can spuriously fire load-more. Snap back to the top for each search.
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }

    // Cancel any existing loading indicator timer
    _loadingIndicatorTimer?.cancel();

    // Only show loading indicator if search takes longer than 150ms
    // This prevents flickering for fast local searches
    _loadingIndicatorTimer = Timer(const Duration(milliseconds: 150), () {
      if (isCurrentSearch()) {
        setState(() {
          _isLoading = true;
        });
      }
    });

    try {
      if (isMentionSearch) {
        final results = await widget.mentionSearch(query);
        if (!isCurrentSearch()) return;
        // Cancel loading indicator timer since we got results quickly
        _loadingIndicatorTimer?.cancel();
        _updateMentionsList(results);
        // Check if we should enable load more based on results
        if (widget.onLoadMoreMentions != null && results.isNotEmpty) {
          _hasMoreItems = true; // Assume there might be more
        } else {
          _hasMoreItems = false;
        }
      } else {
        // Use dollarSearch for $ tags, tagSearch for # tags
        final results = tagTrigger == '\$'
            ? await widget.dollarSearch(query)
            : await widget.tagSearch(query);
        if (!isCurrentSearch()) return;
        // Cancel loading indicator timer since we got results quickly
        _loadingIndicatorTimer?.cancel();
        _updateTagsList(results);
        // Check if we should enable load more based on results
        final loadMoreCallback = tagTrigger == '\$'
            ? widget.onLoadMoreDollarTags
            : widget.onLoadMoreTags;
        if (loadMoreCallback != null && results.isNotEmpty) {
          _hasMoreItems = true; // Assume there might be more
        } else {
          _hasMoreItems = false;
        }
      }
    } catch (e) {
      if (!isCurrentSearch()) return;
      _loadingIndicatorTimer?.cancel();
      setState(() {
        _isLoading = false;
        _hasMoreItems = false;
      });
    }
  }

  // Incrementally update mentions list - preserve existing items, add new ones, remove old ones
  void _updateMentionsList(List<MentionItem> newResults) {
    // Cancel loading indicator timer since we have results
    _loadingIndicatorTimer?.cancel();

    // Create maps for quick lookup
    final oldMap = {
      for (final item in _mentions)
        if (item.id.isNotEmpty) item.id: item,
    };
    final newIds =
        newResults.map((e) => e.id).where((id) => id.isNotEmpty).toSet();

    // Find items that need to be removed (in old but not in new)
    final toRemove = _mentions
        .where((item) => item.id.isNotEmpty && !newIds.contains(item.id))
        .toList();

    // Find items that need to be added (in new but not in old)
    final toAdd = newResults
        .where((item) => item.id.isEmpty || !oldMap.containsKey(item.id))
        .toList();

    // Only update if there are actual changes
    if (toRemove.isEmpty && toAdd.isEmpty) {
      // Check if any existing items need updates
      var needsUpdate = false;
      for (final newItem in newResults) {
        final oldItem = oldMap[newItem.id];
        if (oldItem != null && oldItem != newItem) {
          needsUpdate = true;
          break;
        }
      }
      if (!needsUpdate) {
        setState(() {
          _isLoading = false;
        });
        widget.onItemCountChanged?.call(_mentions.length);
        _scheduleViewportFillCheck();
        return; // No changes needed
      }
    }

    setState(() {
      // Remove items that are no longer in results
      _mentions.removeWhere((item) => toRemove.contains(item));

      // Build new list maintaining order from newResults.
      // Always prefer the newest data (e.g. updated colors, names, counts)
      // instead of keeping stale items from the previous list.
      final resultList = <MentionItem>[];
      final existingIds = <String>{};

      for (final newItem in newResults) {
        if (newItem.id.isNotEmpty && existingIds.contains(newItem.id)) {
          continue;
        }
        resultList.add(newItem);
        if (newItem.id.isNotEmpty) {
          existingIds.add(newItem.id);
        }
      }

      _mentions = resultList;
      _isLoading = false;
      _listVersion++; // Increment to trigger animation

      // Preserve selected index if still valid, otherwise reset to 0
      if (_selectedIndex >= _mentions.length) {
        _selectedIndex = 0;
      }
    });

    widget.onItemCountChanged?.call(_mentions.length);
    _scheduleViewportFillCheck();
  }

  // Incrementally update tags list - preserve existing items, add new ones, remove old ones
  void _updateTagsList(List<TagItem> newResults) {
    // Cancel loading indicator timer since we have results
    _loadingIndicatorTimer?.cancel();
    // Always rebuild from fresh search results so pagination -> search cannot
    // keep stale ordering/content from a previous query.
    final resultList = <TagItem>[];
    final existingIds = <String>{};
    for (final newItem in newResults) {
      if (newItem.id.isNotEmpty && existingIds.contains(newItem.id)) {
        continue;
      }
      resultList.add(newItem);
      if (newItem.id.isNotEmpty) {
        existingIds.add(newItem.id);
      }
    }

    setState(() {
      _tags = resultList;
      _isLoading = false;
      _listVersion++; // Increment to trigger animation

      // Preserve selected index if still valid, otherwise reset to 0
      if (_selectedIndex >= _tags.length) {
        _selectedIndex = 0;
      }
    });

    widget.onItemCountChanged?.call(_tags.length);
    _scheduleViewportFillCheck();
  }

  void _selectMentionItem(MentionItem item, int index) {
    if (!mounted) return;
    setState(() {
      _selectedIndex = index;
    });
    widget.onSelectMention(item);
  }

  void _selectTagItem(TagItem item, int index) {
    if (!mounted) return;
    setState(() {
      _selectedIndex = index;
    });
    widget.onSelectTag(item);
  }

  void _selectHighlightedItem() {
    if (widget.isMention && _selectedIndex < _mentions.length) {
      widget.onSelectMention(_mentions[_selectedIndex]);
    } else if (!widget.isMention && _selectedIndex < _tags.length) {
      widget.onSelectTag(_tags[_selectedIndex]);
    }
  }

  void _moveSelection(int delta) {
    final maxIndex = widget.isMention ? _mentions.length : _tags.length;
    if (maxIndex == 0) return;

    setState(() {
      _selectedIndex = (_selectedIndex + delta).clamp(0, maxIndex - 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isEmpty =
        (widget.isMention ? _mentions.isEmpty : _tags.isEmpty) && !_isLoading;

    // Show loading indicator when searching
    // if (_isLoading) {
    //   return Container(
    //     height: widget.maxHeight,
    //     decoration: BoxDecoration(
    //       color: Theme.of(context).cardColor,
    //       borderRadius: BorderRadius.circular(8),
    //       border: Border.all(
    //         color: Theme.of(context).dividerColor,
    //       ),
    //     ),
    //     child: const Center(
    //       child: Padding(
    //         padding: EdgeInsets.all(16.0),
    //         child: CircularProgressIndicator(),
    //       ),
    //     ),
    //   );
    // }

    // Hide when the search has no results. This avoids laying out an empty
    // suggestion list for configs that intentionally return no items.
    if (isEmpty) {
      return const SizedBox.shrink();
    }

    // Show empty state message if no results found
    // if (isEmpty) {
    //   return Container(
    //     height: widget.maxHeight,
    //     decoration: BoxDecoration(
    //       color: Theme.of(context).cardColor,
    //       borderRadius: BorderRadius.circular(8),
    //       border: Border.all(
    //         color: Theme.of(context).dividerColor,
    //       ),
    //     ),
    //     child: Padding(
    //       padding: const EdgeInsets.all(16.0),
    //       child: Center(
    //         child: Text(
    //           widget.isMention ? 'No users found' : 'No tags found',
    //           style: Theme.of(context).textTheme.bodyMedium,
    //         ),
    //       ),
    //     ),
    //   );
    // }

    // Default decoration if none provided
    final defaultDecoration = BoxDecoration(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(
        color: Theme.of(context).dividerColor,
      ),
    );
    final decoration = widget.decoration ?? defaultDecoration;

    return ClipRRect(
      borderRadius: decoration.borderRadius ?? BorderRadius.zero,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 100),
        transitionBuilder: (child, animation) {
          return FadeTransition(opacity: animation, child: child);
        },
        child: Container(
          decoration: decoration,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: widget.maxHeight),
            child: widget.isMention
                ? ListView.builder(
                    key: const PageStorageKey('mentions_list'),
                    controller: _scrollController,
                    padding: widget.suggestionListPadding,
                    itemCount: _mentions.length + (_isLoadingMore ? 1 : 0),
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      // Show loading indicator at the bottom
                      if (index == _mentions.length) {
                        return widget.loadMoreIndicatorBuilder?.call(
                              context,
                              true,
                              widget.tagTrigger,
                            ) ??
                            const SizedBox(
                                child: Center(
                                    child: Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2))));
                      }
                      final isSelected = index == _selectedIndex;
                      return _buildAnimatedItem(
                        context,
                        index,
                        isSelected,
                        key: ValueKey(
                          'mention-$_listVersion-$index-${_mentions[index].id}-${_mentions[index].name}',
                        ),
                      );
                    })
                : ListView.builder(
                    key: const PageStorageKey('tags_list'),
                    controller: _scrollController,
                    padding: widget.suggestionListPadding,
                    itemCount: _tags.length + (_isLoadingMore ? 1 : 0),
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      // Show loading indicator at the bottom
                      if (index == _tags.length) {
                        return widget.loadMoreIndicatorBuilder?.call(
                              context,
                              false,
                              widget.tagTrigger,
                            ) ??
                            const Center(
                                child: Padding(
                                    padding: EdgeInsets.all(8),
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2)));
                      }
                      final isSelected = index == _selectedIndex;
                      return _buildAnimatedItem(
                        context,
                        index,
                        isSelected,
                        key: ValueKey(
                          'tag-$_listVersion-$index-${_tags[index].id}-${_tags[index].name}',
                        ),
                      );
                    },
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedItem(BuildContext context, int index, bool isSelected,
      {Key? key}) {
    // Use AnimatedOpacity for smooth fade-in when items appear
    // The stable key ensures Flutter reuses widgets and only animates new items
    return AnimatedOpacity(
      key: key,
      opacity: 1.0,
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOut,
      child: _buildItem(context, index, isSelected, key: key),
    );
  }

  Widget _buildItem(BuildContext context, int index, bool isSelected,
      {Key? key}) {
    if (widget.isMention) {
      final mention = _mentions[index];

      // Use custom builder if provided
      if (widget.mentionItemBuilder != null) {
        return widget.mentionItemBuilder!(
          context,
          mention,
          isSelected,
          () {
            _selectMentionItem(mention, index);
          },
          widget.customData,
        );
      }

      // Default mention item builder
      final mentionColor = _parseTagColor(widget.defaultMentionColor, context);
      return InkWell(
        key: key,
        onTap: () {
          _selectMentionItem(mention, index);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          color: isSelected
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          //  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              if (mention.avatarUrl != null)
                CircleAvatar(
                  radius: 16,
                  backgroundImage: NetworkImage(mention.avatarUrl!),
                )
              else
                CircleAvatar(
                  radius: 16,
                  backgroundColor:
                      mentionColor ?? Theme.of(context).colorScheme.primary,
                  child: Text(
                    mention.name.isNotEmpty
                        ? mention.name[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '@${mention.name}',
                  style: mentionColor != null
                      ? TextStyle(
                          color: mentionColor,
                          fontSize:
                              Theme.of(context).textTheme.bodyLarge?.fontSize,
                          fontWeight:
                              Theme.of(context).textTheme.bodyLarge?.fontWeight,
                        )
                      : Theme.of(context).textTheme.bodyLarge,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      final tag = _tags[index];

      // Use custom builder if provided
      if (widget.tagItemBuilder != null) {
        return widget.tagItemBuilder!(
          context,
          tag,
          isSelected,
          () {
            _selectTagItem(tag, index);
          },
          widget.customData,
        );
      }

      // Default tag item builder
      final defaultTagColor = widget.tagTrigger == '\$'
          ? widget.defaultDollarTagColor
          : widget.defaultHashTagColor;
      final tagColor = _parseTagColor(defaultTagColor, context);
      return InkWell(
        key: key,
        onTap: () {
          _selectTagItem(tag, index);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          color: isSelected
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(
                Icons.tag,
                size: 20,
                color: tagColor ?? Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  tag.name,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: tagColor,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (tag.count != null)
                Text(
                  '${tag.count}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
            ],
          ),
        ),
      );
    }
  }

  /// Handle keyboard navigation
  bool handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        _moveSelection(1);
        return true;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        _moveSelection(-1);
        return true;
      } else if (event.logicalKey == LogicalKeyboardKey.enter ||
          event.logicalKey == LogicalKeyboardKey.tab) {
        _selectHighlightedItem();
        return true;
      } else if (event.logicalKey == LogicalKeyboardKey.escape) {
        // Close overlay - handled by parent
        return false;
      }
    }
    return false;
  }

  bool get hasItems =>
      widget.isMention ? _mentions.isNotEmpty : _tags.isNotEmpty;

  String _formatTagDisplay(String tagName, String trigger) {
    if (trigger == '\$') {
      // Format as currency if numeric
      final numericValue = double.tryParse(tagName);
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

        return '\$$formattedInteger${decimalPart.isNotEmpty ? '.$decimalPart' : ''}';
      } else {
        // Not numeric, just use name as is
        return '\$$tagName';
      }
    } else {
      // For # tags, use as is
      return '$trigger$tagName';
    }
  }

  Color? _parseTagColor(String? colorString, BuildContext context) {
    if (colorString == null || colorString.isEmpty) return null;

    try {
      // Use the existing stringToColor utility
      final color = stringToColor(colorString, null, null);
      return color;
    } catch (e) {
      // If parsing fails, try to parse as hex directly
      try {
        var hex = colorString.trim();
        if (!hex.startsWith('#')) {
          hex = '#$hex';
        }
        if (hex.length == 7) {
          // 6-digit hex, add alpha
          hex = 'ff${hex.substring(1)}';
        } else if (hex.length == 4) {
          // 3-digit hex, expand and add alpha
          final r = hex[1];
          final g = hex[2];
          final b = hex[3];
          hex = 'ff$r$r$g$g$b$b';
        }
        final val = int.parse(hex, radix: 16);
        return Color(val);
      } catch (e2) {
        // If all parsing fails, return null to use default color
        return null;
      }
    }
  }
}
