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

This package provides a set of utilities to simplify testing with the `QuillEditor`.

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

You can replace text in the `QuillEditor` using the `quillReplaceText` method:

```dart
await tester.quillReplaceText(find.byType(QuillEditor), 'text to be used for replace');
```

#### Removing Text

To remove text from the `QuillEditor`, you can use the `quillRemoveText` method:

```dart
await tester.quillRemoveText(
  find.byType(QuillEditor),
  TextSelection(baseOffset: 2, extentOffset: 3),
);
```

#### Moving the Cursor

To change the selection values into the `QuillEditor` without use the `QuillController`, use the `quillUpdateSelection` method:

```dart
await tester.quillUpdateSelection(find.byType(QuillEditor), 0, 10);
```

#### Full Example

Here’s a complete example of how you might use these utilities in a test:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_test/flutter_quill_test.dart';

void main() {
  testWidgets('Example QuillEditor test', (WidgetTester tester) async {
    final QuillController controller = QuillController.basic();
    await tester.pumpWidget(
      MaterialApp(
        home: QuillEditor.basic(
          controller: controller,
          config: const QuillEditorConfig(),
        ),
      ),
    );

    await tester.tap(find.byType(QuillEditor));
    await tester.quillEnterText(find.byType(QuillEditor), 'Hello, World!\n');
    expect(controller.document.toPlainText(), 'Hello, World!\n');

    await tester.quillMoveCursorTo(find.byType(QuillEditor), 12);
    await tester.quillExpandSelectionTo(find.byType(QuillEditor), 13);

    await tester.quillReplaceText(find.byType(QuillEditor), ' and hi, World!');
    expect(controller.document.toPlainText(), 'Hello, World and hi, World!\n');

    await tester.quillMoveCursorTo(find.byType(QuillEditor), 0);
    await tester.quillExpandSelectionTo(find.byType(QuillEditor), 7);

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
