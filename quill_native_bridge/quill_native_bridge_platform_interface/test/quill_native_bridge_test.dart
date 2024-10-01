import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:quill_native_bridge_platform_interface/quill_native_bridge_platform_interface.dart';
import 'package:quill_native_bridge_platform_interface/src/quill_native_bridge_method_channel.dart';

class MockQuillNativeBridgePlatform
    with MockPlatformInterfaceMixin
    implements QuillNativeBridgePlatform {
  @override
  Future<bool> isSupported(QuillNativeBridgeFeature feature) async {
    return false;
  }

  @override
  Future<bool> isIOSSimulator() async => false;

  @override
  Future<String?> getClipboardHtml() async {
    return '<center>Invalid HTML</center>';
  }

  String? primaryHTMLClipbaord;

  @override
  Future<void> copyHtmlToClipboard(String html) async {
    primaryHTMLClipbaord = html;
  }

  Uint8List? primaryImageClipboard;

  @override
  Future<void> copyImageToClipboard(Uint8List imageBytes) async {
    primaryImageClipboard = imageBytes;
  }

  @override
  Future<Uint8List?> getClipboardImage() async {
    return Uint8List.fromList([0, 2, 1]);
  }

  @override
  Future<Uint8List?> getClipboardGif() async {
    return Uint8List.fromList([0, 1, 0]);
  }

  @override
  Future<List<String>> getClipboardFiles() async {
    return ['/path/to/file.html', 'path/to/file.md'];
  }
}

void main() {
  final initialPlatform = QuillNativeBridgePlatform.instance;

  test('$MethodChannelQuillNativeBridge is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelQuillNativeBridge>());
  });

  final fakePlatform = MockQuillNativeBridgePlatform();
  QuillNativeBridgePlatform.instance = fakePlatform;

  test('isIOSSimulator', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    expect(await QuillNativeBridgePlatform.instance.isIOSSimulator(), false);
  });

  test('getClipboardHtml()', () async {
    expect(
      await QuillNativeBridgePlatform.instance.getClipboardHtml(),
      '<center>Invalid HTML</center>',
    );
  });

  test('copyImageToClipboard()', () async {
    final imageBytes = Uint8List.fromList([]);
    expect(
      fakePlatform.primaryImageClipboard,
      null,
    );
    await QuillNativeBridgePlatform.instance.copyImageToClipboard(imageBytes);
    expect(
      fakePlatform.primaryImageClipboard,
      imageBytes,
    );
  });

  test('copyHtmlToClipboard()', () async {
    const html = '<pre>HTML</pre>';
    expect(
      fakePlatform.primaryHTMLClipbaord,
      null,
    );
    await QuillNativeBridgePlatform.instance.copyHtmlToClipboard(html);
    expect(
      fakePlatform.primaryHTMLClipbaord,
      html,
    );
  });

  test('getClipboardImage()', () async {
    expect(
      await QuillNativeBridgePlatform.instance.getClipboardImage(),
      Uint8List.fromList([0, 2, 1]),
    );
  });

  test('getClipboardGif()', () async {
    expect(
      await QuillNativeBridgePlatform.instance.getClipboardGif(),
      Uint8List.fromList([0, 1, 0]),
    );
  });
  test('getClipboardFiles()', () async {
    expect(
      await QuillNativeBridgePlatform.instance.getClipboardFiles(),
      ['/path/to/file.html', 'path/to/file.md'],
    );
  });
}
