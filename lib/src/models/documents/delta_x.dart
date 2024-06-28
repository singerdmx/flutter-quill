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
  static Delta fromMarkdown(
    String markdownText, {
    Md2DeltaConfigs md2DeltaConfigs = const Md2DeltaConfigs(),
  }) {
    final mdDocument = md.Document(encodeHtml: false);
    final mdToDelta = MarkdownToDelta(
      markdownDocument: mdDocument,
      customElementToBlockAttribute:
          md2DeltaConfigs.customElementToBlockAttribute,
      customElementToEmbeddable: md2DeltaConfigs.customElementToEmbeddable,
      customElementToInlineAttribute:
          md2DeltaConfigs.customElementToInlineAttribute,
      softLineBreak: md2DeltaConfigs.softLineBreak,
    );
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
  static Delta fromHtml(String htmlText, {Html2MdConfigs? configs}) {
    final markdownText = html2md
        .convert(
          htmlText,
          rules: configs?.customRules,
          ignore: configs?.ignoreIf,
          rootTag: configs?.rootTag,
          imageBaseUrl: configs?.imageBaseUrl,
          styleOptions: configs?.styleOptions,
        )
        .replaceAll(
          'unsafe:',
          '',
        );
    return fromMarkdown(markdownText);
  }
}

@immutable
@experimental
class Md2DeltaConfigs {
  const Md2DeltaConfigs({
    this.customElementToInlineAttribute = const {},
    this.customElementToBlockAttribute = const {},
    this.customElementToEmbeddable = const {},
    this.softLineBreak = false,
  });
  final Map<String, ElementToAttributeConvertor> customElementToInlineAttribute;
  final Map<String, ElementToAttributeConvertor> customElementToBlockAttribute;
  final Map<String, ElementToEmbeddableConvertor> customElementToEmbeddable;
  final bool softLineBreak;
}

@immutable
@experimental
class Html2MdConfigs {
  const Html2MdConfigs({
    this.customRules,
    this.ignoreIf,
    this.rootTag,
    this.imageBaseUrl,
    this.styleOptions = const {'emDelimiter': '*'},
    //emDelimiter set em to be "*" instead a "_"
  });

  /// The [rules] parameter can be used to customize element processing.
  final List<html2md.Rule>? customRules;

  /// Elements list in [ignore] would be ingored.
  final List<String>? ignoreIf;

  final String? rootTag;
  final String? imageBaseUrl;

  /// The default and available style options:
  ///
  /// | Name        | Default           | Options  |
  /// | ------------- |:-------------:| -----:|
  /// | headingStyle      | "setext" | "setext", "atx" |
  /// | hr      | "* * *" | "* * *", "- - -", "_ _ _" |
  /// | bulletListMarker      | "*" | "*", "-", "_" |
  /// | codeBlockStyle      | "indented" | "indented", "fenced" |
  /// | fence      | "\`\`\`" | "\`\`\`", "~~~" |
  /// | emDelimiter      | "_" | "_", "*" |
  /// | strongDelimiter      | "**" | "**", "__" |
  /// | linkStyle      | "inlined" | "inlined", "referenced" |
  /// | linkReferenceStyle      | "full" | "full", "collapsed", "shortcut" |
  final Map<String, String>? styleOptions;
}
