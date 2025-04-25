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

/// This attribute highlights text associated with a comment, using a comment identifier.
/// The value is the comment ID, which can be used to look up the comment in Firestore
/// and retrieve the highlight color.
///
/// The attribute in JSON looks like: "attributes":{"comment-highlight": "f12edf4f-8be9-4b1d-a264-f35371613c1e"}
class CommentHighlightAttribute extends Attribute<String?> {
  const CommentHighlightAttribute({String? commentId})
      : super('comment-highlight', AttributeScope.inline, commentId);
}
