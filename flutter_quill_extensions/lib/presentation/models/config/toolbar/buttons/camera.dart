import 'package:flutter/widgets.dart' show Color;
import 'package:flutter_quill/flutter_quill.dart';

import '../../../../embeds/embed_types.dart';
import '../../../../embeds/embed_types/image.dart';
import 'image.dart';

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
    required this.onVideoPickCallback,
    this.imageConfigurations = const QuillToolbarImageButtonConfigurations(),
    this.webVideoPickImpl,
    this.iconSize,
    this.fillColor,
    super.iconData,
    super.afterButtonPressed,
    super.tooltip,
    super.iconTheme,
    super.childBuilder,
    super.controller,
  });

  final QuillToolbarImageButtonConfigurations imageConfigurations;

  final OnVideoPickCallback onVideoPickCallback;

  final WebVideoPickImpl? webVideoPickImpl;

  final double? iconSize;

  final Color? fillColor;
}
