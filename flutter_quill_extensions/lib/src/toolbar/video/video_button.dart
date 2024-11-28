import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/internal.dart';

import 'package:image_picker/image_picker.dart';

import '../../common/default_video_insert.dart';
import '../../common/image_video_utils.dart';
import '../quill_simple_toolbar_api.dart';

import 'config/video.dart';
import 'config/video_config.dart';
import 'select_video_source.dart';

// ignore: invalid_use_of_internal_member
class QuillToolbarVideoButton extends QuillToolbarBaseButtonStateless {
  const QuillToolbarVideoButton({
    required super.controller,
    QuillToolbarVideoButtonOptions? options,

    /// Shares common options between all buttons, prefer the [options]
    /// over the [baseOptions].
    super.baseOptions,
    super.key,
  })  : _options = options,
        super(options: options);

  final QuillToolbarVideoButtonOptions? _options;

  @override
  QuillToolbarVideoButtonOptions? get options => _options;

  void _sharedOnPressed(BuildContext context) {
    _onPressedHandler(context);
    afterButtonPressed(context);
  }

  Future<void> _handleVideoInsert(String videoUrl) async {
    await handleVideoInsert(
      videoUrl,
      controller: controller,
      onVideoInsertCallback: options?.videoConfig?.onVideoInsertCallback,
      onVideoInsertedCallback: options?.videoConfig?.onVideoInsertedCallback,
    );
  }

  Future<void> _onPressedHandler(BuildContext context) async {
    final onRequestPickVideo = options?.videoConfig?.onRequestPickVideo;
    if (onRequestPickVideo != null) {
      final videoUrl = await onRequestPickVideo(context);
      if (videoUrl != null) {
        await _handleVideoInsert(videoUrl);
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
      _handleVideoInsert(videoUrl);
    }
  }

  Future<String?> _typeLink(BuildContext context) async {
    final value = await showDialog<String>(
      context: context,
      builder: (_) => TypeLinkDialog(
        dialogTheme: options?.dialogTheme,
        linkType: LinkType.video,
      ),
    );
    return value;
  }

  @override
  Widget buildButton(BuildContext context) {
    return QuillToolbarIconButton(
      icon: Icon(
        iconData(context),
        size: iconSize(context) * iconButtonFactor(context),
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
      QuillToolbarVideoButtonOptions(
        afterButtonPressed: afterButtonPressed(context),
        iconData: iconData(context),
        dialogTheme: options?.dialogTheme,
        iconSize: iconSize(context),
        iconButtonFactor: iconButtonFactor(context),
        linkRegExp: options?.linkRegExp,
        tooltip: tooltip(context),
        iconTheme: options?.iconTheme,
        videoConfig: options?.videoConfig,
      ),
      QuillToolbarVideoButtonExtraOptions(
        context: context,
        controller: controller,
        onPressed: () => _sharedOnPressed(context),
      ),
    );
  }

  @override
  IconData Function(BuildContext context) get getDefaultIconData =>
      (context) => Icons.movie_creation;

  @override
  String Function(BuildContext context) get getDefaultTooltip =>
      (context) => context.loc.insertVideo;
}
