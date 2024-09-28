import 'package:flutter_test/flutter_test.dart';
import 'package:quill_native_bridge_windows/src/html_cleaner.dart';

void main() {
  group('stripWin32HtmlDescription', () {
    test(
      'should remove windows metadata block from clipboard HTML',
      () {
        const windowsClipboardHtmlExample = '''
Version:0.9
StartHTML:0000000105
EndHTML:0000000634
StartFragment:0000000141
EndFragment:0000000598
<html>
<body>
<!--StartFragment--><div style="color: #cccccc;background-color: #1f1f1f;font-family: Consolas, 'Courier New', monospace;font-weight: normal;font-size: 14px;line-height: 19px;white-space: pre;"><div><span style="color: #cccccc;">&#160; &#160; &#160; </span><span style="color: #c586c0;">return</span><span style="color: #cccccc;"> </span><span style="color: #569cd6;">null</span><span style="color: #cccccc;">;</span></div><div><span style="color: #cccccc;"></span></div></div><!--EndFragment-->
</body>
</html>
''';
        const expectedHtml = '''
<html>
<body>
<!--StartFragment--><div style="color: #cccccc;background-color: #1f1f1f;font-family: Consolas, 'Courier New', monospace;font-weight: normal;font-size: 14px;line-height: 19px;white-space: pre;"><div><span style="color: #cccccc;">&#160; &#160; &#160; </span><span style="color: #c586c0;">return</span><span style="color: #cccccc;"> </span><span style="color: #569cd6;">null</span><span style="color: #cccccc;">;</span></div><div><span style="color: #cccccc;"></span></div></div><!--EndFragment-->
</body>
</html>
''';
        final strippedHtml =
            stripWindowsHtmlDescriptionHeaders(windowsClipboardHtmlExample);
        expect(
          strippedHtml,
          expectedHtml,
        );
        expect(strippedHtml.trim(), startsWith('<html>'));
        expect(strippedHtml.trim(), endsWith('</html>'));
      },
    );

    test('should return original HTML if no metadata is found', () {
      const cleanHtml = '''
<html>
<body>
<div>Some clean HTML content</div>
</body>
</html>''';

      expect(stripWindowsHtmlDescriptionHeaders(cleanHtml), equals(cleanHtml));
    });
  });
}
