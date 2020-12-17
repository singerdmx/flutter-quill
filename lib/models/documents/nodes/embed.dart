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
}
