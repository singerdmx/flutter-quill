import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:quill_native_bridge/quill_native_bridge.dart';
import 'package:quill_native_bridge/src/quill_native_bridge_method_channel.dart';

class MockQuillNativeBridgePlatform
    with MockPlatformInterfaceMixin
    implements QuillNativeBridgePlatform {
  @override
  Future<bool> isIOSSimulator() async => false;

  @override
  Future<String?> getClipboardHTML() async {
    return '<center>Invalid HTML</center>';
  }

  String? primaryHTMLClipbaord;

  @override
  Future<void> copyHTMLToClipboard(String html) async {
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
    expect(await QuillNativeBridge.isIOSSimulator(), false);
  });

  test('getClipboardHTML()', () async {
    expect(
      await QuillNativeBridgePlatform.instance.getClipboardHTML(),
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

  test('copyHTMLToClipboard()', () async {
    const html = '<pre>HTML</pre>';
    expect(
      fakePlatform.primaryHTMLClipbaord,
      null,
    );
    await QuillNativeBridgePlatform.instance.copyHTMLToClipboard(html);
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
}