import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/documents/nodes/embed.dart';
import '../controller.dart';
import '../toolbar.dart';
import 'quill_icon_button.dart';

class VideoButton extends StatelessWidget {
  const VideoButton({
    required this.icon,
    required this.controller,
    required this.videoSource,
    this.iconSize = kDefaultIconSize,
    this.fillColor,
    this.onVideoPickCallback,
    this.filePickImpl,
    this.webVideoPickImpl,
    Key? key,
  }) : super(key: key);

  final IconData icon;
  final double iconSize;

  final Color? fillColor;

  final QuillController controller;

  final OnVideoPickCallback? onVideoPickCallback;

  final WebVideoPickImpl? webVideoPickImpl;

  final ImageSource videoSource;

  final FilePickImpl? filePickImpl;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return QuillIconButton(
      icon: Icon(icon, size: iconSize, color: theme.iconTheme.color),
      highlightElevation: 0,
      hoverElevation: 0,
      size: iconSize * 1.77,
      fillColor: fillColor ?? theme.canvasColor,
      onPressed: () => _handleVideoButtonTap(context, filePickImpl),
    );
  }

  Future<void> _handleVideoButtonTap(BuildContext context,
      [FilePickImpl? filePickImpl]) async {
    final index = controller.selection.baseOffset;
    final length = controller.selection.extentOffset - index;

    String? videoUrl;
    if (kIsWeb) {
      assert(
          webVideoPickImpl != null,
          'Please provide webVideoPickImpl for Web '
          '(check out example directory for how to do it)');
      videoUrl = await webVideoPickImpl!(onVideoPickCallback!);
    } else if (Platform.isAndroid || Platform.isIOS) {
      videoUrl = await _pickVideo(videoSource, onVideoPickCallback!);
    } else {
      assert(filePickImpl != null, 'Desktop must provide filePickImpl');
      videoUrl =
          await _pickVideoDesktop(context, filePickImpl!, onVideoPickCallback!);
    }

    if (videoUrl != null) {
      controller.replaceText(index, length, BlockEmbed.video(videoUrl), null);
    }
  }

  Future<String?> _pickVideo(
      ImageSource source, OnVideoPickCallback onVideoPickCallback) async {
    final pickedFile = await ImagePicker().getVideo(source: source);
    if (pickedFile == null) {
      return null;
    }

    return onVideoPickCallback(File(pickedFile.path));
  }

  Future<String?> _pickVideoDesktop(
      BuildContext context,
      FilePickImpl filePickImpl,
      OnVideoPickCallback onVideoPickCallback) async {
    final filePath = await filePickImpl(context);
    if (filePath == null || filePath.isEmpty) return null;

    final file = File(filePath);
    return onVideoPickCallback(file);
  }
}
