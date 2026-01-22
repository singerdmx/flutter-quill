import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

/// Simple example showing load more callbacks for mentions and tags
/// 
/// This demonstrates the basic pattern for implementing pagination
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Load More Example',
      home: const LoadMoreExample(),
    );
  }
}

class LoadMoreExample extends StatefulWidget {
  const LoadMoreExample({super.key});

  @override
  State<LoadMoreExample> createState() => _LoadMoreExampleState();
}

class _LoadMoreExampleState extends State<LoadMoreExample> {
  final QuillController _controller = QuillController.basic();
  
  // Simulated data - in real app, replace with API calls
  final List<MentionItem> _allUsers = List.generate(
    100,
    (index) => MentionItem(
      id: 'user_$index',
      name: 'User $index',
    ),
  );

  final List<TagItem> _allTags = List.generate(
    80,
    (index) => TagItem(
      id: 'tag_$index',
      name: 'tag$index',
      count: index * 5,
    ),
  );

  static const int _itemsPerPage = 15;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Initial search - returns first page
  Future<List<MentionItem>> _searchMentions(String query) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    final filtered = query.isEmpty
        ? _allUsers
        : _allUsers.where((u) => u.name.contains(query)).toList();
    
    return filtered.take(_itemsPerPage).toList();
  }

  // Load more - returns next pages
  Future<List<MentionItem>> _loadMoreMentions(
    String query,
    List<MentionItem> currentItems,
    int currentPage,
  ) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    final filtered = query.isEmpty
        ? _allUsers
        : _allUsers.where((u) => u.name.contains(query)).toList();
    
    final startIndex = (currentPage + 1) * _itemsPerPage;
    if (startIndex >= filtered.length) {
      return []; // No more items
    }
    
    final endIndex = (startIndex + _itemsPerPage).clamp(0, filtered.length);
    return filtered.sublist(startIndex, endIndex);
  }

  // Initial search for tags
  Future<List<TagItem>> _searchTags(String query) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    final filtered = query.isEmpty
        ? _allTags
        : _allTags.where((t) => t.name.contains(query)).toList();
    
    return filtered.take(_itemsPerPage).toList();
  }

  // Load more tags
  Future<List<TagItem>> _loadMoreTags(
    String query,
    List<TagItem> currentItems,
    int currentPage,
  ) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    final filtered = query.isEmpty
        ? _allTags
        : _allTags.where((t) => t.name.contains(query)).toList();
    
    final startIndex = (currentPage + 1) * _itemsPerPage;
    if (startIndex >= filtered.length) {
      return []; // No more items
    }
    
    final endIndex = (startIndex + _itemsPerPage).clamp(0, filtered.length);
    return filtered.sublist(startIndex, endIndex);
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
            config: const QuillSimpleToolbarConfig(
              showUserTag: true,
              showHashTag: true,
            ),
          ),
          Expanded(
            child: MentionTagWrapper(
              controller: _controller,
              config: MentionTagConfig(
                // Initial search callbacks
                mentionSearch: _searchMentions,
                tagSearch: _searchTags,
                dollarSearch: (query) async => [],
                
                // Load more callbacks - these enable pagination
                onLoadMoreMentions: _loadMoreMentions,
                onLoadMoreTags: _loadMoreTags,
              ),
              child: QuillEditor.basic(
                controller: _controller,
                config: const QuillEditorConfig(
                  placeholder: 'Type @ for mentions or # for tags',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
