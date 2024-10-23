import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

import 'package:image_picker/image_picker.dart';

import '../../common/image_video_utils.dart';

import 'models/video.dart';
import 'models/video_config.dart';
import 'select_video_source.dart';

class QuillToolbarVideoButton extends StatelessWidget {
  const QuillToolbarVideoButton({
    required this.controller,
    this.options = const QuillToolbarVideoButtonOptions(),
    super.key,
  });

  final QuillController controller;

  final QuillToolbarVideoButtonOptions options;

  double _iconSize(BuildContext context) {
    final iconSize = options.iconSize;
    return iconSize ?? kDefaultIconSize;
  }

  double _iconButtonFactor(BuildContext context) {
    final iconButtonFactor = options.iconButtonFactor;
    return iconButtonFactor ?? kDefaultIconButtonFactor;
  }

  VoidCallback? _afterButtonPressed(BuildContext context) {
    return options.afterButtonPressed;
  }

  QuillIconTheme? _iconTheme(BuildContext context) {
    return options.iconTheme;
  }

  IconData _iconData(BuildContext context) {
    return options.iconData ?? Icons.movie_creation;
  }

  String _tooltip(BuildContext context) {
    // TODO: Add insert video translation
    return options.tooltip ?? 'Insert video';
  }

  void _sharedOnPressed(BuildContext context) {
    _onPressedHandler(context);
    _afterButtonPressed(context);
  }

  @override
  Widget build(BuildContext context) {
    final tooltip = _tooltip(context);
    final iconSize = _iconSize(context);
    final iconButtonFactor = _iconButtonFactor(context);
    final iconData = _iconData(context);
    final childBuilder = options.childBuilder;

    if (childBuilder != null) {
      return childBuilder(
        QuillToolbarVideoButtonOptions(
          afterButtonPressed: _afterButtonPressed(context),
          iconData: iconData,
          dialogTheme: options.dialogTheme,
          iconSize: options.iconSize,
          iconButtonFactor: iconButtonFactor,
          linkRegExp: options.linkRegExp,
          tooltip: options.tooltip,
          iconTheme: options.iconTheme,
          videoConfig: options.videoConfig,
        ),
        QuillToolbarVideoButtonExtraOptions(
          context: context,
          controller: controller,
          onPressed: () => _sharedOnPressed(context),
        ),
      );
    }

    return QuillToolbarIconButton(
      icon: Icon(
        iconData,
        size: iconSize * iconButtonFactor,
      ),
      tooltip: tooltip,
      isSelected: false,
      onPressed: () => _sharedOnPressed(context),
      iconTheme: _iconTheme(context),
    );
  }

  Future<void> _onPressedHandler(BuildContext context) async {
    final onRequestPickVideo = options.videoConfig.onRequestPickVideo;
    if (onRequestPickVideo != null) {
      final videoUrl = await onRequestPickVideo(context);
      if (videoUrl != null) {
        await options.videoConfig.onVideoInsertCallback(videoUrl, controller);
        await options.videoConfig.onVideoInsertedCallback?.call(videoUrl);
      }
      return;
    }

    final imageSource = await showSelectVideoSourceDialog(context: context);

    if (imageSource == null) {
      return;
    }

    final videoUrl = switch (imageSource) {
      InsertVideoSource.gallery =>
        (await ImagePicker().pickVideo(source: ImageSource.gallery))?.path,
      InsertVideoSource.camera =>
        (await ImagePicker().pickVideo(source: ImageSource.camera))?.path,
      InsertVideoSource.link =>
        context.mounted ? await _typeLink(context) : null,
    };
    if (videoUrl == null) {
      return;
    }

    if (videoUrl.trim().isNotEmpty) {
      await options.videoConfig.onVideoInsertCallback(videoUrl, controller);
      await options.videoConfig.onVideoInsertedCallback?.call(videoUrl);
    }
  }

  Future<String?> _typeLink(BuildContext context) async {
    final value = await showDialog<String>(
      context: context,
      builder: (_) => TypeLinkDialog(
        dialogTheme: options.dialogTheme,
        linkType: LinkType.video,
      ),
    );
    return value;
  }
}
