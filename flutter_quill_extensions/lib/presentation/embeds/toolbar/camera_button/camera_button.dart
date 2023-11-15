import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart'
    show
        QuillController,
        QuillIconTheme,
        QuillProviderExt,
        QuillToolbarBaseButtonOptions,
        QuillToolbarIconButton;
import 'package:flutter_quill/translations.dart';

import '../../../../logic/models/config/shared_configurations.dart';
import '../../../../logic/services/image_picker/image_options.dart';
import '../../../models/config/toolbar/buttons/camera.dart';
import '../../embed_types/camera.dart';
import 'select_camera_action.dart';

class QuillToolbarCameraButton extends StatelessWidget {
  const QuillToolbarCameraButton({
    required this.controller,
    required this.options,
    super.key,
  });

  final QuillController controller;
  final QuillToolbarCameraButtonOptions options;

  double _iconSize(BuildContext context) {
    final baseFontSize = baseButtonExtraOptions(context).globalIconSize;
    final iconSize = options.iconSize;
    return iconSize ?? baseFontSize;
  }

  VoidCallback? _afterButtonPressed(BuildContext context) {
    return options.afterButtonPressed ??
        baseButtonExtraOptions(context).afterButtonPressed;
  }

  QuillIconTheme? _iconTheme(BuildContext context) {
    return options.iconTheme ?? baseButtonExtraOptions(context).iconTheme;
  }

  QuillToolbarBaseButtonOptions baseButtonExtraOptions(BuildContext context) {
    return context.requireQuillToolbarBaseButtonOptions;
  }

  IconData _iconData(BuildContext context) {
    return options.iconData ??
        baseButtonExtraOptions(context).iconData ??
        Icons.photo_camera;
  }

  String _tooltip(BuildContext context) {
    return options.tooltip ??
        baseButtonExtraOptions(context).tooltip ??
        context.loc.camera;
  }

  void _sharedOnPressed(BuildContext context) {
    _onPressedHandler(
      context,
      controller,
    );
    _afterButtonPressed(context);
  }

  @override
  Widget build(BuildContext context) {
    final iconTheme = _iconTheme(context);
    final tooltip = _tooltip(context);
    final iconSize = _iconSize(context);
    final iconData = _iconData(context);

    final childBuilder =
        options.childBuilder ?? baseButtonExtraOptions(context).childBuilder;

    if (childBuilder != null) {
      childBuilder(
        QuillToolbarCameraButtonOptions(
          afterButtonPressed: _afterButtonPressed(context),
          iconData: options.iconData,
          fillColor: options.fillColor,
          iconSize: options.iconSize,
          iconButtonFactor: options.iconButtonFactor,
          iconTheme: options.iconTheme,
          tooltip: options.tooltip,
          cameraConfigurations: options.cameraConfigurations,
        ),
        QuillToolbarCameraButtonExtraOptions(
          controller: controller,
          context: context,
          onPressed: () => _sharedOnPressed(context),
        ),
      );
    }

    final theme = Theme.of(context);

    final iconColor = iconTheme?.iconUnselectedColor ?? theme.iconTheme.color;
    final iconFillColor = iconTheme?.iconUnselectedFillColor ??
        (options.fillColor ?? theme.canvasColor);

    return QuillToolbarIconButton(
      icon: Icon(iconData, size: iconSize, color: iconColor),
      tooltip: tooltip,
      highlightElevation: 0,
      hoverElevation: 0,
      size: iconSize * 1.77,
      fillColor: iconFillColor,
      borderRadius: iconTheme?.borderRadius ?? 2,
      // isDesktop(supportWeb: false) ? null :
      onPressed: () => _sharedOnPressed(context),
    );
  }

  Future<CameraAction?> _getCameraAction(BuildContext context) async {
    final customCallback =
        options.cameraConfigurations.onRequestCameraActionCallback;
    if (customCallback != null) {
      return await customCallback(context);
    }
    final cameraAction = await showDialog<CameraAction>(
      context: context,
      builder: (ctx) => const SelectCameraActionDialog(),
    );

    return cameraAction;
  }

  Future<void> _onPressedHandler(
    BuildContext context,
    QuillController controller,
  ) async {
    final imagePickerService =
        QuillSharedExtensionsConfigurations.get(context: context)
            .imagePickerService;

    final cameraAction = await _getCameraAction(context);

    if (cameraAction == null) {
      return;
    }

    switch (cameraAction) {
      case CameraAction.video:
        final videoFile = await imagePickerService.pickVideo(
          source: ImageSource.camera,
        );
        if (videoFile == null) {
          return;
        }
        await options.cameraConfigurations.onVideoInsertCallback(
          videoFile.path,
          controller,
        );
        await options.cameraConfigurations.onVideoInsertedCallback
            ?.call(videoFile.path);
      case CameraAction.image:
        final imageFile = await imagePickerService.pickImage(
          source: ImageSource.camera,
        );
        if (imageFile == null) {
          return;
        }
        await options.cameraConfigurations.onImageInsertCallback(
          imageFile.path,
          controller,
        );
        await options.cameraConfigurations.onImageInsertedCallback
            ?.call(imageFile.path);
    }

    // final file = await switch (cameraAction) {
    //   CameraAction.image =>
    //     imagePickerService.pickImage(source: ImageSource.camera),
    //   CameraAction.video =>
    //     imagePickerService.pickVideo(source: ImageSource.camera),
    // };
  }
}
