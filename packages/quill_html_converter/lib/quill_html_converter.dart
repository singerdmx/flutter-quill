library quill_html_converter;

import 'dart:convert' show jsonDecode;

import 'package:delta_markdown_converter/delta_markdown_converter.dart'
    as delta_markdown show markdownToDelta;
import 'package:flutter_quill/flutter_quill.dart' show Delta;
import 'package:html2md/html2md.dart' as html2md;
import 'package:vsc_quill_delta_to_html/vsc_quill_delta_to_html.dart'
    as conventer show ConverterOptions, QuillDeltaToHtmlConverter;

typedef ConverterOptions = conventer.ConverterOptions;

/// A extension for [Delta] which comes from `flutter_quill` to extends
/// the functionality of it to support converting the [Delta] to/from HTML
extension DeltaHtmlExt on Delta {
  /// Convert the [Delta] instance to HTML Raw string
  ///
  /// It will run using the following steps:
  ///
  /// 1. Convert the [Delta] to json using [toJson]
  /// 2. Cast the json map as `List<Map<String, dynamic>>`
  /// 3. Pass it to the conventer `vsc_quill_delta_to_html` which is a package
  /// that designed specifically for converting the quill delta to html
  String toHtml({ConverterOptions? options}) {
    final json = toJson();
    final html = conventer.QuillDeltaToHtmlConverter(
      List.castFrom(json),
      options,
    ).convert();
    return html;
  }

  /// Convert the HTML Raw string to [Delta]
  ///
  /// It will run using the following steps:
  ///
  /// 1. Convert the html to markdown string using `html2md` package
  /// 2. Convert the markdown string to quill delta json string
  /// 3. Decode the delta json string to [Delta]
  ///
  /// for more [info](https://github.com/singerdmx/flutter-quill/issues/1100)
  static Delta fromHtml(String html) {
    final markdown = html2md
        .convert(
          html,
        )
        .replaceAll('unsafe:', '');
    final deltaJsonString = delta_markdown.markdownToDelta(markdown);
    final deltaJson = jsonDecode(deltaJsonString);
    if (deltaJson is! List) {
      throw ArgumentError(
        'The delta json string should be of type list when jsonDecode() it',
      );
    }
    return Delta.fromJson(
      deltaJson,
    );
  }
}
