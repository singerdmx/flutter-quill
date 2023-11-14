import 'package:meta/meta.dart' show immutable;

@immutable
class ImageUrl {
  const ImageUrl(
    this.url,
    this.styleString,
  );

  final String url;
  final String styleString;
}
