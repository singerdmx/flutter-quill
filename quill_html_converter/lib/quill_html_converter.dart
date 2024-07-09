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
      options ?? _defaultConverterOptions,
    ).convert();
    return html;
  }
}

/// Configuration options for converting Quill Delta to HTML.
/// This includes various settings for how different elements and styles should be handled.
final _defaultConverterOptions = ConverterOptions(
  // Tag to be used for ordered lists
  orderedListTag: 'ol',

  // Tag to be used for bullet lists
  bulletListTag: 'ul',

  // Enable multi-line blockquote conversion
  multiLineBlockquote: true,

  // Enable multi-line header conversion
  multiLineHeader: true,

  // Enable multi-line code block conversion
  multiLineCodeblock: true,

  // Enable multi-line paragraph conversion
  multiLineParagraph: true,

  // Enable multi-line custom block conversion
  multiLineCustomBlock: true,

  // Options for sanitizing attributes
  sanitizerOptions: converter.OpAttributeSanitizerOptions(
    // Allow 8-digit hex colors in styles
    allow8DigitHexColors: true,
  ),

  // This handle specific styles and attributes
  converterOptions: converter.OpConverterOptions(
    customCssStyles: (op) {
      // Validate if our attributes exist in [DeltaInsertOp]
      // and return the necessary HTML style
      // These lists of attributes, are passed as inline styles
      //
      // For example, if you have a delta like ->
      // [ { "insert": "hello", "attributes": { "line-height": 1.5 }} ]
      //
      // Without the validation below to verify if exist line-height atribute in the Operation, it would be:
      // <p>hello</p> -> isn't created the attribute
      //
      // But, with this validation an implementation of the style will be:
      // <p><span style="line-height: 1.5px">hello</span></p>
      if (op.attributes['line-height'] != null) {
        return ['line-height: ${op.attributes['line-height']}px'];
      }
      if (op.isImage()) {
        // Fit images within restricted parent width
        final String? styles = op.attributes['style'];
        final listStyles = styles?.split(';') ?? [];
        return ['max-width: 100%', 'object-fit: contain', ...listStyles];
      }
      return null;
    },
    // Enable inline styles
    inlineStylesFlag: true,
    inlineStyles: converter.InlineStyles(
      <String, converter.InlineStyleType>{
        'font': converter.InlineStyleType(
          fn: (value, _) =>
              converter.defaultInlineFonts[value] ?? 'font-family: $value',
        ),
        'size': converter.InlineStyleType(
          fn: (value, _) {
            // Default sizes
            if (value == 'small') return 'font-size: 0.75em';
            if (value == 'large') return 'font-size: 1.5em';
            if (value == 'huge') return 'font-size: 2.5em';
            // Accept any int or double type size
            return 'font-size: ${value}px';
          },
        ),
        'indent': converter.InlineStyleType(
          fn: (value, op) {
            // Calculate indent size based on the value
            final indentSize = (double.tryParse(value) ?? double.nan) * 3;
            // Determine side for padding based on text direction
            final side = op.attributes['direction'] == 'rtl' ? 'right' : 'left';
            return 'padding-$side:${indentSize}em';
          },
        ),
        'list': converter.InlineStyleType(
          map: <String, String>{
            // Styles for checked and unchecked list items
            'checked': "list-style-type:'\\2611';padding-left: 0.5em;",
            'unchecked': "list-style-type:'\\2610';padding-left: 0.5em;",
          },
        ),
      },
    ),
  ),
);
