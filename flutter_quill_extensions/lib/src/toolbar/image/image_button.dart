import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/internal.dart';
import 'package:image_picker/image_picker.dart';

import '../../common/default_image_insert.dart';
import '../../common/image_video_utils.dart';
import '../../editor/image/image_embed_types.dart';
import '../quill_simple_toolbar_api.dart';
import 'config/image_config.dart';
import 'select_image_source.dart';

// ignore: invalid_use_of_internal_member
class QuillToolbarImageButton extends QuillToolbarBaseButtonStateless {
  const QuillToolbarImageButton({
    required super.controller,
    QuillToolbarImageButtonOptions? options,

    /// Shares common options between all buttons, prefer the [options]
    /// over the [baseOptions].
    super.baseOptions,
    super.key,
  })  : _options = options,
        super(options: options);

  final QuillToolbarImageButtonOptions? _options;

  @override
  QuillToolbarImageButtonOptions? get options => _options;

  void _sharedOnPressed(BuildContext context) {
    _onPressedHandler(context);
    afterButtonPressed(context);
  }

  Future<void> _handleImageInsert(String imageUrl) async {
    await handleImageInsert(
      imageUrl,
      controller: controller,
      onImageInsertCallback: options?.imageButtonConfig?.onImageInsertCallback,
      onImageInsertedCallback:
          options?.imageButtonConfig?.onImageInsertedCallback,
    );
  }

  Future<void> _onPressedHandler(BuildContext context) async {
    final onRequestPickImage = options?.imageButtonConfig?.onRequestPickImage;
    if (onRequestPickImage != null) {
      final imageUrl = await onRequestPickImage(
        context,
      );
      if (imageUrl != null) {
        await _handleImageInsert(imageUrl);
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
      await _handleImageInsert(imageUrl);
    }
  }

  Future<String?> _typeLink(BuildContext context) async {
    final value = await showDialog<String>(
      context: context,
      builder: (_) => TypeLinkDialog(
        dialogTheme: options?.dialogTheme,
        linkRegExp: options?.linkRegExp,
        linkType: LinkType.image,
      ),
    );
    return value;
  }

  @override
  Widget buildButton(BuildContext context) {
    return QuillToolbarIconButton(
      icon: Icon(
        iconData(context),
        size: iconButtonFactor(context) * iconSize(context),
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
      QuillToolbarImageButtonOptions(
        afterButtonPressed: afterButtonPressed(context),
        iconData: iconData(context),
        iconSize: iconSize(context),
        iconButtonFactor: iconButtonFactor(context),
        dialogTheme: options?.dialogTheme,
        iconTheme: options?.iconTheme,
        linkRegExp: options?.linkRegExp,
        tooltip: tooltip(context),
        imageButtonConfig: options?.imageButtonConfig,
      ),
      QuillToolbarImageButtonExtraOptions(
        context: context,
        controller: controller,
        onPressed: () => _sharedOnPressed(context),
      ),
    );
  }

  @override
  IconData Function(BuildContext context) get getDefaultIconData =>
      (context) => Icons.image;

  @override
  String Function(BuildContext context) get getDefaultTooltip =>
      (context) => context.loc.insertImage;
}
