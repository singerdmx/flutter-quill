import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/extensions.dart';
import 'package:flutter_quill/flutter_quill.dart' hide Text;
import 'package:flutter_quill/translations.dart';
import 'package:image_picker/image_picker.dart';

import '../embed_types.dart';

class LinkDialog extends StatefulWidget {
  const LinkDialog({
    this.dialogTheme,
    this.link,
    this.linkRegExp,
    Key? key,
  }) : super(key: key);

  final QuillDialogTheme? dialogTheme;
  final String? link;
  final RegExp? linkRegExp;

  @override
  LinkDialogState createState() => LinkDialogState();
}

class LinkDialogState extends State<LinkDialog> {
  late String _link;
  late TextEditingController _controller;
  late RegExp _linkRegExp;

  @override
  void initState() {
    super.initState();
    _link = widget.link ?? '';
    _controller = TextEditingController(text: _link);
    _linkRegExp = widget.linkRegExp ?? AutoFormatMultipleLinksRule.linkRegExp;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: widget.dialogTheme?.dialogBackgroundColor,
      content: TextField(
        keyboardType: TextInputType.multiline,
        maxLines: null,
        style: widget.dialogTheme?.inputTextStyle,
        decoration: InputDecoration(
            labelText: 'Paste a link'.i18n,
            labelStyle: widget.dialogTheme?.labelTextStyle,
            floatingLabelStyle: widget.dialogTheme?.labelTextStyle),
        autofocus: true,
        onChanged: _linkChanged,
        controller: _controller,
      ),
      actions: [
        TextButton(
          onPressed: _link.isNotEmpty && _linkRegExp.hasMatch(_link)
              ? _applyLink
              : null,
          child: Text(
            'Ok'.i18n,
            style: widget.dialogTheme?.labelTextStyle,
          ),
        ),
      ],
    );
  }

  void _linkChanged(String value) {
    setState(() {
      _link = value;
    });
  }

  void _applyLink() {
    Navigator.pop(context, _link.trim());
  }
}

class ImageVideoUtils {
  static Future<MediaPickSetting?> selectMediaPickSetting(
    BuildContext context,
  ) =>
      showDialog<MediaPickSetting>(
        context: context,
        builder: (ctx) => AlertDialog(
          contentPadding: EdgeInsets.zero,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton.icon(
                icon: const Icon(
                  Icons.collections,
                  color: Colors.orangeAccent,
                ),
                label: Text('Gallery'.i18n),
                onPressed: () => Navigator.pop(ctx, MediaPickSetting.Gallery),
              ),
              TextButton.icon(
                icon: const Icon(
                  Icons.link,
                  color: Colors.cyanAccent,
                ),
                label: Text('Link'.i18n),
                onPressed: () => Navigator.pop(ctx, MediaPickSetting.Link),
              )
            ],
          ),
        ),
      );

  /// For image picking logic
  static Future<void> handleImageButtonTap(
      BuildContext context,
      QuillController controller,
      ImageSource imageSource,
      OnImagePickCallback onImagePickCallback,
      {FilePickImpl? filePickImpl,
      WebImagePickImpl? webImagePickImpl}) async {
    final index = controller.selection.baseOffset;
    final length = controller.selection.extentOffset - index;

    String? imageUrl;
    if (kIsWeb) {
      assert(
          webImagePickImpl != null,
          'Please provide webImagePickImpl for Web '
          '(check out example directory for how to do it)');
      imageUrl = await webImagePickImpl!(onImagePickCallback);
    } else if (isMobile()) {
      imageUrl = await _pickImage(imageSource, onImagePickCallback);
    } else {
      assert(filePickImpl != null, 'Desktop must provide filePickImpl');
      imageUrl =
          await _pickImageDesktop(context, filePickImpl!, onImagePickCallback);
    }

    if (imageUrl != null) {
      controller.replaceText(index, length, BlockEmbed.image(imageUrl), null);
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

  /// For video picking logic
  static Future<void> handleVideoButtonTap(
      BuildContext context,
      QuillController controller,
      ImageSource videoSource,
      OnVideoPickCallback onVideoPickCallback,
      {FilePickImpl? filePickImpl,
      WebVideoPickImpl? webVideoPickImpl}) async {
    final index = controller.selection.baseOffset;
    final length = controller.selection.extentOffset - index;

    String? videoUrl;
    if (kIsWeb) {
      assert(
          webVideoPickImpl != null,
          'Please provide webVideoPickImpl for Web '
          '(check out example directory for how to do it)');
      videoUrl = await webVideoPickImpl!(onVideoPickCallback);
    } else if (isMobile()) {
      videoUrl = await _pickVideo(videoSource, onVideoPickCallback);
    } else {
      assert(filePickImpl != null, 'Desktop must provide filePickImpl');
      videoUrl =
          await _pickVideoDesktop(context, filePickImpl!, onVideoPickCallback);
    }

    if (videoUrl != null) {
      controller.replaceText(index, length, BlockEmbed.video(videoUrl), null);
    }
  }

  static Future<String?> _pickVideo(
      ImageSource source, OnVideoPickCallback onVideoPickCallback) async {
    final pickedFile = await ImagePicker().pickVideo(source: source);
    if (pickedFile == null) {
      return null;
    }

    return onVideoPickCallback(File(pickedFile.path));
  }

  static Future<String?> _pickVideoDesktop(
      BuildContext context,
      FilePickImpl filePickImpl,
      OnVideoPickCallback onVideoPickCallback) async {
    final filePath = await filePickImpl(context);
    if (filePath == null || filePath.isEmpty) return null;

    final file = File(filePath);
    return onVideoPickCallback(file);
  }
}
