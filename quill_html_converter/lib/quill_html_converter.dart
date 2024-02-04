library quill_html_converter;

import 'package:dart_quill_delta/dart_quill_delta.dart';
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
}
