library quill_html_converter;

import 'dart:convert' show jsonDecode;

import 'package:flutter_quill/flutter_quill.dart' show Delta;
import 'package:html2md/html2md.dart' as html2md;
import 'package:vsc_quill_delta_to_html/vsc_quill_delta_to_html.dart'
    as conventer show ConverterOptions, QuillDeltaToHtmlConverter;

import 'src/packages/delta_markdown/delta_markdown.dart' show markdownToDelta;

typedef ConverterOptions = conventer.ConverterOptions;

extension DeltaHtmlExt on Delta {
  String toHtml({ConverterOptions? options}) {
    final html = conventer.QuillDeltaToHtmlConverter(
      List.castFrom(toJson()),
      options,
    ).convert();
    return html;
  }

  static Delta fromHtml(String html) {
    return Delta.fromJson(
      jsonDecode(
        markdownToDelta(
          html2md.convert(html),
        ),
      ),
    );
  }
}
