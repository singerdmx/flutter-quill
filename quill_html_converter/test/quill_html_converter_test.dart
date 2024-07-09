import 'package:dart_quill_delta/dart_quill_delta.dart';
import 'package:quill_html_converter/quill_html_converter.dart';
import 'package:test/test.dart';

void main() {
  group('Quill HTML Converter', () {
    test('should parser delta heading to html', () {
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

    test('should parse line-height attribute to html', () {
      const html = '<p><span style="line-height: 1.5px">hello</span></p>';
      final quillDelta = [
        {
          'insert': 'hello',
          'attributes': {'line-height': 1.5}
        },
        {'insert': '\n'}
      ];
      expect(Delta.fromJson(quillDelta).toHtml().trim(), html.trim());
    });

    test("should parse block image embed with it's attributes to html", () {
      const html =
          '<p><img style="max-width: 100%;object-fit: contain;width: 40vh; height:350px; margin: 20px;" src="https://img.freepik.com/foto-gratis/belleza-otonal-abstracta-patron-venas-hoja-multicolor-generado-ia_188544-9871.jpg"/></p>';
      final quillDelta = [
        {
          'insert': {
            'image':
                'https://img.freepik.com/foto-gratis/belleza-otonal-abstracta-patron-venas-hoja-multicolor-generado-ia_188544-9871.jpg'
          },
          'attributes': {'style': 'width: 40vh; height:350px; margin: 20px;'}
        },
        {'insert': '\n'}
      ];
      expect(Delta.fromJson(quillDelta).toHtml().trim(), html.trim());
    });
  });
}
