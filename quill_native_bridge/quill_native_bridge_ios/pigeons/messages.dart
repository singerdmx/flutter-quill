import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(PigeonOptions(
  dartOut: 'lib/src/messages.g.dart',
  swiftOut: 'ios/Classes/Messages.g.swift',
  dartPackageName: 'quill_native_bridge_ios',
))
@HostApi()
abstract class QuillNativeBridgeApi {
  bool isIosSimulator();

  // HTML
  String? getClipboardHtml();
  void copyHtmlToClipboard(String html);

  // Image
  Uint8List? getClipboardImage();
  void copyImageToClipboard(Uint8List imageBytes);
  Uint8List? getClipboardGif();
}
