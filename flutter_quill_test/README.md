# 📝 Flutter Quill Test

Test utilities for [flutter_quill](https://pub.dev/packages/flutter_quill)
which include methods to simplify interacting with the editor in test cases.

## 📚 Table of contents

- [💾 Installation](#-installation)
- [🧪 Testing](#-testing)
- [🤝 Contributing](#-contributing)

## 💾 Installation

Add the dependencies [`flutter_test`](https://api.flutter.dev/flutter/flutter_test/flutter_test-library.html) and `flutter_quill_test`:

```shell
flutter pub add 'dev:flutter_test:{"sdk":"flutter"}'
flutter pub add dev:flutter_quill_test
```

## 🧪 Testing

To aid in testing applications using the editor an extension to the flutter `WidgetTester` is provided which includes
methods to simplify interacting with the editor in test cases.

# Flutter Quill Test Utilities

This package provides a set of utilities to simplify testing with the `QuillEditor` in Flutter.

First, import the test utilities in your test file:

```dart
import 'package:flutter_quill_test/flutter_quill_test.dart';
```

## Usage

### Entering Text

To enter text into the `QuillEditor`, use the `quillEnterText` method:

```dart
await tester.quillEnterText(find.byType(QuillEditor), 'test\n');
```

### Replacing Text

You can replace text in the `QuillEditor` using the following methods:

- **Replace the current selection**:
  ```dart
  await tester.quillReplaceText(find.byType(QuillEditor), 'text to be used for replace');
  ```

- **Replace text within a specific selection range**:
  ```dart
  await tester.quillReplaceTextWithSelection(
    find.byType(QuillEditor),
    'text',
    TextSelection(baseOffset: 0, extentOffset: 5),
  );
  ```

### Removing Text

To remove text from the `QuillEditor`, you can use the following methods:

- **Remove text within a specific selection**:
  ```dart
  await tester.quillRemoveText(
    find.byType(QuillEditor),
    TextSelection(baseOffset: 2, extentOffset: 3),
  );
  ```

- **Remove the currently selected text**:
  ```dart
  await tester.quillRemoveTextInSelection(find.byType(QuillEditor));
  ```

### Moving the Cursor

To move the cursor to a specific position in the `QuillEditor`, use the `quillMoveCursorTo` method:

```dart
await tester.quillMoveCursorTo(find.byType(QuillEditor), 50);
```

## Full Example

Here’s a complete example of how you might use these utilities in a test:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_test/flutter_quill_test.dart';

void main() {
  testWidgets('Test QuillEditor interactions', (WidgetTester tester) async {
    // Build the QuillEditor widget
    await tester.pumpWidget(
      MaterialApp(
        home: QuillEditor.basic(
          controller: your_controller,
          config: const QuillEditorConfig(),
        ),
      ),
    );

    // Enter text
    await tester.quillEnterText(find.byType(QuillEditor), 'Hello, World!\n');

    // Replace text
    await tester.quillReplaceText(find.byType(QuillEditor), 'Hi, World!\n');

    // Move the cursor
    await tester.quillMoveCursorTo(find.byType(QuillEditor), 5);

    // Remove text
    await tester.quillRemoveTextInSelection(find.byType(QuillEditor));
  });
}
```

## 🤝 Contributing

We greatly appreciate your time and effort.

To keep the project consistent and maintainable, we have a few guidelines that we ask all contributors to follow.
These guidelines help ensure that everyone can understand and work with the code easier.

See [Contributing](../CONTRIBUTING.md) for more details.
