import 'package:flutter/services.dart' show Uint8List, rootBundle;

const kFlutterQuillAssetImage = 'assets/flutter-quill.png';
const kQuillJsRichTextEditor = 'assets/quilljs-rich-text-editor.png';

Future<Uint8List> loadAssetImage(String assetPath) async {
  return (await rootBundle.load(assetPath)).buffer.asUint8List();
}
