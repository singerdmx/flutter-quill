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
}

void main() {
  final initialPlatform = QuillNativeBridgePlatform.instance;

  test('$MethodChannelQuillNativeBridge is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelQuillNativeBridge>());
  });

  test('isIOSSimulator', () async {
    final fakePlatform = MockQuillNativeBridgePlatform();
    QuillNativeBridgePlatform.instance = fakePlatform;

    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    expect(await QuillNativeBridge.isIOSSimulator(), false);
  });
}
