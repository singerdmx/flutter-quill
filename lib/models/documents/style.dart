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
}
