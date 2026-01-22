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

/// This attribute represents a user mention. The mention can contain
/// user ID and display name.
///
/// The attribute at the json looks like: "attributes":{"mention": {"id": "123", "name": "John Doe"} }
class MentionAttribute extends Attribute<Map<String, dynamic>?> {
  const MentionAttribute({Map<String, dynamic>? value})
      : super('mention', AttributeScope.inline, value);
}

/// This attribute represents a hashtag. The tag can contain
/// tag ID and display name.
///
/// The attribute at the json looks like: "attributes":{"tag": {"id": "456", "name": "flutter"} }
class TagAttribute extends Attribute<Map<String, dynamic>?> {
  const TagAttribute({Map<String, dynamic>? value})
      : super('tag', AttributeScope.inline, value);
}

/// This attribute represents a currency tag (dollar tag). The currency tag can contain
/// tag ID and display name/value.
///
/// The attribute at the json looks like: "attributes":{"currency": {"id": "789", "name": "1000"} }
class CurrencyAttribute extends Attribute<Map<String, dynamic>?> {
  const CurrencyAttribute({Map<String, dynamic>? value})
      : super('currency', AttributeScope.inline, value);
}
