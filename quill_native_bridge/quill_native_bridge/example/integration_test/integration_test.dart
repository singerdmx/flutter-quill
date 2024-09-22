import 'package:flutter/services.dart' show Uint8List, rootBundle;
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
    // TODO: copyHTMLToClipbaord() is missing.
    // const htmlToCopy =
    //     '<div class="container"><h1>Test Document</h1><p>This is a <strong>sample</strong> paragraph with <a href="https://example.com">a link</a> and some <span style="color:red;">red text</span>.</p><ul><li>Item 1</li><li>Item 2</li><li>Item 3</li></ul><footer>Footer content here</footer></div>';
    // QuillNativeBridge.copyHTMLToClipboard(htmlToCopy);
    // final clipboardHTML = QuillNativeBridge.getClipboardHTML();
    // expect(htmlToCopy, clipboardHTML);
  });
}

Future<Uint8List> loadAssetImage(String assetPath) async {
  return (await rootBundle.load(assetPath)).buffer.asUint8List();
}
