library quill_pdf_converter;

import 'package:dart_quill_delta/dart_quill_delta.dart';
import 'package:htmltopdfwidgets/htmltopdfwidgets.dart';
import 'package:meta/meta.dart';
import 'package:pdf/widgets.dart' as pw;

/// Extension on [Delta] to add extra functions for converting to Pdf
extension DeltaPdfExt on Delta {
  /// First convert to Html then to Pdf
  @experimental
  Future<List<pw.Widget>> toPdf() async {
    const html = '<html></html';
    return HTMLToPdf().convert(
      html,
      fontFallback: [
        pw.Font.symbol(),
      ],
    );
  }
}
