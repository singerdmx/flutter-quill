import 'attribute.dart';

// Attributes that don't conform to standard Quill Delta
// and are not compatible with https://quilljs.com/docs/delta/

/// This attribute represents the space between text lines. The line height can be
/// adjusted using predefined constants or custom values
///
/// The attribute at the json looks like: "attributes":{"line-height": 1.5 }
class LineHeightAttribute extends Attribute<double?> {
  const LineHeightAttribute({double? lineHeight})
      : super('line-height', AttributeScope.block, lineHeight);

  static const Attribute<double?> lineHeightNormal =
      LineHeightAttribute(lineHeight: 1);

  static const Attribute<double?> lineHeightTight =
      LineHeightAttribute(lineHeight: 1.15);

  static const Attribute<double?> lineHeightOneAndHalf =
      LineHeightAttribute(lineHeight: 1.5);

  static const Attribute<double?> lineHeightDouble =
      LineHeightAttribute(lineHeight: 2);
}

/// This attribute highlights text associated with a comment, using a comment identifier
/// and a highlight color. The value is a map containing the comment ID (key: 'id') and
/// the color code (key: 'color').
///
/// The attribute in JSON looks like: "attributes":{"comment-highlight": {"id": "12345id", "color": "#FFFFFF"}}
class CommentHighlightAttribute extends Attribute<Map<String, String>?> {
  const CommentHighlightAttribute({Map<String, String>? val})
      : super('comment-highlight', AttributeScope.inline, val);
}
