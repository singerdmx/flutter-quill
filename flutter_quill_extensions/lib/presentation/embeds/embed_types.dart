import 'package:cross_file/cross_file.dart' show XFile;

typedef MediaFileUrl = String;
typedef MediaFilePicker = Future<XFile?> Function(QuillMediaType mediaType);
typedef MediaPickedCallback = Future<MediaFileUrl> Function(XFile file);

enum QuillMediaType { image, video }

extension QuillMediaTypeX on QuillMediaType {
  bool get isImage => this == QuillMediaType.image;
  bool get isVideo => this == QuillMediaType.video;
}
