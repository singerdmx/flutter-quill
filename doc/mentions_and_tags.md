# Mentions and Tags Feature

This document explains how to use the mention (@) and tag (#) functionality in Flutter Quill.

## Overview

The mention and tag feature allows users to:
- Type `@` to mention users - shows a list of users above the keyboard
- Type `#` to add hashtags - shows a list of tags above the keyboard
- Select items from the list to insert them with proper attributes

## Setup

### 1. Wrap your QuillEditor with MentionTagWrapper

```dart
import 'package:flutter_quill/flutter_quill.dart';

MentionTagWrapper(
  controller: _controller,
  config: MentionTagConfig(
    mentionSearch: (query) async {
      // Your user search logic here
      // Return a list of MentionItem objects
      return [
        MentionItem(id: '1', name: 'John Doe'),
        MentionItem(id: '2', name: 'Jane Smith'),
      ];
    },
    tagSearch: (query) async {
      // Your tag search logic here
      // Return a list of TagItem objects
      return [
        TagItem(id: '1', name: 'flutter', count: 123),
        TagItem(id: '2', name: 'dart', count: 89),
      ];
    },
    onMentionSelected: (mention) {
      print('Mention selected: ${mention.name}');
    },
    onTagSelected: (tag) {
      print('Tag selected: ${tag.name}');
    },
  ),
  child: QuillEditor(
    controller: _controller,
    config: QuillEditorConfig(
      placeholder: 'Type @ for mentions or # for tags',
    ),
  ),
)
```

### 2. Configure MentionTagConfig

The `MentionTagConfig` requires:
- `mentionSearch`: Async function that searches for users based on query string
- `tagSearch`: Async function that searches for tags based on query string

Optional parameters:
- `maxHeight`: Maximum height of the overlay (default: 200)
- `itemHeight`: Height of each item in the list (default: 48)
- `onMentionSelected`: Callback when a mention is selected
- `onTagSelected`: Callback when a tag is selected
- `mentionItemBuilder`: Custom builder for mention items (allows full UI customization)
- `tagItemBuilder`: Custom builder for tag items (allows full UI customization)
- `customData`: Custom data passed to builders (for additional context)
- `dollarSearch`: Callback to search for currency tags when $ is typed
- `onLoadMoreMentions`: Callback to load more mentions when user scrolls to bottom (pagination)
- `onLoadMoreTags`: Callback to load more tags when user scrolls to bottom (pagination)
- `onLoadMoreDollarTags`: Callback to load more dollar tags when user scrolls to bottom (pagination)
- `decoration`: Custom decoration for the suggestion overlay view

## Data Models

### MentionItem

```dart
class MentionItem {
  final String id;
  final String name;
  final String? avatarUrl; // Optional avatar URL
  final String? color; // Optional color as hex string (e.g., "#FF5733") or color name
  final dynamic customData; // Optional custom data for your requirements
}
```

### TagItem

```dart
class TagItem {
  final String id;
  final String name;
  final int? count; // Optional tag count
  final String? color; // Optional color
  final dynamic customData; // Optional custom data for your requirements
}
```

## Attributes

When a mention or tag is inserted, it's automatically formatted with attributes:

### Mention Attribute

```json
{
  "attributes": {
    "mention": {
      "id": "123",
      "name": "John Doe",
      "avatarUrl": "https://example.com/avatar.jpg",
      "color": "#FF5733"
    }
  }
}
```

### Tag Attribute

```json
{
  "attributes": {
    "tag": {
      "id": "456",
      "name": "flutter",
      "count": 123
    }
  }
}
```

## Usage Example

```dart
class MyEditor extends StatefulWidget {
  @override
  _MyEditorState createState() => _MyEditorState();
}

class _MyEditorState extends State<MyEditor> {
  final QuillController _controller = QuillController.basic();
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  // Mock user data
  final List<MentionItem> _users = [
    MentionItem(id: '1', name: 'John Doe'),
    MentionItem(id: '2', name: 'Jane Smith'),
    MentionItem(id: '3', name: 'Bob Johnson'),
  ];

  // Mock tag data
  final List<TagItem> _tags = [
    TagItem(id: '1', name: 'flutter', count: 123),
    TagItem(id: '2', name: 'dart', count: 89),
    TagItem(id: '3', name: 'mobile', count: 45),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        QuillSimpleToolbar(controller: _controller),
        Expanded(
          child: MentionTagWrapper(
            controller: _controller,
            config: MentionTagConfig(
              mentionSearch: (query) async {
                // Simulate network delay
                await Future.delayed(Duration(milliseconds: 300));
                
                if (query.isEmpty) return _users;
                
                return _users
                    .where((user) =>
                        user.name.toLowerCase().contains(query.toLowerCase()))
                    .toList();
              },
              tagSearch: (query) async {
                // Simulate network delay
                await Future.delayed(Duration(milliseconds: 300));
                
                if (query.isEmpty) return _tags;
                
                return _tags
                    .where((tag) =>
                        tag.name.toLowerCase().contains(query.toLowerCase()))
                    .toList();
              },
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
            child: QuillEditor(
              focusNode: _focusNode,
              scrollController: _scrollController,
              controller: _controller,
              config: QuillEditorConfig(
                placeholder: 'Type @ for mentions or # for tags',
                padding: EdgeInsets.all(16),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
```

## How It Works

1. **Trigger Detection**: When the user types `@` or `#`, the system detects the trigger character
2. **Query Extraction**: As the user continues typing, the query text is extracted
3. **Search**: The `mentionSearch` or `tagSearch` callback is called with the query
4. **Display**: Results are shown in an overlay above the keyboard
5. **Selection**: When a user selects an item:
   - The trigger character and query are replaced with the selected item's name
   - The text is formatted with the appropriate attribute (mention or tag)
   - The overlay is hidden

## Keyboard Navigation

The overlay supports keyboard navigation:
- **Arrow Up/Down**: Navigate through the list
- **Enter/Tab**: Select the highlighted item
- **Escape**: Close the overlay (handled automatically when typing continues)

## Customization

### Custom Item Builders

You can provide custom builders to fully customize the appearance of mention and tag items:

```dart
MentionTagConfig(
  // ... other config ...
  mentionItemBuilder: (context, item, isSelected, onTap, customData) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: item.avatarUrl != null 
          ? NetworkImage(item.avatarUrl!) 
          : null,
        child: item.avatarUrl == null 
          ? Text(item.name[0].toUpperCase()) 
          : null,
      ),
      title: Text(item.name),
      selected: isSelected,
      onTap: onTap,
      tileColor: isSelected ? Colors.blue.shade100 : null,
    );
  },
  tagItemBuilder: (context, item, isSelected, onTap, customData) {
    return ListTile(
      leading: Icon(Icons.tag, color: Colors.blue),
      title: Text('#${item.name}'),
      trailing: item.count != null 
        ? Text('${item.count}', style: TextStyle(color: Colors.grey))
        : null,
      selected: isSelected,
      onTap: onTap,
    );
  },
  customData: {'theme': 'dark', 'userId': '123'}, // Pass any custom data
)
```

### Custom Data

You can pass custom data to builders using the `customData` parameter:

```dart
MentionTagConfig(
  customData: {
    'currentUserId': '123',
    'theme': 'dark',
    'permissions': ['edit', 'delete'],
    // Any data you need
  },
  mentionItemBuilder: (context, item, isSelected, onTap, customData) {
    final userId = customData?['currentUserId'];
    final isCurrentUser = item.id == userId;
    
    return ListTile(
      title: Text(item.name),
      trailing: isCurrentUser ? Text('You') : null,
      // ... rest of your custom UI
    );
  },
)
```

### Refreshing the List

When your data changes, you can refresh the suggestion list:

**Option 1: Using GlobalKey (Recommended)**

```dart
class _MyEditorState extends State<MyEditor> {
  final GlobalKey<_MentionTagWrapperState> _mentionTagKey = GlobalKey();
  
  void _updateData() {
    // Your data update logic
    setState(() {
      _users.add(MentionItem(id: '4', name: 'New User'));
    });
    
    // Refresh the suggestion list
    _mentionTagKey.currentState?.refreshSuggestionList();
  }
  
  @override
  Widget build(BuildContext context) {
    return MentionTagWrapper(
      key: _mentionTagKey,
      // ... rest of config
    );
  }
}
```

**Option 2: Update Search Callbacks**

The list will automatically refresh when search callbacks change:

```dart
setState(() {
  _config = MentionTagConfig(
    mentionSearch: (query) async {
      // Return updated data
      return updatedMentionList;
    },
    // ... other callbacks
  );
});
```

## Load More / Pagination

The mention and tag overlays support pagination through load more callbacks. When the user scrolls near the bottom of the list (within 100px), the load more callback is automatically triggered.

### Load More Callback Signature

```dart
Future<List<MentionItem>> Function(
  String query,           // Current search query
  List<MentionItem> currentItems,  // Items currently displayed
  int currentPage,        // Current page number (0-indexed)
)? onLoadMoreMentions;

Future<List<TagItem>> Function(
  String query,
  List<TagItem> currentItems,
  int currentPage,
)? onLoadMoreTags;

Future<List<TagItem>> Function(
  String query,
  List<TagItem> currentItems,
  int currentPage,
)? onLoadMoreDollarTags;
```

### Example: Load More with Pagination

```dart
MentionTagConfig(
  mentionSearch: (query) async {
    // Return first page (e.g., 20 items)
    final response = await api.searchUsers(query, page: 1, limit: 20);
    return response.users;
  },
  onLoadMoreMentions: (query, currentItems, currentPage) async {
    // Load next page
    // currentPage is 0-indexed, so first load more call has currentPage = 1
    final nextPage = currentPage + 1;
    final response = await api.searchUsers(query, page: nextPage, limit: 20);
    
    // Return empty list when no more items
    if (response.users.isEmpty || !response.hasMore) {
      return [];
    }
    
    return response.users;
  },
  // ... other config
)
```

### Example: Simple List Pagination

```dart
final List<MentionItem> _allUsers = List.generate(200, (index) => 
  MentionItem(id: 'user_$index', name: 'User $index')
);

Future<List<MentionItem>> _loadMoreMentions(
  String query,
  List<MentionItem> currentItems,
  int currentPage,
) async {
  // Filter by query
  final filtered = query.isEmpty 
    ? _allUsers 
    : _allUsers.where((u) => u.name.contains(query)).toList();
  
  // Calculate next page
  const itemsPerPage = 20;
  final startIndex = (currentPage + 1) * itemsPerPage;
  final endIndex = (startIndex + itemsPerPage).clamp(0, filtered.length);
  
  // Return empty if no more items
  if (startIndex >= filtered.length) {
    return [];
  }
  
  return filtered.sublist(startIndex, endIndex);
}
```

### Key Points

- **Automatic Triggering**: Load more is called automatically when user scrolls near bottom (100px threshold)
- **Page Numbers**: First page (page 0) is handled by the search callback, load more handles pages 1, 2, 3...
- **Return Empty List**: Return `[]` when there are no more items to stop pagination
- **Query Filtering**: Always filter by the current query to maintain search context
- **Loading Indicator**: A loading indicator automatically appears at the bottom while loading
- **Error Handling**: Return empty list on errors to gracefully stop pagination

See [Load More Example](./examples/load_more_example.dart) for complete working examples.

## Features

- **Smooth Animations**: List items animate smoothly when data changes
- **Smooth Closing**: The suggestion view closes with a smooth fade and size animation when an item is selected
- **Incremental Updates**: Only changed items are updated, preserving existing items
- **Keyboard Navigation**: Full keyboard support with arrow keys and Enter
- **Debounced Search**: Prevents excessive API calls during typing
- **Empty Query Support**: Shows all data immediately when trigger character is typed (#, @, or $)
- **Pagination Support**: Automatic load more when scrolling to bottom

## Notes

- The suggestion list appears below the editor (not as an overlay)
- The search is debounced to avoid excessive API calls
- Mentions and tags are stored as inline attributes in the document
- The feature works on all platforms (iOS, Android, Web, Desktop)
- The list automatically updates when search callbacks change
- Custom builders receive `customData` for additional context