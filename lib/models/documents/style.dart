import 'package:collection/collection.dart';
import 'package:flutter_quill/models/documents/attribute.dart';
import 'package:quiver/core.dart';

/* Collection of style attributes */
class Style {
  final Map<String, Attribute> _attributes;

  Style.attr(this._attributes);

  Style() : _attributes = <String, Attribute>{};

  static Style fromJson(Map<String, dynamic>? attributes) {
    if (attributes == null) {
      return Style();
    }

    Map<String, Attribute> result = attributes.map((String key, dynamic value) {
      Attribute attr = Attribute.fromKeyValue(key, value);
      return MapEntry<String, Attribute>(key, attr);
    });
    return Style.attr(result);
  }

  Map<String, dynamic>? toJson() => _attributes.isEmpty
      ? null
      : _attributes.map<String, dynamic>((String _, Attribute attribute) =>
          MapEntry<String, dynamic>(attribute.key, attribute.value));

  Iterable<String> get keys => _attributes.keys;

  Iterable<Attribute> get values => _attributes.values;

  Map<String, Attribute> get attributes => _attributes;

  bool get isEmpty => _attributes.isEmpty;

  bool get isNotEmpty => _attributes.isNotEmpty;

  bool get isInline => isNotEmpty && values.every((item) => item.isInline);

  bool get isIgnored =>
      isNotEmpty && values.every((item) => item.scope == AttributeScope.IGNORE);

  Attribute get single => _attributes.values.single;

  bool containsKey(String key) => _attributes.containsKey(key);

  Attribute? getBlockExceptHeader() {
    for (Attribute val in values) {
      if (val.isBlockExceptHeader) {
        return val;
      }
    }
    return null;
  }

  Style merge(Attribute attribute) {
    Map<String, Attribute> merged = Map<String, Attribute>.from(_attributes);
    if (attribute.value == null) {
      merged.remove(attribute.key);
    } else {
      merged[attribute.key] = attribute;
    }
    return Style.attr(merged);
  }

  Style mergeAll(Style other) {
    Style result = Style.attr(_attributes);
    for (Attribute attribute in other.values) {
      result = result.merge(attribute);
    }
    return result;
  }

  Style removeAll(Set<Attribute> attributes) {
    Map<String, Attribute> merged = Map<String, Attribute>.from(_attributes);
    attributes.map((item) => item.key).forEach(merged.remove);
    return Style.attr(merged);
  }

  Style put(Attribute attribute) {
    Map<String, Attribute> m = Map<String, Attribute>.from(attributes);
    m[attribute.key] = attribute;
    return Style.attr(m);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Style) {
      return false;
    }
    Style typedOther = other;
    final eq = const MapEquality<String, Attribute>();
    return eq.equals(_attributes, typedOther._attributes);
  }

  @override
  int get hashCode {
    final hashes =
        _attributes.entries.map((entry) => hash2(entry.key, entry.value));
    return hashObjects(hashes);
  }

  @override
  String toString() => "{${_attributes.values.join(', ')}}";
}
