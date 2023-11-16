// import 'dart:convert' show jsonDecode, jsonEncode;

// import 'package:flutter/widgets.dart';
// import 'package:flutter_inappwebview/flutter_inappwebview.dart';
// import 'package:flutter_quill/flutter_quill.dart';
// import 'package:meta/meta.dart' show experimental;

// import '../../models/config/editor/webview.dart';

// @experimental
// class QuillEditorWebViewBlockEmbed extends CustomBlockEmbed {
//   const QuillEditorWebViewBlockEmbed(
//     String value,
//   ) : super(webViewType, value);

//   factory QuillEditorWebViewBlockEmbed.fromDocument(Document document) =>
//       QuillEditorWebViewBlockEmbed(jsonEncode(document.toDelta().toJson()));

//   static const String webViewType = 'webview';

//   Document get document => Document.fromJson(jsonDecode(data));
// }

// @experimental
// class QuillEditorWebViewEmbedBuilder extends EmbedBuilder {
//   const QuillEditorWebViewEmbedBuilder({
//     required this.configurations,
//   });

//   @override
//   bool get expanded => false;

//   final QuillEditorWebViewEmbedConfigurations configurations;
//   @override
//   Widget build(
//     BuildContext context,
//     QuillController controller,
//     Embed node,
//     bool readOnly,
//     bool inline,
//     TextStyle textStyle,
//   ) {
//     final url = node.value.data as String;

//     return SizedBox(
//       width: double.infinity,
//       height: 200,
//       child: InAppWebView(
//         initialUrlRequest: URLRequest(
//           url: Uri.parse(url),
//         ),
//       ),
//     );
//   }

//   @override
//   String get key => 'webview';
// }
