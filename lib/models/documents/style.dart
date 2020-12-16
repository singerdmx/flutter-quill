import 'package:flutter_quill/models/documents/attribute.dart';

/* Collection of style attributes */
class Style {
  final Map<String, Attribute> _attributes;

  Style.attr(this._attributes);

  Style() : _attributes = <String, Attribute>{};

  static Style fromJson(Map<String, dynamic> attributes) {
    if (attributes == null) {
      return Style();
    }

    Map<String, Attribute> result = attributes.map((String key, dynamic value) {
      var attr = Attribute.fromKeyValue(key, value);
      return MapEntry<String, Attribute>(key, attr);
    });
    return Style.attr(result);
  }

  Iterable<String> get keys => _attributes.keys;

  Iterable<Attribute> get values => _attributes.values;

  bool get isEmpty => _attributes.isEmpty;

  bool get isNotEmpty => _attributes.isNotEmpty;

  bool get isInline => isNotEmpty && values.every((item) => item.isInline);

  Attribute get single => _attributes.values.single;

  bool containsKey(String key) => _attributes.containsKey(key);
}
