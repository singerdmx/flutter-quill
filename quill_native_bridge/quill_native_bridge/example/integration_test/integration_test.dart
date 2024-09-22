import 'package:flutter/services.dart' as services
    show Clipboard, ClipboardData;
import 'package:flutter_test/flutter_test.dart';
import 'package:image_compare/image_compare.dart';
import 'package:integration_test/integration_test.dart';
import 'package:quill_native_bridge/quill_native_bridge.dart';
import 'package:quill_native_bridge_example/assets.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('getClipboardImage and copyImageToClipboard', () {
    test('copying images to the clipboard should make them accessible',
        () async {
      Future<void> verifyImageCopiedToClipboard(String assetPath) async {
        final imageBytes = await loadAssetImage(assetPath);
        await QuillNativeBridge.copyImageToClipboard(imageBytes);
        final clipboardImageBytes = await QuillNativeBridge.getClipboardImage();
        final pixelMismatchPercentage =
            await compareImages(src1: imageBytes, src2: clipboardImageBytes);
        expect(pixelMismatchPercentage, 0);
      }

      await verifyImageCopiedToClipboard(kFlutterQuillAssetImage);
      await verifyImageCopiedToClipboard(kQuillJsRichTextEditor);
      await verifyImageCopiedToClipboard(kFlutterQuillAssetImage);
      await verifyImageCopiedToClipboard(kQuillJsRichTextEditor);
    });

    test(
      'copying an image should return the image that was recently copied',
      () async {
        final imageBytes = await loadAssetImage(kFlutterQuillAssetImage);
        final imageBytes2 = await loadAssetImage(kQuillJsRichTextEditor);

        await QuillNativeBridge.copyImageToClipboard(imageBytes);
        await QuillNativeBridge.copyImageToClipboard(imageBytes2);

        final clipboardImageBytes = await QuillNativeBridge.getClipboardImage();
        final pixelMismatchPercentage =
            await compareImages(src1: imageBytes, src2: clipboardImageBytes);
        expect(pixelMismatchPercentage, isNot(0));

        final pixelMismatchPercentage2 =
            await compareImages(src1: imageBytes2, src2: clipboardImageBytes);
        expect(pixelMismatchPercentage2, 0);
      },
    );
  });

  group('getClipboardHTML and copyHTMLToClipbaord', () {
    test('copying HTML to the clipboard should make it accessible', () async {
      const htmlToCopy =
          '<div class="container"><h1>Test Document</h1><p>This is a <strong>sample</strong> paragraph with <a href="https://example.com">a link</a> and some <span style="color:red;">red text</span>.</p><ul><li>Item 1</li><li>Item 2</li><li>Item 3</li></ul><footer>Footer content here</footer></div>';
      await QuillNativeBridge.copyHTMLToClipboard(htmlToCopy);
      final clipboardHTML = await QuillNativeBridge.getClipboardHTML();
      expect(htmlToCopy, clipboardHTML);
    });

    test('copying HTML should return the HTML that was recently copied',
        () async {
      const html1 = '<pre style="font-family: monospace;">HTML</pre>';
      const html2 = '<div style="border: 1px solid;">HTML Div</div>';

      await QuillNativeBridge.copyHTMLToClipboard(html1);
      await QuillNativeBridge.copyHTMLToClipboard(html2);

      final clipboardHTML = await QuillNativeBridge.getClipboardHTML();
      expect(clipboardHTML, isNot(html1));
      expect(clipboardHTML, html2);
    });
    // TODO: See if there is a need for writing a similar test for getClipboardImage
    test(
      'getClipboardHTML should return the HTML content after copying HTML, '
      'and should no longer return HTML once an image (or any non-HTML item) '
      'has been copied to the clipboard after that.',
      () async {
        const html = '<pre style="font-family: monospace;">HTML</pre>';

        // Copy HTML to clipboard before copying an image

        await QuillNativeBridge.copyHTMLToClipboard(html);

        expect(
          await QuillNativeBridge.getClipboardHTML(),
          html,
        );

        // Image clipboard item
        final imageBytes = await loadAssetImage(kFlutterQuillAssetImage);
        await QuillNativeBridge.copyImageToClipboard(imageBytes);

        expect(
          await QuillNativeBridge.getClipboardHTML(),
          null,
        );

        // Copy HTML to clipboard before copying plain text

        await QuillNativeBridge.copyHTMLToClipboard(html);

        expect(
          await QuillNativeBridge.getClipboardHTML(),
          html,
        );

        // Plain text clipboard item
        const plainTextExample = 'Flutter Quill';
        services.Clipboard.setData(
          const services.ClipboardData(text: plainTextExample),
        );
        expect(
          (await services.Clipboard.getData(services.Clipboard.kTextPlain))
              ?.text,
          plainTextExample,
        );

        expect(
          await QuillNativeBridge.getClipboardHTML(),
          null,
        );
      },
    );
  });
}
