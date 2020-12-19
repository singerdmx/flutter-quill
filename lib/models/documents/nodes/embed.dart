import 'dart:collection';

class Embeddable {
  static const TYPE_KEY = '_type';
  static const INLINE_KEY = '_inline';
  final String type;
  final bool inline;
  final Map<String, dynamic> _data;

  Embeddable(this.type, this.inline, Map<String, dynamic> data)
      : assert(type != null),
        assert(inline != null),
        assert(!data.containsKey(TYPE_KEY)),
        assert(!data.containsKey(INLINE_KEY)),
        _data = Map.from(data);

  Map<String, dynamic> get data => UnmodifiableMapView(_data);

  Map<String, dynamic> toJson() {
    Map<String, dynamic> m = Map<String, dynamic>.from(_data);
    m[TYPE_KEY] = type;
    m[INLINE_KEY] = inline;
    return m;
  }

  static Embeddable fromJson(Map<String, dynamic> json) {
    String type = json[TYPE_KEY] as String;
    bool inline = json[INLINE_KEY] as bool;
    Map<String, dynamic> data = Map<String, dynamic>.from(json);
    data.remove(TYPE_KEY);
    data.remove(INLINE_KEY);
    if (inline) {
      return Span(type, data: data);
    }
    return BlockEmbed(type, data: data);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Embeddable &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          inline == other.inline &&
          _data == other._data;

  @override
  int get hashCode => type.hashCode ^ inline.hashCode ^ _data.hashCode;
}

class Span extends Embeddable {
  Span(
    String type, {
    Map<String, dynamic> data = const {},
  }) : super(type, true, data);
}

class BlockEmbed extends Embeddable {
  BlockEmbed(
    String type, {
    Map<String, dynamic> data = const {},
  }) : super(type, false, data);
}
