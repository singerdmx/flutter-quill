# Flutter Quill Pdf
A extension for [flutter_quill](https://pub.dev/packages/flutter_quill) package to add support for dealing with conversion to Pdf

It uses [quill_html_converter](https://pub.dev/packages/quill_html_converter) package to convert the the delta to Html and [htmltopdfwidgets](https://pub.dev/packages/htmltopdfwidgets) to convert the Html to Pdf

This library is **experimental** and the support might be dropped at anytime.

## Features

```markdown
- Easy to use
- Support Flutter Quill package
```

## Getting started

```yaml
dependencies:
  quill_pdf_converter: ^<latest-version-here>
```

## Usage

First, you need to [setup](../README.md#usage) the `flutter_quill` first

Then you can simply convert to PDF

```dart
import 'package:quill_pdf_converter/quill_pdf_converter.dart';

// Convert Delta to Pdf
final pdfWidgets = _controller.document.toDelta().toPdf();

```