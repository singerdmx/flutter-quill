import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:quill_native_bridge/quill_native_bridge.dart';
import 'package:quill_native_bridge/src/quill_native_bridge_method_channel.dart';
import 'package:quill_native_bridge/src/quill_native_bridge_platform_interface.dart';

class MockQuillNativeBridgePlatform
    with MockPlatformInterfaceMixin
    implements QuillNativeBridgePlatform {
  @override
  Future<bool> isIOSSimulator() async => false;

  @override
  Future<String?> getClipboardHTML() async {
    return '<center>Invalid HTML</center>';
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
}
