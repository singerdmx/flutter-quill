library quill_html_converter;

import 'package:dart_quill_delta/dart_quill_delta.dart';
import 'package:vsc_quill_delta_to_html/vsc_quill_delta_to_html.dart'
    as converter
    show
        ConverterOptions,
        QuillDeltaToHtmlConverter,
        OpAttributeSanitizerOptions,
        OpConverterOptions,
        InlineStyles,
        InlineStyleType,
        defaultInlineFonts;

typedef ConverterOptions = converter.ConverterOptions;

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
    final html = converter.QuillDeltaToHtmlConverter(
      List.castFrom(json),
      options ??
          ConverterOptions(
            orderedListTag: 'ol',
            bulletListTag: 'ul',
            multiLineBlockquote: true,
            multiLineHeader: true,
            multiLineCodeblock: true,
            multiLineParagraph: true,
            multiLineCustomBlock: true,
            sanitizerOptions: converter.OpAttributeSanitizerOptions(
                allow8DigitHexColors: true),
            converterOptions: converter.OpConverterOptions(
              customCssStyles: (op) {
                ///if found line-height apply this as a inline style
                if (op.attributes['line-height'] != null) {
                  return ['line-height: ${op.attributes['line-height']}px'];
                }
                //here is where us pass the necessary
                //code to validate if our attributes exist in [DeltaInsertOp]
                //and return the necessary html style
                if (op.isImage()) {
                  // Fit images within restricted parent width.
                  return ['max-width: 100%', 'object-fit: contain'];
                }
                if (op.isBlockquote()) {
                  return ['border-left: 4px solid #ccc', 'padding-left: 16px'];
                }
                return null;
              },
              inlineStylesFlag: true, //This let inlineStyles work
              inlineStyles: converter.InlineStyles(
                <String, converter.InlineStyleType>{
                  'font': converter.InlineStyleType(
                      fn: (value, _) =>
                          converter.defaultInlineFonts[value] ??
                          'font-family: $value'),
                  'size': converter.InlineStyleType(fn: (value, _) {
                    //default sizes
                    if (value == 'small') return 'font-size: 0.75em';
                    if (value == 'large') return 'font-size: 1.5em';
                    if (value == 'huge') return 'font-size: 2.5em';
                    //accept any int or double type size
                    return 'font-size: ${value}px';
                  }),
                  'indent': converter.InlineStyleType(fn: (value, op) {
                    final indentSize =
                        (double.tryParse(value) ?? double.nan) * 3;
                    final side =
                        op.attributes['direction'] == 'rtl' ? 'right' : 'left';
                    return 'padding-$side:${indentSize}em';
                  }),
                  'list': converter.InlineStyleType(map: <String, String>{
                    'checked': "list-style-type:'\\2611';padding-left: 0.5em;",
                    'unchecked':
                        "list-style-type:'\\2610';padding-left: 0.5em;",
                  }),
                },
              ),
            ),
          ),
    ).convert();
    return html;
  }
}
