import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/internal.dart';

import 'package:image_picker/image_picker.dart';
import '../../common/default_image_insert.dart';
import '../../common/default_video_insert.dart';
import '../quill_simple_toolbar_api.dart';
import 'camera_types.dart';
import 'config/camera_config.dart';
import 'select_camera_action.dart';

// ignore: invalid_use_of_internal_member
class QuillToolbarCameraButton extends QuillToolbarBaseButtonStateless {
  const QuillToolbarCameraButton({
    required super.controller,
    QuillToolbarCameraButtonOptions? options,

    /// Shares common options between all buttons, prefer the [options]
    /// over the [baseOptions].
    super.baseOptions,
    super.key,
  })  : _options = options,
        super(options: options);

  final QuillToolbarCameraButtonOptions? _options;

  @override
  QuillToolbarCameraButtonOptions? get options => _options;

  void _sharedOnPressed(BuildContext context) {
    _onPressedHandler(
      context,
      controller,
    );
    afterButtonPressed(context);
  }

  Future<CameraAction?> _getCameraAction(BuildContext context) async {
    final customCallback = options?.cameraConfig?.onRequestCameraActionCallback;
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
    final cameraAction = await _getCameraAction(context);

    if (cameraAction == null) {
      return;
    }

    switch (cameraAction) {
      case CameraAction.video:
        final videoFile =
            await ImagePicker().pickVideo(source: ImageSource.camera);
        if (videoFile == null) {
          return;
        }
        await handleVideoInsert(
          videoFile.path,
          controller: controller,
          onVideoInsertCallback: options?.cameraConfig?.onVideoInsertCallback,
          onVideoInsertedCallback:
              options?.cameraConfig?.onVideoInsertedCallback,
        );
      case CameraAction.image:
        final imageFile =
            await ImagePicker().pickImage(source: ImageSource.camera);
        if (imageFile == null) {
          return;
        }
        await handleImageInsert(
          imageFile.path,
          controller: controller,
          onImageInsertCallback: options?.cameraConfig?.onImageInsertCallback,
          onImageInsertedCallback:
              options?.cameraConfig?.onImageInsertedCallback,
        );
    }
  }

  @override
  Widget buildButton(BuildContext context) {
    return QuillToolbarIconButton(
      icon: Icon(
        iconData(context),
        size: iconButtonFactor(context) * iconSize(context),
      ),
      tooltip: tooltip(context),
      isSelected: false,
      onPressed: () => _sharedOnPressed(context),
      iconTheme: iconTheme(context),
    );
  }

  @override
  Widget? buildCustomChildBuilder(BuildContext context) {
    return childBuilder?.call(
      QuillToolbarCameraButtonOptions(
        afterButtonPressed: afterButtonPressed(context),
        iconData: iconData(context),
        iconSize: iconSize(context),
        iconButtonFactor: iconButtonFactor(context),
        iconTheme: options?.iconTheme,
        tooltip: tooltip(context),
        cameraConfig: options?.cameraConfig,
      ),
      QuillToolbarCameraButtonExtraOptions(
        controller: controller,
        context: context,
        onPressed: () => _sharedOnPressed(context),
      ),
    );
  }

  @override
  IconData Function(BuildContext context) get getDefaultIconData =>
      (context) => Icons.photo_camera;

  @override
  String Function(BuildContext context) get getDefaultTooltip =>
      (context) => context.loc.camera;
}
