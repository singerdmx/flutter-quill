import 'package:meta/meta.dart';
import 'package:quill_native_bridge/quill_native_bridge.dart';

abstract final class QuillNativeProvider {
  static QuillNativeBridge _instance = QuillNativeBridge();

  static QuillNativeBridge get instance => _instance;

  /// Creates a static instance of [QuillNativeBridge], allowing it to be overridden in tests.
  @visibleForTesting
  static set instance(QuillNativeBridge value) => _instance = value;
}
