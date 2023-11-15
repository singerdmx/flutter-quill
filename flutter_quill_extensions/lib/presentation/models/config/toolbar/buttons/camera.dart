import 'package:flutter/widgets.dart' show Color;
import 'package:flutter_quill/flutter_quill.dart';

import '../../../../embeds/embed_types/camera.dart';

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
    this.cameraConfigurations = const QuillToolbarCameraConfigurations(),
    this.iconSize,
    this.iconButtonFactor,
    this.fillColor,
    super.iconData,
    super.afterButtonPressed,
    super.tooltip,
    super.iconTheme,
    super.childBuilder,
    super.controller,
  });

  final double? iconSize;
  final double? iconButtonFactor;

  final Color? fillColor;

  final QuillToolbarCameraConfigurations cameraConfigurations;
}
