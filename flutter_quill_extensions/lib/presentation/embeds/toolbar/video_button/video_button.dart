// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

import '../../../../logic/models/config/shared_configurations.dart';
import '../../../../logic/services/image_picker/image_options.dart';
import '../../../models/config/toolbar/buttons/video.dart';
import '../../embed_types/video.dart';
import '../utils/image_video_utils.dart';
import 'select_video_source.dart';

class QuillToolbarVideoButton extends StatelessWidget {
  const QuillToolbarVideoButton({
    required this.options,
    required this.controller,
    super.key,
  });

  final QuillController controller;

  final QuillToolbarVideoButtonOptions options;

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
        Icons.movie_creation;
  }

  String _tooltip(BuildContext context) {
    return options.tooltip ??
        baseButtonExtraOptions(context).tooltip ??
        'Insert video';
    // ('Insert video'.i18n);
  }

  void _sharedOnPressed(BuildContext context) {
    _onPressedHandler(context);
    _afterButtonPressed(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final iconTheme = _iconTheme(context);

    final tooltip = _tooltip(context);
    final iconSize = _iconSize(context);
    final iconData = _iconData(context);
    final childBuilder =
        options.childBuilder ?? baseButtonExtraOptions(context).childBuilder;

    final iconColor = iconTheme?.iconUnselectedColor ?? theme.iconTheme.color;
    final iconFillColor = iconTheme?.iconUnselectedFillColor ??
        (options.fillColor ?? theme.canvasColor);

    if (childBuilder != null) {
      return childBuilder(
        QuillToolbarVideoButtonOptions(
          afterButtonPressed: _afterButtonPressed(context),
          iconData: iconData,
          dialogTheme: options.dialogTheme,
          fillColor: iconFillColor,
          iconSize: options.iconSize,
          iconButtonFactor: options.iconButtonFactor,
          linkRegExp: options.linkRegExp,
          tooltip: options.tooltip,
          iconTheme: options.iconTheme,
          videoConfigurations: options.videoConfigurations,
        ),
        QuillToolbarVideoButtonExtraOptions(
          context: context,
          controller: controller,
          onPressed: () => _sharedOnPressed(context),
        ),
      );
    }

    return QuillToolbarIconButton(
      icon: Icon(iconData, size: iconSize, color: iconColor),
      tooltip: tooltip,
      highlightElevation: 0,
      hoverElevation: 0,
      size: iconSize * 1.77,
      fillColor: iconFillColor,
      borderRadius: iconTheme?.borderRadius ?? 2,
      onPressed: () => _sharedOnPressed(context),
    );
  }

  Future<void> _onPressedHandler(BuildContext context) async {
    final imagePickerService =
        QuillSharedExtensionsConfigurations.get(context: context)
            .imagePickerService;

    final onRequestPickVideo = options.videoConfigurations.onRequestPickVideo;
    if (onRequestPickVideo != null) {
      final videoUrl = await onRequestPickVideo(context, imagePickerService);
      if (videoUrl != null) {
        await options.videoConfigurations
            .onVideoInsertCallback(videoUrl, controller);
        await options.videoConfigurations.onVideoInsertedCallback
            ?.call(videoUrl);
      }
      return;
    }

    final imageSource = await showSelectVideoSourceDialog(context: context);

    if (imageSource == null) {
      return;
    }

    final videoUrl = switch (imageSource) {
      InsertVideoSource.gallery =>
        (await imagePickerService.pickVideo(source: ImageSource.gallery))?.path,
      InsertVideoSource.camera =>
        (await imagePickerService.pickVideo(source: ImageSource.camera))?.path,
      InsertVideoSource.link => await _typeLink(context),
    };
    if (videoUrl == null) {
      return;
    }

    if (videoUrl.trim().isNotEmpty) {
      await options.videoConfigurations
          .onVideoInsertCallback(videoUrl, controller);
      await options.videoConfigurations.onVideoInsertedCallback?.call(videoUrl);
    }

    // if (options.onVideoPickCallback != null) {
    //   final selector = options.mediaPickSettingSelector ??
    //       ImageVideoUtils.selectMediaPickSetting;
    //   final source = await selector(context);
    //   if (source != null) {
    //     if (source == MediaPickSetting.gallery) {
    //     } else {
    //       await _typeLink(context);
    //     }
    //   }
    // } else {}
  }

  Future<String?> _typeLink(BuildContext context) async {
    final value = await showDialog<String>(
      context: context,
      builder: (_) => QuillProvider.value(
        value: context.requireQuillProvider,
        child: FlutterQuillLocalizationsWidget(
          child: TypeLinkDialog(
            dialogTheme: options.dialogTheme,
            linkType: LinkType.video,
          ),
        ),
      ),
    );
    return value;
  }

  // void _linkSubmitted(String? value) {
  //   if (value != null && value.isNotEmpty) {
  //     final index = controller.selection.baseOffset;
  //     final length = controller.selection.extentOffset - index;

  //     controller.replaceText(index, length, BlockEmbed.video(value), null);
  //   }
  // }
}
