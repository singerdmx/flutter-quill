# Flutter Quill HTML
A extension for [flutter_quill](https://pub.dev/packages/flutter_quill) package to add support for dealing with conversion to/from html

It uses [vsc_quill_delta_to_html](https://pub.dev/packages/vsc_quill_delta_to_html) package to convert the the delta to HTML

This library is **experimental** and the support might be dropped at anytime.

## Features

```markdown
- Easy to use
- Support Flutter Quill package
```

## Getting started

```yaml
dependencies:
  quill_html_converter: ^<latest-version-here>
```

## Usage

First, you need to [setup](../README.md#usage) the `flutter_quill` first

Then you can simply convert to/from HTML

```dart
import 'package:quill_html_converter/quill_html_converter.dart';

// Convert Delta to HTML
final html = _controller.document.toDelta().toHtml();

// Load Delta document using HTML
_controller.document =
    Document.fromDelta(Document.fromHtml(html));
```

## Additional information

This will be updated soon.
