class Embeddable {
  static const TYPE_KEY = '_type';
  static const INLINE_KEY = '_inline';
  final String type;
  final bool inline;
  final Map<String, dynamic> _data;

  Embeddable(this.type, this.inline, Map<String, dynamic> data)
      : assert(type != null),
        assert(inline != null),
        _data = Map.from(data);

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
