import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../common/utils/color.dart';

/// Represents a user mention item
class MentionItem { // Custom data for additional requirements

  const MentionItem({
    required this.id,
    required this.name,
    this.avatarUrl,
    this.color,
    this.customData,
  });
  final String id;
  final String name;
  final String? avatarUrl;
  final String? color; // Color as hex string (e.g., "#FF5733") or color name
  final dynamic customData;
}

/// Represents a hashtag item
class TagItem { // Custom data for additional requirements

  const TagItem({
    required this.id,
    required this.name,
    this.count,
    this.color,
    this.customData,
  });
  final String id;
  final String name;
  final int? count;
  final String? color; // Color as hex string (e.g., "#FF5733") or color name
  final dynamic customData;
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
    this.onItemCountChanged,
    this.mentionItemBuilder,
    this.tagItemBuilder,
    this.customData,
    this.onLoadMoreMentions,
    this.onLoadMoreTags,
    this.onLoadMoreDollarTags,
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
    _scrollController..removeListener(_onScroll)
    ..dispose();
    super.dispose();
  }

  void _onScroll() {
    // Check if user scrolled near the bottom (within 100px)
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 100) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    // Don't load more if already loading, no more items, or no callback provided
    if (_isLoadingMore || !_hasMoreItems) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      if (widget.isMention) {
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
            widget.query, _mentions, _currentPage + 1);

        if (mounted) {
          setState(() {
            if (newItems.isEmpty) {
              _hasMoreItems = false;
            } else {
              // Append new items, avoiding duplicates
              final existingIds = _mentions.map((e) => e.id).toSet();
              final uniqueNewItems = newItems
                  .where((item) => !existingIds.contains(item.id))
                  .toList();
              _mentions.addAll(uniqueNewItems);
              _currentPage++;
              // If we got fewer items than requested, assume no more items
              _hasMoreItems = uniqueNewItems.isNotEmpty;
            }
            _isLoadingMore = false;
            _listVersion++; // Trigger animation
          });

          widget.onItemCountChanged?.call(_mentions.length);
        }
      } else {
        // Handle tags
        final loadMoreCallback = widget.tagTrigger == '\$'
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

        final newItems =
            await loadMoreCallback(widget.query, _tags, _currentPage + 1);

        if (mounted) {
          setState(() {
            if (newItems.isEmpty) {
              _hasMoreItems = false;
            } else {
              // Append new items, avoiding duplicates
              final existingIds = _tags.map((e) => e.id).toSet();
              final uniqueNewItems = newItems
                  .where((item) => !existingIds.contains(item.id))
                  .toList();
              _tags.addAll(uniqueNewItems);
              _currentPage++;
              // If we got fewer items than requested, assume no more items
              _hasMoreItems = uniqueNewItems.isNotEmpty;
            }
            _isLoadingMore = false;
            _listVersion++; // Trigger animation
          });

          widget.onItemCountChanged?.call(_tags.length);
        }
      }
    } catch (e) {
      if (mounted) {
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
    // Check if search callbacks changed (data source updated)
    final searchCallbacksChanged = widget.isMention
        ? (oldWidget.mentionSearch != widget.mentionSearch)
        : (widget.tagTrigger == '\$'
            ? (oldWidget.dollarSearch != widget.dollarSearch)
            : (oldWidget.tagSearch != widget.tagSearch));

    // If search callbacks changed, refresh the list immediately
    if (searchCallbacksChanged) {
      _lastSearchedQuery = ''; // Reset to force refresh
      _searchDebounceTimer?.cancel();
      _searchWithQuery(widget.query);
      return;
    }

    // Only search if query actually changed and we haven't already searched for this query
    if (oldWidget.query != widget.query && widget.query != _lastSearchedQuery) {
      _selectedIndex = 0;
      // Debounce search to avoid rapid reloads
      _searchDebounceTimer?.cancel();
      final queryToSearch = widget.query; // Capture current query
      _searchDebounceTimer = Timer(const Duration(milliseconds: 150), () {
        // Only search if query hasn't changed since we scheduled this search
        if (mounted &&
            widget.query == queryToSearch &&
            queryToSearch != _lastSearchedQuery) {
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

    // Reset pagination state when searching
    _currentPage = 0;
    _hasMoreItems = true;

    // Cancel any existing loading indicator timer
    _loadingIndicatorTimer?.cancel();

    // Only show loading indicator if search takes longer than 150ms
    // This prevents flickering for fast local searches
    _loadingIndicatorTimer = Timer(const Duration(milliseconds: 150), () {
      if (mounted) {
        setState(() {
          _isLoading = true;
        });
      }
    });

    try {
      if (widget.isMention) {
        final results = await widget.mentionSearch(query);
        // Cancel loading indicator timer since we got results quickly
        _loadingIndicatorTimer?.cancel();
        if (mounted) {
          _updateMentionsList(results);
          // Check if we should enable load more based on results
          if (widget.onLoadMoreMentions != null && results.isNotEmpty) {
            _hasMoreItems = true; // Assume there might be more
          } else {
            _hasMoreItems = false;
          }
        }
      } else {
        // Use dollarSearch for $ tags, tagSearch for # tags
        final results = widget.tagTrigger == '\$'
            ? await widget.dollarSearch(query)
            : await widget.tagSearch(query);
        // Cancel loading indicator timer since we got results quickly
        _loadingIndicatorTimer?.cancel();
        if (mounted) {
          _updateTagsList(results);
          // Check if we should enable load more based on results
          final loadMoreCallback = widget.tagTrigger == '\$'
              ? widget.onLoadMoreDollarTags
              : widget.onLoadMoreTags;
          if (loadMoreCallback != null && results.isNotEmpty) {
            _hasMoreItems = true; // Assume there might be more
          } else {
            _hasMoreItems = false;
          }
        }
      }
    } catch (e) {
      _loadingIndicatorTimer?.cancel();
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasMoreItems = false;
        });
      }
    }
  }

  // Incrementally update mentions list - preserve existing items, add new ones, remove old ones
  void _updateMentionsList(List<MentionItem> newResults) {
    // Cancel loading indicator timer since we have results
    _loadingIndicatorTimer?.cancel();

    // Create maps for quick lookup
    final oldMap = {for (final item in _mentions) item.id: item};
    final newIds = newResults.map((e) => e.id).toSet();

    // Find items that need to be removed (in old but not in new)
    final toRemove =
        _mentions.where((item) => !newIds.contains(item.id)).toList();

    // Find items that need to be added (in new but not in old)
    final toAdd =
        newResults.where((item) => !oldMap.containsKey(item.id)).toList();

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
        return; // No changes needed
      }
    }

    setState(() {
      // Remove items that are no longer in results
      _mentions.removeWhere((item) => toRemove.contains(item));

      // Build new list maintaining order from newResults
      final resultList = <MentionItem>[];
      final existingIds = <String>{};

      for (var newItem in newResults) {
        if (existingIds.contains(newItem.id)) continue;

        // Use existing item if available (preserves state), otherwise use new
        final existingItem = oldMap[newItem.id];
        resultList.add(existingItem ?? newItem);
        existingIds.add(newItem.id);
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
  }

  // Incrementally update tags list - preserve existing items, add new ones, remove old ones
  void _updateTagsList(List<TagItem> newResults) {
    // Cancel loading indicator timer since we have results
    _loadingIndicatorTimer?.cancel();

    // Create maps for quick lookup
    final oldMap = {for (var item in _tags) item.id: item};
    final newIds = newResults.map((e) => e.id).toSet();

    // Find items that need to be removed (in old but not in new)
    final toRemove = _tags.where((item) => !newIds.contains(item.id)).toList();

    // Find items that need to be added (in new but not in old)
    final toAdd =
        newResults.where((item) => !oldMap.containsKey(item.id)).toList();

    // Only update if there are actual changes
    if (toRemove.isEmpty && toAdd.isEmpty) {
      // Check if any existing items need updates
      bool needsUpdate = false;
      for (var newItem in newResults) {
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
        return; // No changes needed
      }
    }

    setState(() {
      // Remove items that are no longer in results
      _tags.removeWhere((item) => toRemove.contains(item));

      // Build new list maintaining order from newResults
      final resultList = <TagItem>[];
      final existingIds = <String>{};

      for (var newItem in newResults) {
        if (existingIds.contains(newItem.id)) continue;

        // Use existing item if available (preserves state), otherwise use new
        final existingItem = oldMap[newItem.id];
        resultList.add(existingItem ?? newItem);
        existingIds.add(newItem.id);
      }

      _tags = resultList;
      _isLoading = false;
      _listVersion++; // Increment to trigger animation

      // Preserve selected index if still valid, otherwise reset to 0
      if (_selectedIndex >= _tags.length) {
        _selectedIndex = 0;
      }
    });

    widget.onItemCountChanged?.call(_tags.length);
  }

  void _selectItem() {
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

    // Hide only if no items and query is empty (no trigger typed)
    if (isEmpty && widget.query.isEmpty) {
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
                    key: ValueKey('mentions_list_v$_listVersion'),
                    controller: _scrollController,
                    itemCount: _mentions.length + (_isLoadingMore ? 1 : 0),
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      // Show loading indicator at the bottom
                      if (index == _mentions.length) {
                        return const SizedBox(
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
                        key: ValueKey(_mentions[index].id),
                      );
                    })
                : ListView.builder(
                    key: ValueKey('tags_list_v$_listVersion'),
                    controller: _scrollController,
                    itemCount: _tags.length + (_isLoadingMore ? 1 : 0),
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      // Show loading indicator at the bottom
                      if (index == _tags.length) {
                        return const Center(
                            child: Padding(
                                padding: EdgeInsets.all(8),
                                child: CircularProgressIndicator(strokeWidth: 2)));
                      }
                      final isSelected = index == _selectedIndex;
                      return _buildAnimatedItem(
                        context,
                        index,
                        isSelected,
                        key: ValueKey(_tags[index].id),
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
            setState(() {
              _selectedIndex = index;
            });
            _selectItem();
          },
          widget.customData,
        );
      }

      // Default mention item builder
      final mentionColor = _parseTagColor(mention.color, context);
      return InkWell(
        key: key,
        onTap: () {
          setState(() {
            _selectedIndex = index;
          });
          _selectItem();
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
            setState(() {
              _selectedIndex = index;
            });
            _selectItem();
          },
          widget.customData,
        );
      }

      // Default tag item builder
      return InkWell(
        key: key,
        onTap: () {
          setState(() {
            _selectedIndex = index;
          });
          _selectItem();
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
                color: _parseTagColor(tag.color, context) ??
                    Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  tag.name,
                  //_formatTagDisplay(tag.name, widget.tagTrigger),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: _parseTagColor(tag.color, context),
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
        _selectItem();
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
