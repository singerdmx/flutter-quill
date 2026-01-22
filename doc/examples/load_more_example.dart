import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
// Uncomment these if using API example:
// import 'package:http/http.dart' as http;

/// Example demonstrating how to use load more callbacks for mentions and tags
/// with pagination support
class LoadMoreExample extends StatefulWidget {
  const LoadMoreExample({super.key});

  @override
  State<LoadMoreExample> createState() => _LoadMoreExampleState();
}

class _LoadMoreExampleState extends State<LoadMoreExample> {
  final QuillController _controller = QuillController.basic();
  
  // Simulated data sources (in real app, these would be API calls)
  final List<MentionItem> _allUsers = List.generate(
    200, // Total 200 users
    (index) => MentionItem(
      id: 'user_$index',
      name: 'User $index',
      avatarUrl: 'https://i.pravatar.cc/150?img=$index',
    ),
  );

  final List<TagItem> _allTags = List.generate(
    150, // Total 150 tags
    (index) => TagItem(
      id: 'tag_$index',
      name: 'tag$index',
      count: index * 10,
      color: '#${(0x1000000 + (index * 0x123456) % 0xFFFFFF).toRadixString(16)}',
    ),
  );

  final List<TagItem> _allCurrencyTags = List.generate(
    100, // Total 100 currency values
    (index) => TagItem(
      id: 'currency_$index',
      name: (index * 100).toString(),
      count: index,
    ),
  );

  // Pagination constants
  static const int _itemsPerPage = 20;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Example: Load more mentions with pagination
  /// 
  /// Parameters:
  /// - [query]: Current search query (e.g., "john")
  /// - [currentItems]: List of mentions currently displayed
  /// - [currentPage]: Current page number (0-indexed, starts at 0)
  /// 
  /// Returns: List of new MentionItem objects to append, or empty list if no more items
  Future<List<MentionItem>> _loadMoreMentions(
    String query,
    List<MentionItem> currentItems,
    int currentPage,
  ) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Filter users based on query
    final filteredUsers = query.isEmpty
        ? _allUsers
        : _allUsers
            .where((user) =>
                user.name.toLowerCase().contains(query.toLowerCase()))
            .toList();

    // Calculate pagination
    final startIndex = (currentPage + 1) * _itemsPerPage;
    final endIndex = (startIndex + _itemsPerPage).clamp(0, filteredUsers.length);

    // Check if there are more items to load
    if (startIndex >= filteredUsers.length) {
      return []; // No more items
    }

    // Return the next page of items
    return filteredUsers.sublist(startIndex, endIndex);
  }

  /// Example: Load more hashtags with pagination
  Future<List<TagItem>> _loadMoreTags(
    String query,
    List<TagItem> currentItems,
    int currentPage,
  ) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Filter tags based on query
    final filteredTags = query.isEmpty
        ? _allTags
        : _allTags
            .where((tag) =>
                tag.name.toLowerCase().contains(query.toLowerCase()))
            .toList();

    // Calculate pagination
    final startIndex = (currentPage + 1) * _itemsPerPage;
    final endIndex = (startIndex + _itemsPerPage).clamp(0, filteredTags.length);

    // Check if there are more items to load
    if (startIndex >= filteredTags.length) {
      return []; // No more items
    }

    // Return the next page of items
    return filteredTags.sublist(startIndex, endIndex);
  }

  /// Example: Load more dollar/currency tags with pagination
  Future<List<TagItem>> _loadMoreDollarTags(
    String query,
    List<TagItem> currentItems,
    int currentPage,
  ) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Filter currency tags based on query
    final filteredTags = query.isEmpty
        ? _allCurrencyTags
        : _allCurrencyTags
            .where((tag) =>
                tag.name.toLowerCase().contains(query.toLowerCase()))
            .toList();

    // Calculate pagination
    final startIndex = (currentPage + 1) * _itemsPerPage;
    final endIndex = (startIndex + _itemsPerPage).clamp(0, filteredTags.length);

    // Check if there are more items to load
    if (startIndex >= filteredTags.length) {
      return []; // No more items
    }

    // Return the next page of items
    return filteredTags.sublist(startIndex, endIndex);
  }

  /// Initial search callback for mentions
  Future<List<MentionItem>> _searchMentions(String query) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final filteredUsers = query.isEmpty
        ? _allUsers
        : _allUsers
            .where((user) =>
                user.name.toLowerCase().contains(query.toLowerCase()))
            .toList();

    // Return first page
    return filteredUsers.take(_itemsPerPage).toList();
  }

  /// Initial search callback for hashtags
  Future<List<TagItem>> _searchTags(String query) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final filteredTags = query.isEmpty
        ? _allTags
        : _allTags
            .where((tag) =>
                tag.name.toLowerCase().contains(query.toLowerCase()))
            .toList();

    // Return first page
    return filteredTags.take(_itemsPerPage).toList();
  }

  /// Initial search callback for dollar tags
  Future<List<TagItem>> _searchDollarTags(String query) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final filteredTags = query.isEmpty
        ? _allCurrencyTags
        : _allCurrencyTags
            .where((tag) =>
                tag.name.toLowerCase().contains(query.toLowerCase()))
            .toList();

    // Return first page
    return filteredTags.take(_itemsPerPage).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Load More Example'),
      ),
      body: Column(
        children: [
          QuillSimpleToolbar(
            controller: _controller,
            config: QuillSimpleToolbarConfig(
              showUserTag: true,
              showHashTag: true,
              showDollarTag: true,
            ),
          ),
          Expanded(
            child: MentionTagWrapper(
              controller: _controller,
              config: MentionTagConfig(
                // Initial search callbacks - return first page
                mentionSearch: _searchMentions,
                tagSearch: _searchTags,
                dollarSearch: _searchDollarTags,

                // Load more callbacks - return next pages
                onLoadMoreMentions: _loadMoreMentions,
                onLoadMoreTags: _loadMoreTags,
                onLoadMoreDollarTags: _loadMoreDollarTags,

                // Optional: Customize overlay appearance
                maxHeight: 300,
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).dividerColor,
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),

                // Optional: Callbacks when items are selected
                onMentionSelected: (mention) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Mentioned: ${mention.name}')),
                  );
                },
                onTagSelected: (tag) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Tagged: #${tag.name}')),
                  );
                },
              ),
              child: QuillEditor.basic(
                controller: _controller,
                config: QuillEditorConfig(
                  placeholder: 'Type @ for mentions, # for tags, or $ for currency',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Example with API-based pagination
class ApiLoadMoreExample extends StatefulWidget {
  const ApiLoadMoreExample({super.key});

  @override
  State<ApiLoadMoreExample> createState() => _ApiLoadMoreExampleState();
}

class _ApiLoadMoreExampleState extends State<ApiLoadMoreExample> {
  final QuillController _controller = QuillController.basic();

  /// Example: Load more mentions from API
  /// 
  /// This example shows how to implement pagination with a real API
  Future<List<MentionItem>> _loadMoreMentionsFromApi(
    String query,
    List<MentionItem> currentItems,
    int currentPage,
  ) async {
    try {
      // Make API call with pagination parameters
      // Replace this with your actual API endpoint
      // Uncomment and use your HTTP client:
      // final response = await http.get(
        //   Uri.parse(
        //     'https://api.example.com/users?'
        //     'query=$query&'
        //     'page=${currentPage + 1}&' // API typically uses 1-indexed pages
        //     'limit=20',
        //   ),
        // );

        // Example response structure:
        // if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final users = data['users'] as List;
        final hasMore = data['hasMore'] as bool;

        // Convert API response to MentionItem list
        final newItems = users.map((user) {
          return MentionItem(
            id: user['id'].toString(),
            name: user['name'],
            avatarUrl: user['avatarUrl'],
            color: user['color'],
          );
        }).toList();

        // Return empty list if no more items (API indicates no more)
        if (!hasMore || newItems.isEmpty) {
          return [];
        }

        return newItems;
      } else {
        // Handle error - return empty list to stop pagination
        return [];
      }
    } catch (e) {
      // Handle error - return empty list to stop pagination
      debugPrint('Error loading more mentions: $e');
      return [];
    }
  }

  /// Example: Load more tags from API with cursor-based pagination
  /// 
  /// Some APIs use cursor-based pagination instead of page numbers
  Future<List<TagItem>> _loadMoreTagsWithCursor(
    String query,
    List<TagItem> currentItems,
    int currentPage,
  ) async {
    try {
      // Get the last item's ID as cursor
      final lastItemId = currentItems.isNotEmpty
          ? currentItems.last.id
          : null;

      // Make API call with cursor
      // Uncomment and use your HTTP client:
      // final response = await http.get(
      //   Uri.parse(
      //     'https://api.example.com/tags?'
      //     'query=$query&'
      //     'cursor=$lastItemId&'
      //     'limit=20',
      //   ),
      // );

      // Example response structure:
      // if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final tags = data['tags'] as List;
        final nextCursor = data['nextCursor'];

        // Convert API response to TagItem list
        final newItems = tags.map((tag) {
          return TagItem(
            id: tag['id'].toString(),
            name: tag['name'],
            count: tag['count'],
            color: tag['color'],
          );
        }).toList();

        // If no nextCursor, there are no more items
        if (nextCursor == null || newItems.isEmpty) {
          return [];
        }

        return newItems;
      } else {
        return [];
      }
    } catch (e) {
      debugPrint('Error loading more tags: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API Load More Example'),
      ),
      body: MentionTagWrapper(
        controller: _controller,
        config: MentionTagConfig(
          mentionSearch: (query) async {
            // Initial search - first page
            // Example API call:
            // final response = await http.get(
            //   Uri.parse('https://api.example.com/users?query=$query&page=1&limit=20'),
            // );
            // Parse and return first page
            // ... implementation
            return [];
          },
          tagSearch: (query) async {
            // Initial search - first page
            // ... implementation
            return [];
          },
          dollarSearch: (query) async {
            // Initial search - first page
            // ... implementation
            return [];
          },
          onLoadMoreMentions: _loadMoreMentionsFromApi,
          onLoadMoreTags: _loadMoreTagsWithCursor,
        ),
        child: QuillEditor.basic(controller: _controller),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

/// Key Points for Load More Callbacks:
/// 
/// 1. **Parameters**:
///    - `query`: The current search query string
///    - `currentItems`: List of items currently displayed in the overlay
///    - `currentPage`: Current page number (0-indexed, starts at 0)
/// 
/// 2. **Return Value**:
///    - Return a list of new items to append to the current list
///    - Return an empty list `[]` when there are no more items to load
/// 
/// 3. **Pagination Logic**:
///    - First page (currentPage = 0) is handled by the initial search callback
///    - Load more callback is called for subsequent pages (currentPage = 1, 2, 3...)
///    - Calculate the next page's items based on currentPage
/// 
/// 4. **Automatic Behavior**:
///    - The overlay automatically detects when user scrolls near the bottom (within 100px)
///    - It calls the load more callback automatically
///    - Shows a loading indicator at the bottom while loading
///    - Stops calling when empty list is returned or callback is null
/// 
/// 5. **Best Practices**:
///    - Always filter by query to maintain search context
///    - Handle errors gracefully by returning empty list
///    - Avoid duplicates by checking existing items (handled automatically)
///    - Use appropriate page size (typically 20-50 items)
///    - Consider debouncing if making API calls
