import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart'
    show
        QuillController,
        QuillIconTheme,
        QuillSimpleToolbarExt,
        QuillToolbarBaseButtonOptions,
        QuillToolbarIconButton,
        kDefaultIconSize,
        kDefaultIconButtonFactor;
import 'package:flutter_quill/translations.dart';

import '../../../models/config/camera/camera_configurations.dart';
import '../../../models/config/shared_configurations.dart';
import '../../../services/image_picker/image_options.dart';
import 'camera_types.dart';
import 'select_camera_action.dart';

class QuillToolbarCameraButton extends StatelessWidget {
  const QuillToolbarCameraButton({
    required this.controller,
    this.options = const QuillToolbarCameraButtonOptions(),
    super.key,
  });

  final QuillController controller;
  final QuillToolbarCameraButtonOptions options;

  double _iconSize(BuildContext context) {
    final baseFontSize = baseButtonExtraOptions(context)?.iconSize;
    final iconSize = options.iconSize;
    return iconSize ?? baseFontSize ?? kDefaultIconSize;
  }

  double _iconButtonFactor(BuildContext context) {
    final baseIconFactor = baseButtonExtraOptions(context)?.iconButtonFactor;
    final iconButtonFactor = options.iconButtonFactor;
    return iconButtonFactor ?? baseIconFactor ?? kDefaultIconButtonFactor;
  }

  VoidCallback? _afterButtonPressed(BuildContext context) {
    return options.afterButtonPressed ??
        baseButtonExtraOptions(context)?.afterButtonPressed;
  }

  QuillIconTheme? _iconTheme(BuildContext context) {
    return options.iconTheme ?? baseButtonExtraOptions(context)?.iconTheme;
  }

  QuillToolbarBaseButtonOptions? baseButtonExtraOptions(BuildContext context) {
    return context.quillToolbarBaseButtonOptions;
  }

  IconData _iconData(BuildContext context) {
    return options.iconData ??
        baseButtonExtraOptions(context)?.iconData ??
        Icons.photo_camera;
  }

  String _tooltip(BuildContext context) {
    return options.tooltip ??
        baseButtonExtraOptions(context)?.tooltip ??
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
    final iconButtonFactor = _iconButtonFactor(context);

    final childBuilder =
        options.childBuilder ?? baseButtonExtraOptions(context)?.childBuilder;

    if (childBuilder != null) {
      childBuilder(
        QuillToolbarCameraButtonOptions(
          afterButtonPressed: _afterButtonPressed(context),
          iconData: options.iconData,
          iconSize: options.iconSize,
          iconButtonFactor: iconButtonFactor,
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

    return QuillToolbarIconButton(
      icon: Icon(
        iconData,
        size: iconButtonFactor * iconSize,
      ),
      tooltip: tooltip,
      isSelected: false,
      // isDesktop(supportWeb: false) ? null :
      onPressed: () => _sharedOnPressed(context),
      iconTheme: iconTheme,
    );
  }

  Future<CameraAction?> _getCameraAction(BuildContext context) async {
    final customCallback =
        options.cameraConfigurations.onRequestCameraActionCallback;
    if (customCallback != null) {
      return await customCallback(context);
    }
    final cameraAction = await showSelectCameraActionDialog(
      context: context,
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
  }
}
