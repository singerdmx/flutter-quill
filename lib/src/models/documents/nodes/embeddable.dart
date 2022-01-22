/// An object which can be embedded into a Quill document.
class Embeddable {
  const Embeddable(this.type, this.data);

  /// The type of this object.
  final String type;

  /// The data payload of this object.
  final String data;

  Map<String, String> toJson() {
    final m = <String, String>{type: data};
    return m;
  }

  static Embeddable fromJson(Map<String, String> json) {
    final m = Map<String, String>.from(json);
    assert(m.length == 1, 'Embeddable map must only have one key');

    return Embeddable(m.keys.single, m.values.single);
  }

  static const String imageType = 'image';
  static Embeddable image(String imageUrl) => Embeddable(imageType, imageUrl);

  static const String videoType = 'video';
  static Embeddable video(String videoUrl) => Embeddable(videoType, videoUrl);
}
