import 'package:html2md/html2md.dart' as hmd;
import 'package:markdown/markdown.dart' as md;

// [ character
const int _$lbracket = 0x5B;
final RegExp _youtubeVideoUrlValidator = RegExp(
    r'^((?:https?:)?\/\/)?((?:www|m)\.)?((?:youtube\.com|youtu.be))(\/(?:[\w\-]+\?v=|embed\/|v\/)?)([\w\-]+)(\S+)?$');

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
          startCharacter: _$lbracket,
        );

  @override
  md.Element createNode(
    String destination,
    String? title, {
    required List<md.Node> Function() getChildren,
  }) {
    final element = md.Element.empty('video');
    element.attributes['src'] = destination;
    if (title != null && title.isNotEmpty) {
      element.attributes['title'] = title;
    }
    return element;
  }
}

///This rule avoid the default converter from html2md ignore underline tag for <u> or <ins>
final underlineRule =
    hmd.Rule('underline', filters: ['u', 'ins'], replacement: (content, node) {
  //Is used a local underline implemenation since markdown just use underline with html tags
  return '<und>$content<und>';
});
final videoRule = hmd.Rule('video', filters: ['iframe', 'video'],
    replacement: (content, node) {
  //This need to be verified by a different way of iframes, since video tag can have <source> children
  if (node.nodeName == 'video') {
    //if has children then just will be taked as different part of code
    if (node.childNum > 0) {
      var child = node.firstChild!;
      var src = child.getAttribute('src');
      if (src == null) {
        child = node.childNodes().last;
        src = child.getAttribute('src');
      }
      if (!_youtubeVideoUrlValidator.hasMatch(src ?? '')) {
        return '<video>${child.outerHTML}</video>';
      }
      return '[$content]($src)';
    }
    final src = node.getAttribute('src');
    if (src == null || !_youtubeVideoUrlValidator.hasMatch(src)) {
      return node.outerHTML;
    }
    return '[$content]($src)';
  }
  //by now, we can only access to src
  final src = node.getAttribute('src');
  //if the source is null or is not valid youtube url, then just return the html instead remove it
  //by now is only available validation for youtube videos
  if (src == null || !_youtubeVideoUrlValidator.hasMatch(src)) {
    return node.outerHTML;
  }
  final title = node.getAttribute('title');
  return '[$title]($src)';
});
