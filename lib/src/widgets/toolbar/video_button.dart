import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/documents/nodes/embed.dart';
import '../../utils/media_source.dart';
import '../controller.dart';
import '../link_dialog.dart';
import '../toolbar.dart';
import 'image_video_utils.dart';
import 'quill_icon_button.dart';

class VideoButton extends StatelessWidget {
  const VideoButton({
    required this.icon,
    required this.controller,
    required this.source,
    this.iconSize = kDefaultIconSize,
    this.onVideoPickCallback,
    this.fillColor,
    this.filePickImpl,
    this.webVideoPickImpl,
    this.mediaSourceSelectorBuilder,
    Key? key,
  })  : assert(
          source == MediaSource.Link || onVideoPickCallback != null,
          'Gallery source requires non-null onVideoPickCallback',
        ),
        super(key: key);

  final IconData icon;
  final double iconSize;

  final Color? fillColor;

  final QuillController controller;

  final OnVideoPickCallback? onVideoPickCallback;

  final WebVideoPickImpl? webVideoPickImpl;

  final FilePickImpl? filePickImpl;

  final MediaSource source;

  final MediaSourceSelectorBuilder? mediaSourceSelectorBuilder;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return QuillIconButton(
      icon: Icon(icon, size: iconSize, color: theme.iconTheme.color),
      highlightElevation: 0,
      hoverElevation: 0,
      size: iconSize * 1.77,
      fillColor: fillColor ?? theme.canvasColor,
      onPressed: () => _onPressedHandler(context),
    );
  }

  Future<void> _onPressedHandler(BuildContext context) async {
    switch (source) {
      case MediaSource.Gallery:
        _pickVideo(context);
        break;
      case MediaSource.Link:
        _typeLink(context);
        break;
      case MediaSource.GalleryAndLink:
        final builder =
            mediaSourceSelectorBuilder ?? ImageVideoUtils.selectMediaSource;
        final source = await builder(context);
        if (source != null) {
          assert(
            source != MediaSource.GalleryAndLink,
            'Source selector should return either MediaSource.Gallery or Link',
          );

          if (source == MediaSource.Gallery) {
            _pickVideo(context);
          } else {
            _typeLink(context);
          }
        }
        break;
    }
  }

  void _pickVideo(BuildContext context) => ImageVideoUtils.handleVideoButtonTap(
        context,
        controller,
        ImageSource.gallery,
        onVideoPickCallback!,
        filePickImpl: filePickImpl,
        webVideoPickImpl: webVideoPickImpl,
      );

  void _typeLink(BuildContext context) {
    showDialog<String>(
      context: context,
      builder: (_) => const LinkDialog(),
    ).then(_linkSubmitted);
  }

  void _linkSubmitted(String? value) {
    if (value != null && value.isNotEmpty) {
      final index = controller.selection.baseOffset;
      final length = controller.selection.extentOffset - index;

      controller.replaceText(index, length, BlockEmbed.video(value), null);
    }
  }
}
