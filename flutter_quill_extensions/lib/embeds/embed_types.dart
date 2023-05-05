import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';

typedef OnImagePickCallback = Future<String?> Function(File file);
typedef OnVideoPickCallback = Future<String?> Function(File file);
typedef FilePickImpl = Future<String?> Function(BuildContext context);
typedef WebImagePickImpl = Future<String?> Function(
    OnImagePickCallback onImagePickCallback);
typedef WebVideoPickImpl = Future<String?> Function(
    OnVideoPickCallback onImagePickCallback);
typedef MediaPickSettingSelector = Future<MediaPickSetting?> Function(
    BuildContext context);

enum MediaPickSetting {
  Gallery,
  Link,
  Camera,
  Video,
}

typedef MediaFileUrl = String;
typedef MediaFilePicker = Future<QuillFile?> Function(QuillMediaType mediaType);
typedef MediaPickedCallback = Future<MediaFileUrl> Function(QuillFile file);

enum QuillMediaType { image, video }

extension QuillMediaTypeX on QuillMediaType {
  bool get isImage => this == QuillMediaType.image;
  bool get isVideo => this == QuillMediaType.video;
}

/// Represents a file data which returned by file picker.
class QuillFile {
  QuillFile({
    required this.name,
    this.path = '',
    Uint8List? bytes,
  })  : assert(name.isNotEmpty),
        bytes = bytes ?? Uint8List(0);

  final String name;
  final String path;
  final Uint8List bytes;
}
