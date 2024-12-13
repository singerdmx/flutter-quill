import 'package:meta/meta.dart';
import 'package:quill_native_bridge/quill_native_bridge.dart';

export 'package:quill_native_bridge/quill_native_bridge.dart';

@visibleForTesting
typedef DefaultQuillNativeBridge = QuillNativeBridge;

abstract final class QuillNativeProvider {
  static QuillNativeBridge _instance = DefaultQuillNativeBridge();

  static QuillNativeBridge get instance => _instance;

  /// Allows overriding the instance for testing.
  /// Pass `null` to restore the default instance.
  @visibleForTesting
  static set instance(QuillNativeBridge? newInstance) =>
      _instance = newInstance ?? DefaultQuillNativeBridge();
}
