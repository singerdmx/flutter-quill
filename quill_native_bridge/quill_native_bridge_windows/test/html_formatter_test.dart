import 'package:flutter_test/flutter_test.dart';
import 'package:quill_native_bridge_windows/src/html_formatter.dart';

void main() {
  group('constructWindowsHtmlDescriptionHeaders', () {
    test('should include windows descirption headers', () {
      const htmlInput =
          '<body>This is normal. <b>This is bold.</b> <i><b>This is bold italic.</b> This is italic.</i></body>';
      const expectedWindowsHtml = '''
Version:1.0
StartHTML:0082
EndHTML:0220
StartFragment:0102
EndFragment:0202
<html><!--StartFragment--><body>This is normal. <b>This is bold.</b> <i><b>This is bold italic.</b> This is italic.</i></body><!--EndFragment--></html>
''';
      expect(
        constructWindowsHtmlDescriptionHeaders(htmlInput),
        expectedWindowsHtml,
      );
    });
  });
}
