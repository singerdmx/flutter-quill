import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/internal.dart';
import 'package:image_picker/image_picker.dart';

import '../../common/image_video_utils.dart';
import '../../editor/image/image_embed_types.dart';
import 'models/image_config.dart';
import 'select_image_source.dart';

class QuillToolbarImageButton extends StatelessWidget {
  const QuillToolbarImageButton({
    required this.controller,
    this.options = const QuillToolbarImageButtonOptions(),
    super.key,
  });

  final QuillController controller;

  final QuillToolbarImageButtonOptions options;

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
    return options.iconData ?? Icons.image;
  }

  String _tooltip(BuildContext context) {
    return options.tooltip ?? context.loc.insertImage;
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
        QuillToolbarImageButtonOptions(
          afterButtonPressed: _afterButtonPressed(context),
          iconData: iconData,
          iconSize: iconSize,
          iconButtonFactor: iconButtonFactor,
          dialogTheme: options.dialogTheme,
          iconTheme: options.iconTheme,
          linkRegExp: options.linkRegExp,
          tooltip: options.tooltip,
          imageButtonConfig: options.imageButtonConfig,
        ),
        QuillToolbarImageButtonExtraOptions(
          context: context,
          controller: controller,
          onPressed: () => _sharedOnPressed(context),
        ),
      );
    }

    return QuillToolbarIconButton(
      icon: Icon(
        iconData,
        size: iconButtonFactor * iconSize,
      ),
      tooltip: tooltip,
      isSelected: false,
      onPressed: () => _sharedOnPressed(context),
      iconTheme: _iconTheme(context),
    );
  }

  Future<void> _onPressedHandler(BuildContext context) async {
    final onRequestPickImage = options.imageButtonConfig.onRequestPickImage;
    if (onRequestPickImage != null) {
      final imageUrl = await onRequestPickImage(
        context,
      );
      if (imageUrl != null) {
        await options.imageButtonConfig
            .onImageInsertCallback(imageUrl, controller);
        await options.imageButtonConfig.onImageInsertedCallback?.call(imageUrl);
      }
      return;
    }
    final source = await showSelectImageSourceDialog(
      context: context,
    );
    if (source == null) {
      return;
    }

    final imageUrl = switch (source) {
      InsertImageSource.gallery =>
        (await ImagePicker().pickImage(source: ImageSource.gallery))?.path,
      InsertImageSource.link =>
        context.mounted ? await _typeLink(context) : null,
      InsertImageSource.camera =>
        (await ImagePicker().pickImage(source: ImageSource.camera))?.path,
    };
    if (imageUrl == null) {
      return;
    }
    if (imageUrl.trim().isNotEmpty) {
      await options.imageButtonConfig
          .onImageInsertCallback(imageUrl, controller);
      await options.imageButtonConfig.onImageInsertedCallback?.call(imageUrl);
    }
  }

  Future<String?> _typeLink(BuildContext context) async {
    final value = await showDialog<String>(
      context: context,
      builder: (_) => TypeLinkDialog(
        dialogTheme: options.dialogTheme,
        linkRegExp: options.linkRegExp,
        linkType: LinkType.image,
      ),
    );
    return value;
  }
}
