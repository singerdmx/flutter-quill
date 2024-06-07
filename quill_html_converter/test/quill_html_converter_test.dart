import 'package:dart_quill_delta/dart_quill_delta.dart';
import 'package:quill_html_converter/quill_html_converter.dart';
import 'package:test/test.dart';

void main() {
  group('Quill HTML Converter', () {
    test('Example of toHtml', () {
      const html = '<p><br/></p><h1><br/></h1>';
      final quillDelta = [
        {'insert': '\n'},
        {
          'attributes': {'header': 1},
          'insert': 'Hello'
        }
      ];
      expect(Delta.fromJson(quillDelta).toHtml().trim(), html.trim());
    });
  });
}
