// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/translations.dart';

import '../../../../logic/models/config/shared_configurations.dart';
import '../../../../logic/services/image_picker/image_picker.dart';
import '../../../models/config/toolbar/buttons/image.dart';
import '../../embed_types/image.dart';
import '../utils/image_video_utils.dart';
import 'select_image_source.dart';

class QuillToolbarImageButton extends StatelessWidget {
  const QuillToolbarImageButton({
    required this.controller,
    required this.options,
    super.key,
  });

  final QuillController controller;

  final QuillToolbarImageButtonOptions options;

  double _iconSize(BuildContext context) {
    final baseFontSize = baseButtonExtraOptions(context).globalIconSize;
    final iconSize = options.iconSize;
    return iconSize ?? baseFontSize;
  }

  double _iconButtonFactor(BuildContext context) {
    final baseIconFactor =
        baseButtonExtraOptions(context).globalIconButtonFactor;
    final iconButtonFactor = options.iconButtonFactor;
    return iconButtonFactor ?? baseIconFactor;
  }

  VoidCallback? _afterButtonPressed(BuildContext context) {
    return options.afterButtonPressed ??
        baseButtonExtraOptions(context).afterButtonPressed;
  }

  QuillIconTheme? _iconTheme(BuildContext context) {
    return options.iconTheme ?? baseButtonExtraOptions(context).iconTheme;
  }

  QuillToolbarBaseButtonOptions baseButtonExtraOptions(BuildContext context) {
    return context.requireQuillToolbarBaseButtonOptions;
  }

  IconData _iconData(BuildContext context) {
    return options.iconData ??
        baseButtonExtraOptions(context).iconData ??
        Icons.image;
  }

  String _tooltip(BuildContext context) {
    return options.tooltip ??
        baseButtonExtraOptions(context).tooltip ??
        context.loc.insertImage;
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
    final childBuilder =
        options.childBuilder ?? baseButtonExtraOptions(context).childBuilder;

    if (childBuilder != null) {
      return childBuilder(
        QuillToolbarImageButtonOptions(
          afterButtonPressed: _afterButtonPressed(context),
          iconData: iconData,
          iconSize: iconSize,
          iconButtonFactor: iconButtonFactor,
          dialogTheme: options.dialogTheme,
          fillColor: options.fillColor,
          iconTheme: options.iconTheme,
          linkRegExp: options.linkRegExp,
          tooltip: options.tooltip,
          imageButtonConfigurations: options.imageButtonConfigurations,
        ),
        QuillToolbarImageButtonExtraOptions(
          context: context,
          controller: controller,
          onPressed: () => _sharedOnPressed(context),
        ),
      );
    }

    final theme = Theme.of(context);

    final iconTheme = _iconTheme(context);

    final iconColor = iconTheme?.iconUnselectedColor ?? theme.iconTheme.color;
    final iconFillColor = iconTheme?.iconUnselectedFillColor ??
        (options.fillColor ?? theme.canvasColor);

    return QuillToolbarIconButton(
      icon: Icon(
        iconData,
        size: iconSize,
        color: iconColor,
      ),
      tooltip: tooltip,
      highlightElevation: 0,
      hoverElevation: 0,
      size: iconSize * 1.77,
      fillColor: iconFillColor,
      borderRadius: iconTheme?.borderRadius ?? 2,
      onPressed: () => _sharedOnPressed(context),
    );
  }

  Future<void> _onPressedHandler(BuildContext context) async {
    final imagePickerService =
        QuillSharedExtensionsConfigurations.get(context: context)
            .imagePickerService;

    final onRequestPickImage =
        options.imageButtonConfigurations.onRequestPickImage;
    if (onRequestPickImage != null) {
      final imageUrl = await onRequestPickImage(
        context,
        imagePickerService,
      );
      if (imageUrl != null) {
        await options.imageButtonConfigurations
            .onImageInsertCallback(imageUrl, controller);
        await options.imageButtonConfigurations.onImageInsertedCallback
            ?.call(imageUrl);
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
      InsertImageSource.gallery => (await imagePickerService.pickImage(
          source: ImageSource.gallery,
        ))
            ?.path,
      InsertImageSource.link => await _typeLink(context),
      InsertImageSource.camera => (await imagePickerService.pickImage(
          source: ImageSource.camera,
        ))
            ?.path,
    };
    if (imageUrl == null) {
      return;
    }
    if (imageUrl.trim().isNotEmpty) {
      await options.imageButtonConfigurations
          .onImageInsertCallback(imageUrl, controller);
      await options.imageButtonConfigurations.onImageInsertedCallback
          ?.call(imageUrl);
    }
  }

  Future<String?> _typeLink(BuildContext context) async {
    final value = await showDialog<String>(
      context: context,
      builder: (_) => QuillProvider.value(
        value: context.requireQuillProvider,
        child: FlutterQuillLocalizationsWidget(
          child: TypeLinkDialog(
            dialogTheme: options.dialogTheme,
            linkRegExp: options.linkRegExp,
            linkType: LinkType.image,
          ),
        ),
      ),
    );
    return value;
  }
}
