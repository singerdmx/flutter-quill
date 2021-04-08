class Embeddable {
  final String type;
  final dynamic data;

  Embeddable(this.type, this.data);

  Map<String, dynamic> toJson() {
    final m = <String, String>{type: data};
    return m;
  }

  static Embeddable fromJson(Map<String, dynamic> json) {
    final m = Map<String, dynamic>.from(json);
    assert(m.length == 1, 'Embeddable map has one key');

    return BlockEmbed(m.keys.first, m.values.first);
  }
}

class BlockEmbed extends Embeddable {
  BlockEmbed(String type, String data) : super(type, data);

  static final BlockEmbed horizontalRule = BlockEmbed('divider', 'hr');

  static BlockEmbed image(String imageUrl) => BlockEmbed('image', imageUrl);
}
