import 'package:flutter/services.dart' show Uint8List, rootBundle;

const kFlutterQuillAssetImage = 'assets/flutter-quill.png';
const kQuillJsRichTextEditor = 'assets/quilljs-rich-text-editor.png';

Future<Uint8List> loadAssetFile(String assetFilePath) async {
  return (await rootBundle.load(assetFilePath)).buffer.asUint8List();
}
