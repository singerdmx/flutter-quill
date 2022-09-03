import 'dart:io';

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
