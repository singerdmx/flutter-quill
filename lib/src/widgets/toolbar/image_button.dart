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

class ImageButton extends StatefulWidget {
  const ImageButton({
    required this.icon,
    required this.controller,
    required this.imageSource,
    this.iconSize = kDefaultIconSize,
    this.onImagePickCallback,
    this.imagePickImpl,
    Key? key,
  }) : super(key: key);

  final IconData icon;
  final double iconSize;

  final QuillController controller;

  final OnImagePickCallback? onImagePickCallback;

  final ImagePickImpl? imagePickImpl;

  final ImageSource imageSource;

  @override
  _ImageButtonState createState() => _ImageButtonState();
}

class _ImageButtonState extends State<ImageButton> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return QuillIconButton(
      icon: Icon(
        widget.icon,
        size: widget.iconSize,
        color: theme.iconTheme.color,
      ),
      highlightElevation: 0,
      hoverElevation: 0,
      size: widget.iconSize * 1.77,
      fillColor: theme.canvasColor,
      onPressed: _handleImageButtonTap,
    );
  }

  Future<void> _handleImageButtonTap() async {
    final index = widget.controller.selection.baseOffset;
    final length = widget.controller.selection.extentOffset - index;

    String? imageUrl;
    if (widget.imagePickImpl != null) {
      imageUrl = await widget.imagePickImpl!(widget.imageSource);
    } else {
      if (kIsWeb) {
        imageUrl = await _pickImageWeb();
      } else if (Platform.isAndroid || Platform.isIOS) {
        imageUrl = await _pickImage(widget.imageSource);
      } else {
        imageUrl = await _pickImageDesktop();
      }
    }

    if (imageUrl != null) {
      widget.controller
          .replaceText(index, length, BlockEmbed.image(imageUrl), null);
    }
  }

  Future<String?> _pickImageWeb() async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null) {
      return null;
    }

    // Take first, because we don't allow picking multiple files.
    final fileName = result.files.first.name!;
    final file = File(fileName);

    return widget.onImagePickCallback!(file);
  }

  Future<String?> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().getImage(source: source);
    if (pickedFile == null) {
      return null;
    }

    return widget.onImagePickCallback!(File(pickedFile.path));
  }

  Future<String?> _pickImageDesktop() async {
    final filePath = await FilesystemPicker.open(
      context: context,
      rootDirectory: await getApplicationDocumentsDirectory(),
      fsType: FilesystemType.file,
      fileTileSelectMode: FileTileSelectMode.wholeTile,
    );
    if (filePath == null || filePath.isEmpty) return null;

    final file = File(filePath);
    return widget.onImagePickCallback!(file);
  }
}
