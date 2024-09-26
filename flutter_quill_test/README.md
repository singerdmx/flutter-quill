# 📝 Flutter Quill Test

Test utilities for [flutter_quill](https://pub.dev/packages/flutter_quill)
which include methods to simplify interacting with the editor in test cases.

## 📚 Table of contents

- [💾 Installation](#-installation)
- [🧪 Testing](#-testing)
- [🤝 Contributing](#-contributing)

## 💾 Installation

Run the following command:

```
flutter pub add dev:flutter_quill_test
```

Also add `flutter_test` as a dependency:

```yaml
dev_dependencies:
  flutter_quill_test: any # Use latest Version
  flutter_test:
    sdk: flutter
```

## 🧪 Testing

To aid in testing applications using the editor an extension to the flutter `WidgetTester` is provided which includes
methods to simplify interacting with the editor in test cases.

Import the test utilities in your test file:

```dart
import 'package:flutter_quill_test/flutter_quill_test.dart';
```

and then enter text using `quillEnterText`:

```dart
await tester.quillEnterText(find.byType(QuillEditor), 'test\n');
```

## 🤝 Contributing

We greatly appreciate your time and effort.

To keep the project consistent and maintainable, we have a few guidelines that we ask all contributors to follow.
These guidelines help ensure that everyone can understand and work with the code easier.

See [Contributing](../CONTRIBUTING.md) for more details.
