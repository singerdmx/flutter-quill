import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../../models/documents/nodes/embed.dart';
import '../controller.dart';
import '../toolbar.dart';
import 'quill_icon_button.dart';

class ImageButton extends StatelessWidget {
  const ImageButton({
    required this.icon,
    required this.controller,
    required this.imageSource,
    this.iconSize = kDefaultIconSize,
    this.fillColor,
    this.onImagePickCallback,
    this.imagePickImpl,
    Key? key,
  }) : super(key: key);

  final IconData icon;
  final double iconSize;

  final Color? fillColor;

  final QuillController controller;

  final OnImagePickCallback? onImagePickCallback;

  final ImagePickImpl? imagePickImpl;

  final ImageSource imageSource;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return QuillIconButton(
      icon: Icon(icon, size: iconSize, color: theme.iconTheme.color),
      highlightElevation: 0,
      hoverElevation: 0,
      size: iconSize * 1.77,
      fillColor: fillColor ?? theme.canvasColor,
      onPressed: () => _handleImageButtonTap(context),
    );
  }

  Future<void> _handleImageButtonTap(BuildContext context) async {
    final index = controller.selection.baseOffset;
    final length = controller.selection.extentOffset - index;

    String? imageUrl;
    if (imagePickImpl != null) {
      imageUrl = await imagePickImpl!(imageSource);
    } else {
      if (kIsWeb) {
        imageUrl = await _pickImageWeb();
      } else if (Platform.isAndroid || Platform.isIOS) {
        imageUrl = await _pickImage(imageSource);
      } else {
        imageUrl = await _pickImageDesktop(context);
      }
    }

    if (imageUrl != null) {
      controller.replaceText(index, length, BlockEmbed.image(imageUrl), null);
    }
  }

  Future<String?> _pickImageWeb() async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null) {
      return null;
    }

    // Take first, because we don't allow picking multiple files.
    final fileName = result.files.first.name;
    final file = File(fileName);

    return onImagePickCallback!(file);
  }

  Future<String?> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().getImage(source: source);
    if (pickedFile == null) {
      return null;
    }

    return onImagePickCallback!(File(pickedFile.path));
  }

  Future<String?> _pickImageDesktop(BuildContext context) async {
    final filePath = await FilesystemPicker.open(
      context: context,
      rootDirectory: await getApplicationDocumentsDirectory(),
      fsType: FilesystemType.file,
      fileTileSelectMode: FileTileSelectMode.wholeTile,
    );
    if (filePath == null || filePath.isEmpty) return null;

    final file = File(filePath);
    return onImagePickCallback!(file);
  }
}
