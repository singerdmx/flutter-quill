import 'package:html2md/html2md.dart' as html2md;
import 'package:markdown/markdown.dart' as md;
import 'package:meta/meta.dart';

import '../../../markdown_quill.dart';
import '../../../quill_delta.dart';

@immutable
class DeltaX {
  /// Convert the HTML Raw string to [Delta]
  ///
  /// It will run using the following steps:
  ///
  /// 1. Convert the html to markdown string using `html2md` package
  /// 2. Convert the markdown string to quill delta json string
  /// 3. Decode the delta json string to [Delta]
  ///
  /// for more [info](https://github.com/singerdmx/flutter-quill/issues/1100)
  ///
  /// Please notice that this api is designed to be used internally and shouldn't
  /// used for real world applications
  ///
  @experimental
  static Delta fromHtml(String html) {
    final markdown = html2md
        .convert(
          html,
        )
        .replaceAll('unsafe:', '');

    final mdDocument = md.Document(encodeHtml: false);

    final mdToDelta = MarkdownToDelta(markdownDocument: mdDocument);

    return mdToDelta.convert(markdown);

    // final deltaJsonString = markdownToDelta(markdown);
    // final deltaJson = jsonDecode(deltaJsonString);
    // if (deltaJson is! List) {
    //   throw ArgumentError(
    //     'The delta json string should be of type list when jsonDecode() it',
    //   );
    // }
    // return Delta.fromJson(
    //   deltaJson,
    // );
  }
}
