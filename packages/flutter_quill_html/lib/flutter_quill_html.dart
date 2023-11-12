library flutter_quill_html;

import 'dart:convert' show jsonDecode;

import 'package:delta_markdown/delta_markdown.dart' show markdownToDelta;
import 'package:flutter/foundation.dart';
import 'package:flutter_quill/flutter_quill.dart' show Delta;
// ignore: depend_on_referenced_packages
import 'package:html/dom.dart' as html_dom;
// ignore: depend_on_referenced_packages
import 'package:html/parser.dart' as html_parse;
import 'package:html2md/html2md.dart' as html2md;
import 'package:vsc_quill_delta_to_html/vsc_quill_delta_to_html.dart'
    as conventer show ConverterOptions, QuillDeltaToHtmlConverter;

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

// From https://github.com/singerdmx/flutter-quill/issues/1100#issuecomment-1681274676
@immutable
class HtmlToDeltaConverter {
  static const _collorPattern = r'color: rgb\((\d+), (\d+), (\d+)\);';

  static Delta _parseInlineStyles(html_dom.Element element) {
    var delta = Delta();

    for (final node in element.nodes) {
      final attributes = _parseElementStyles(element);

      if (node is html_dom.Text) {
        delta.insert(node.text, attributes);
      } else if (node is html_dom.Element && node.localName == 'img') {
        final src = node.attributes['src'];
        if (src != null) {
          delta.insert({'image': src});
        }
      } else if (node is html_dom.Element) {
        delta = delta.concat(_parseInlineStyles(node));
      }
    }

    return delta;
  }

  static Map<String, dynamic> _parseElementStyles(html_dom.Element element) {
    final attributes = <String, dynamic>{};

    if (element.localName == 'strong') attributes['bold'] = true;
    if (element.localName == 'em') attributes['italic'] = true;
    if (element.localName == 'u') attributes['underline'] = true;
    if (element.localName == 'del') attributes['strike'] = true;

    final style = element.attributes['style'];
    if (style != null) {
      final colorValue = _parseColorFromStyle(style);
      if (colorValue != null) attributes['color'] = colorValue;

      final bgColorValue = _parseBackgroundColorFromStyle(style);
      if (bgColorValue != null) attributes['background'] = bgColorValue;
    }

    return attributes;
  }

  static String? _parseColorFromStyle(String style) {
    if (RegExp(r'(^|\s)color:(\s|$)').hasMatch(style)) {
      return _parseRgbColorFromMatch(RegExp(_collorPattern).firstMatch(style));
    }
    return null;
  }

  static String? _parseBackgroundColorFromStyle(String style) {
    if (RegExp(r'(^|\s)background-color:(\s|$)').hasMatch(style)) {
      return _parseRgbColorFromMatch(RegExp(_collorPattern).firstMatch(style));
    }
    return null;
  }

  static String? _parseRgbColorFromMatch(RegExpMatch? colorMatch) {
    if (colorMatch != null) {
      try {
        final red = int.parse(colorMatch.group(1)!);
        final green = int.parse(colorMatch.group(2)!);
        final blue = int.parse(colorMatch.group(3)!);
        return '#${red.toRadixString(16).padLeft(2, '0')}${green.toRadixString(16).padLeft(2, '0')}${blue.toRadixString(16).padLeft(2, '0')}';
      } catch (e) {
        // debugPrintStack(label: e.toString());
      }
    }
    return null;
  }

  static Delta htmlToDelta(String html) {
    final document = html_parse.parse(html);
    var delta = Delta();

    for (final node in document.body?.nodes ?? []) {
      if (node is html_dom.Element) {
        switch (node.localName) {
          case 'p':
            delta = delta.concat(_parseInlineStyles(node))..insert('\n');
            break;
          case 'br':
            delta.insert('\n');
            break;
        }
      }
    }

    return html.isNotEmpty ? delta : Delta()
      ..insert('\n');
  }
}
