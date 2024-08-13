import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/translations.dart';

import '../../../models/config/shared_configurations.dart';
import '../../../models/config/video/toolbar/video_configurations.dart';
import '../../../services/image_picker/image_options.dart';
import '../../others/image_video_utils.dart';
import '../video.dart';
import 'select_video_source.dart';

// TODO: Add custom callback to validate the video link input

class QuillToolbarVideoButton extends StatelessWidget {
  const QuillToolbarVideoButton({
    required this.controller,
    this.options = const QuillToolbarVideoButtonOptions(),
    super.key,
  });

  final QuillController controller;

  final QuillToolbarVideoButtonOptions options;

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
        Icons.movie_creation;
  }

  String _tooltip(BuildContext context) {
    return options.tooltip ??
        baseButtonExtraOptions(context)?.tooltip ??
        'Insert video';
    // ('Insert video'.i18n);
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
    final childBuilder =
        options.childBuilder ?? baseButtonExtraOptions(context)?.childBuilder;

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
      InsertVideoSource.link =>
        context.mounted ? await _typeLink(context) : null,
    };
    if (videoUrl == null) {
      return;
    }

    if (videoUrl.trim().isNotEmpty) {
      await options.videoConfigurations
          .onVideoInsertCallback(videoUrl, controller);
      await options.videoConfigurations.onVideoInsertedCallback?.call(videoUrl);
    }
  }

  Future<String?> _typeLink(BuildContext context) async {
    final value = await showDialog<String>(
      context: context,
      builder: (_) => FlutterQuillLocalizationsWidget(
        child: TypeLinkDialog(
          dialogTheme: options.dialogTheme,
          linkType: LinkType.video,
        ),
      ),
    );
    return value;
  }
}
