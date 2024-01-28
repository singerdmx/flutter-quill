import 'package:collection/collection.dart';
import 'package:quiver/core.dart';

/// Decoder function to convert raw `data` object into a user-defined data type.
///
/// Useful with embedded content.
typedef DataDecoder = Object? Function(Object data);

/// Default data decoder which simply passes through the original value.
Object? _passThroughDataDecoder(Object? data) => data;

const _attributeEquality = DeepCollectionEquality();
const _valueEquality = DeepCollectionEquality();

/// Operation performed on a rich-text document.
class Operation {
  Operation(this.key, this.length, this.data, Map? attributes)
      : assert(_validKeys.contains(key), 'Invalid operation key "$key".'),
        assert(() {
          if (key != Operation.insertKey) return true;
          return data is String ? data.length == length : length == 1;
        }(), 'Length of insert operation must be equal to the data length.'),
        _attributes =
            attributes != null ? Map<String, dynamic>.from(attributes) : null;

  /// Creates operation which deletes [length] of characters.
  factory Operation.delete(int length) =>
      Operation(Operation.deleteKey, length, '', null);

  /// Creates operation which inserts [text] with optional [attributes].
  factory Operation.insert(dynamic data, [Map<String, dynamic>? attributes]) =>
      Operation(Operation.insertKey, data is String ? data.length : 1, data,
          attributes);

  /// Creates operation which retains [length] of characters and optionally
  /// applies attributes.
  factory Operation.retain(int? length, [Map<String, dynamic>? attributes]) =>
      Operation(Operation.retainKey, length, '', attributes);

  /// Key of insert operations.
  static const String insertKey = 'insert';

  /// Key of delete operations.
  static const String deleteKey = 'delete';

  /// Key of retain operations.
  static const String retainKey = 'retain';

  /// Key of attributes collection.
  static const String attributesKey = 'attributes';

  static const List<String> _validKeys = [insertKey, deleteKey, retainKey];

  /// Key of this operation, can be "insert", "delete" or "retain".
  final String key;

  /// Length of this operation.
  final int? length;

  /// Payload of "insert" operation, for other types is set to empty string.
  final Object? data;

  /// Rich-text attributes set by this operation, can be `null`.
  Map<String, dynamic>? get attributes =>
      _attributes == null ? null : Map<String, dynamic>.from(_attributes);
  final Map<String, dynamic>? _attributes;

  /// Creates new [Operation] from JSON payload.
  ///
  /// If `dataDecoder` parameter is not null then it is used to additionally
  /// decode the operation's data object. Only applied to insert operations.
  static Operation fromJson(Map data, {DataDecoder? dataDecoder}) {
    dataDecoder ??= _passThroughDataDecoder;
    final map = Map<String, dynamic>.from(data);
    if (map.containsKey(Operation.insertKey)) {
      final data = dataDecoder(map[Operation.insertKey]);
      final dataLength = data is String ? data.length : 1;
      return Operation(
          Operation.insertKey, dataLength, data, map[Operation.attributesKey]);
    } else if (map.containsKey(Operation.deleteKey)) {
      final int? length = map[Operation.deleteKey];
      return Operation(Operation.deleteKey, length, '', null);
    } else if (map.containsKey(Operation.retainKey)) {
      final int? length = map[Operation.retainKey];
      return Operation(
          Operation.retainKey, length, '', map[Operation.attributesKey]);
    }
    throw ArgumentError.value(data, 'Invalid data for Delta operation.');
  }

  /// Returns JSON-serializable representation of this operation.
  Map<String, dynamic> toJson() {
    final json = {key: value};
    if (_attributes != null) json[Operation.attributesKey] = attributes;
    return json;
  }

  /// Returns value of this operation.
  ///
  /// For insert operations this returns text, for delete and retain - length.
  dynamic get value => (key == Operation.insertKey) ? data : length;

  /// Returns `true` if this is a delete operation.
  bool get isDelete => key == Operation.deleteKey;

  /// Returns `true` if this is an insert operation.
  bool get isInsert => key == Operation.insertKey;

  /// Returns `true` if this is a retain operation.
  bool get isRetain => key == Operation.retainKey;

  /// Returns `true` if this operation has no attributes, e.g. is plain text.
  bool get isPlain => _attributes == null || _attributes.isEmpty;

  /// Returns `true` if this operation sets at least one attribute.
  bool get isNotPlain => !isPlain;

  /// Returns `true` is this operation is empty.
  ///
  /// An operation is considered empty if its [length] is equal to `0`.
  bool get isEmpty => length == 0;

  /// Returns `true` is this operation is not empty.
  bool get isNotEmpty => length! > 0;

  @override
  bool operator ==(other) {
    if (identical(this, other)) return true;
    if (other is! Operation) return false;
    final typedOther = other;
    return key == typedOther.key &&
        length == typedOther.length &&
        _valueEquality.equals(data, typedOther.data) &&
        hasSameAttributes(typedOther);
  }

  /// Returns `true` if this operation has attribute specified by [name].
  bool hasAttribute(String name) =>
      isNotPlain && _attributes!.containsKey(name);

  /// Returns `true` if [other] operation has the same attributes as this one.
  bool hasSameAttributes(Operation other) {
    // treat null and empty equal
    if ((_attributes?.isEmpty ?? true) &&
        (other._attributes?.isEmpty ?? true)) {
      return true;
    }
    return _attributeEquality.equals(_attributes, other._attributes);
  }

  @override
  int get hashCode {
    if (_attributes != null && _attributes.isNotEmpty) {
      final attrsHash =
          hashObjects(_attributes.entries.map((e) => hash2(e.key, e.value)));
      return hash3(key, value, attrsHash);
    }
    return hash2(key, value);
  }

  @override
  String toString() {
    final attr = attributes == null ? '' : ' + $attributes';
    final text = isInsert
        ? (data is String
            ? (data as String).replaceAll('\n', '⏎')
            : data.toString())
        : '$length';
    return '$key⟨ $text ⟩$attr';
  }
}
