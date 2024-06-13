import 'package:html2md/html2md.dart' as html2md;
import 'package:markdown/markdown.dart' as md;
import 'package:meta/meta.dart';

import '../../../markdown_quill.dart';
import '../../../quill_delta.dart';

@immutable
@experimental
class DeltaX {
  const DeltaX._();

  /// Convert Markdown text to [Delta]
  ///
  /// This api is **experimental** and designed to be used **internally** and shouldn't
  /// used for **production applications**.
  @experimental
  static Delta fromMarkdown(String markdownText) {
    final mdDocument = md.Document(encodeHtml: false);
    final mdToDelta = MarkdownToDelta(markdownDocument: mdDocument);
    return mdToDelta.convert(markdownText);
  }

  /// Convert the HTML Raw string to [Delta]
  ///
  /// It will run using the following steps:
  ///
  /// 1. Convert the html to markdown string using `html2md` package
  /// 2. Convert the markdown string to [Delta] using [fromMarkdown]
  ///
  /// This api is **experimental** and designed to be used **internally** and shouldn't
  /// used for **production applications**.
  ///
  @experimental
  static Delta fromHtml(String htmlText) {
    final markdownText = html2md.convert(htmlText).replaceAll('unsafe:', '');

    return fromMarkdown(markdownText);
  }
}
