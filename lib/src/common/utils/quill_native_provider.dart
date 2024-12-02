import 'package:meta/meta.dart';
import 'package:quill_native_bridge/quill_native_bridge.dart';

export 'package:quill_native_bridge/quill_native_bridge.dart';

@visibleForTesting
typedef DefaultQuillNativeBridge = QuillNativeBridge;

abstract final class QuillNativeProvider {
  static QuillNativeBridge _instance = DefaultQuillNativeBridge();

  static QuillNativeBridge get instance => _instance;

  /// Creates a static instance of [DefaultQuillNativeBridge], allowing it to be overridden in tests.
  /// Pass `null` to restore the default instance.
  @visibleForTesting
  static set instance(QuillNativeBridge? value) =>
      _instance = value ?? DefaultQuillNativeBridge();
}
