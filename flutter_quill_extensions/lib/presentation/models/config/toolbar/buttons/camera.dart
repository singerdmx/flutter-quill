import 'package:flutter/widgets.dart' show Color;
import 'package:flutter_quill/flutter_quill.dart';

import '../../../../embeds/embed_types.dart';

class QuillToolbarCameraButtonExtraOptions
    extends QuillToolbarBaseButtonExtraOptions {
  const QuillToolbarCameraButtonExtraOptions({
    required super.controller,
    required super.context,
    required super.onPressed,
  });
}

class QuillToolbarCameraButtonOptions extends QuillToolbarBaseButtonOptions<
    QuillToolbarCameraButtonOptions, QuillToolbarCameraButtonExtraOptions> {
  const QuillToolbarCameraButtonOptions({
    required this.onImagePickCallback,
    required this.onVideoPickCallback,
    this.webImagePickImpl,
    this.webVideoPickImpl,
    this.filePickImpl,
    this.cameraPickSettingSelector,
    this.iconSize,
    this.fillColor,
    super.iconData,
    super.afterButtonPressed,
    super.tooltip,
    super.iconTheme,
    super.childBuilder,
    super.controller,
  });

  final OnImagePickCallback onImagePickCallback;

  final OnVideoPickCallback onVideoPickCallback;

  final WebImagePickImpl? webImagePickImpl;

  final WebVideoPickImpl? webVideoPickImpl;

  final FilePickImpl? filePickImpl;

  final MediaPickSettingSelector? cameraPickSettingSelector;

  final double? iconSize;

  final Color? fillColor;
}
