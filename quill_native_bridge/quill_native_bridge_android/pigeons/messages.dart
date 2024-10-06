import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(PigeonOptions(
  dartOut: 'lib/src/messages.g.dart',
  // Using `GeneratedMessages.kt` instead of `Messages.g.kt` to follow
  // Kotlin conventions: https://kotlinlang.org/docs/coding-conventions.html#source-file-names
  kotlinOut:
      'android/src/main/kotlin/dev/flutterquill/quill_native_bridge/generated/GeneratedMessages.kt',
  kotlinOptions: KotlinOptions(
    package: 'dev.flutterquill.quill_native_bridge.generated',
  ),
  dartPackageName: 'quill_native_bridge_android',
))
@HostApi()
abstract class QuillNativeBridgeApi {
  // HTML
  String? getClipboardHtml();
  void copyHtmlToClipboard(String html);

  // Image
  Uint8List? getClipboardImage();
  void copyImageToClipboard(Uint8List imageBytes);
  Uint8List? getClipboardGif();
}
