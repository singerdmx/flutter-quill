// ignore_for_file: implementation_imports

import 'package:html2md/html2md.dart' as hmd;
import 'package:markdown/markdown.dart' as md;
import 'package:markdown/src/ast.dart' as ast;
import 'package:markdown/src/util.dart' as util;
import 'package:meta/meta.dart';

// [ character
const int $lbracket = 0x5B;
final RegExp youtubeVideoUrlValidator = RegExp(
    r'^(?:https?:)?(?:\/\/)?(?:youtu\.be\/|(?:www\.|m\.)?youtube\.com\/(?:watch|v|embed)(?:\.php)?(?:\?.*v=|\/))([a-zA-Z0-9\_-]{7,15})(?:[\?&][a-zA-Z0-9\_-]+=[a-zA-Z0-9\_-]+)*(?:[&\/\#].*)?$');

///Local syntax implementation for underline
class UnderlineSyntax extends md.DelimiterSyntax {
  UnderlineSyntax()
      : super(
          '<und>',
          requiresDelimiterRun: true,
          allowIntraWord: true,
          tags: [md.DelimiterTag('u', 5)],
        );
}

class VideoSyntax extends md.LinkSyntax {
  VideoSyntax({super.linkResolver})
      : super(
          pattern: r'\[',
          startCharacter: $lbracket,
        );

  @override
  ast.Element createNode(
    String destination,
    String? title, {
    required List<ast.Node> Function() getChildren,
  }) {
    final element = md.Element.empty('video');
    element.attributes['src'] = util.normalizeLinkDestination(
      util.escapePunctuation(destination),
    );
    if (title != null && title.isNotEmpty) {
      element.attributes['title'] = util.normalizeLinkTitle(title);
    }
    return element;
  }
}

class Html2MdRules {
  const Html2MdRules._();

  ///This rule avoid the default converter from html2md ignore underline tag for <u> or <ins>
  static final underlineRule = hmd.Rule('underline', filters: ['u', 'ins'],
      replacement: (content, node) {
    //Is used a local underline implemenation since markdown just use underline with html tags
    return '<und>$content<und>';
  });
  static final videoRule =
      hmd.Rule('video', filters: ['iframe'], replacement: (content, node) {
    //by now, we can only access to src
    final src = node.getAttribute('src');
    //if the source is null or is not valid youtube url, then just return the html instead remove it
    //by now is only available validation for youtube videos
    if (src == null || !youtubeVideoUrlValidator.hasMatch(src)) {
      return node.outerHTML;
    }
    final title = node.getAttribute('title');
    return '[$title]($src)';
  });
}

@experimental
class Html2MdConfigs {
  const Html2MdConfigs({
    this.customRules,
    this.ignoreIf,
    this.rootTag,
    this.imageBaseUrl,
    this.styleOptions,
  });

  /// The [rules] parameter can be used to customize element processing.
  final List<hmd.Rule>? customRules;

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
