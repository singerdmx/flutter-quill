import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../utils/media_pick_setting.dart';
import '../controller.dart';
import '../link_dialog.dart';
import '../toolbar.dart';
import 'image_video_utils.dart';
import 'quill_icon_button.dart';

class CustomEmoticonsButton extends StatelessWidget {
  const CustomEmoticonsButton({
    required this.icon,
    required this.controller,
    this.iconSize = kDefaultIconSize,
    this.onImagePickCallback,
    this.fillColor,
    this.filePickImpl,
    this.webImagePickImpl,
    this.mediaPickSettingSelector,
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

  static bool _isMobile() => Platform.isAndroid || Platform.isIOS;

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
    if (onImagePickCallback != null) {
      final selector =
          mediaPickSettingSelector ?? ImageVideoUtils.selectMediaPickSetting;
      final source = await selector(context);
      if (source != null) {
        if (source == MediaPickSetting.Gallery) {
          _selectImage(context);
        } else {
          _typeLink(context);
        }
      }
    } else {
      _typeLink(context);
    }
  }

  void _selectImage(BuildContext context) async {
    String? imageUrl;
    if (kIsWeb) {
      assert(
          webImagePickImpl != null,
          'Please provide webImagePickImpl for Web '
          '(check out example directory for how to do it)');
      imageUrl = await webImagePickImpl!(onImagePickCallback!);
    } else if (_isMobile()) {
      imageUrl = await _pickImage(ImageSource.gallery, onImagePickCallback!);
    } else {
      assert(filePickImpl != null, 'Desktop must provide filePickImpl');
      imageUrl =
          await _pickImageDesktop(context, filePickImpl!, onImagePickCallback!);
    }

    if (imageUrl != null) {
      _insertImg(imageUrl);
    }
  }

  static Future<String?> _pickImage(
      ImageSource source, OnImagePickCallback onImagePickCallback) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile == null) {
      return null;
    }

    return onImagePickCallback(File(pickedFile.path));
  }

  static Future<String?> _pickImageDesktop(
      BuildContext context,
      FilePickImpl filePickImpl,
      OnImagePickCallback onImagePickCallback) async {
    final filePath = await filePickImpl(context);
    if (filePath == null || filePath.isEmpty) return null;

    final file = File(filePath);
    return onImagePickCallback(file);
  }

  void _typeLink(BuildContext context) {
    showDialog<String>(
      context: context,
      builder: (_) => const LinkDialog(),
    ).then(_linkSubmitted);
  }

  void _linkSubmitted(String? value) {
    if (value != null && value.isNotEmpty) {
      _insertImg(value);
    }
  }

  void _insertImg(String? imageUrl) {
    final index = controller.selection.baseOffset;
    final length = controller.selection.extentOffset - index;
    // To do ...
  }
}
