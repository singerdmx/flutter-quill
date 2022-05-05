import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/documents/nodes/embeddable.dart';
import '../../models/themes/quill_dialog_theme.dart';
import '../../models/themes/quill_icon_theme.dart';
import '../controller.dart';
import '../toolbar.dart';

class ImageButton extends StatelessWidget {
  const ImageButton({
    required this.icon,
    required this.controller,
    this.iconSize = kDefaultIconSize,
    this.onImagePickCallback,
    this.fillColor,
    this.filePickImpl,
    this.webImagePickImpl,
    this.mediaPickSettingSelector,
    this.iconTheme,
    this.dialogTheme,
    Key? key,
  }) : super(key: key);

  final IconData icon;
  final double iconSize;

  final Color? fillColor;

  final QuillController controller;

  final OnImagePickCallback? onImagePickCallback;

  final WebImagePickImpl? webImagePickImpl;

  final FilePickImpl? filePickImpl;

  final MediaPickSettingSelector? mediaPickSettingSelector;

  final QuillIconTheme? iconTheme;

  final QuillDialogTheme? dialogTheme;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final iconColor = iconTheme?.iconUnselectedColor ?? theme.iconTheme.color;
    final iconFillColor =
        iconTheme?.iconUnselectedFillColor ?? (fillColor ?? theme.canvasColor);

    return QuillIconButton(
      icon: Icon(icon, size: iconSize, color: iconColor),
      highlightElevation: 0,
      hoverElevation: 0,
      size: iconSize * 1.77,
      fillColor: iconFillColor,
      borderRadius: iconTheme?.borderRadius ?? 2,
      onPressed: () => _onPressedHandler(context),
    );
  }

  Future<void> _onPressedHandler(BuildContext context) async {
    if (onImagePickCallback != null) {
      final selector =
          mediaPickSettingSelector ?? ImageVideoUtils.selectMediaPickSetting;
      final source = await selector(context);
      if (source != null) {
        if (source == MediaPickSetting.Gallery) {
          _pickImage(context);
        } else {
          _typeLink(context);
        }
      }
    } else {
      _typeLink(context);
    }
  }

  void _pickImage(BuildContext context) => ImageVideoUtils.handleImageButtonTap(
        context,
        controller,
        ImageSource.gallery,
        onImagePickCallback!,
        filePickImpl: filePickImpl,
        webImagePickImpl: webImagePickImpl,
      );

  void _typeLink(BuildContext context) {
    showDialog<String>(
      context: context,
      builder: (_) => LinkDialog(dialogTheme: dialogTheme),
    ).then(_linkSubmitted);
  }

  void _linkSubmitted(String? value) {
    if (value != null && value.isNotEmpty) {
      final index = controller.selection.baseOffset;
      final length = controller.selection.extentOffset - index;

      controller.replaceText(index, length, BlockEmbed.image(value), null);
    }
  }
}
