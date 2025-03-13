# 📝 Flutter Quill Test

Test utilities for [flutter_quill](https://pub.dev/packages/flutter_quill)
which include methods to simplify interacting with the editor in test cases.

## 📚 Table of contents

- [💾 Installation](#-installation)
- [🧪 Testing](#-testing)
- [🛠️ Utilities](#-utilities)
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

## 🛠️ Utilities

This package provides a set of utilities to simplify testing with the `QuillEditor` in Flutter.

First, import the test utilities in your test file:

```dart
import 'package:flutter_quill_test/flutter_quill_test.dart';
```

### Usage

#### Entering Text

To enter text into the `QuillEditor`, use the `quillEnterText` method:

```dart
await tester.quillEnterText(find.byType(QuillEditor), 'test\n');
```

#### Replacing Text

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

#### Removing Text

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

#### Moving the Cursor

To change the selection values into the `QuillEditor` without use the `QuillController`, use the following methods:

- **Collapse the selection and move the cursor to the specified position**:
    ```dart
    await tester.quillMoveCursorTo(find.byType(QuillEditor), 15);
    ```

- **Expand the selection to**:
    ```dart
    await tester.quillExpandSelectionTo(find.byType(QuillEditor), 20);
    ```

#### Full Example

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

    await tester.tap(find.byType(QuillEditor));
    // Enter text
    await tester.quillEnterText(find.byType(QuillEditor), 'Hello, World!\n');
    expect(controller.document.toPlainText(), 'Hello, World!\n');

    // Move the cursor to before "!" 
    await tester.quillMoveCursorTo(find.byType(QuillEditor), 12);
    
    // Expands the selection to wrap the "!" character 
    await tester.quillExpandSelectionTo(find.byType(QuillEditor), 13);

    // Replace the "!" character and add new text replacement
    await tester.quillReplaceText(find.byType(QuillEditor), ' and hi, World!');
    expect(controller.document.toPlainText(), 'Hello, World and hi, World!\n');

    // Now, we move to the start of the document
    await tester.quillMoveCursorTo(find.byType(QuillEditor), 0);

    // Expand the selection to to wrap "Hello, "
    await tester.quillExpandSelectionTo(find.byType(QuillEditor), 7);

    // Remove the selected text
    await tester.quillRemoveTextInSelection(find.byType(QuillEditor));
    expect(controller.document.toPlainText(), 'World and hi, World!\n');
  });
}
```

## 🤝 Contributing

We greatly appreciate your time and effort.

To keep the project consistent and maintainable, we have a few guidelines that we ask all contributors to follow.
These guidelines help ensure that everyone can understand and work with the code easier.

See [Contributing](../CONTRIBUTING.md) for more details.
