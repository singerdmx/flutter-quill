//import 'dart:io';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/extensions.dart';
import 'package:flutter_quill/flutter_quill.dart' hide Text;
import 'package:flutter_quill/translations.dart';
import 'package:image_picker/image_picker.dart';

import '../embed_types.dart';

/// Widget which combines [ImageButton] and [VideButton] widgets. This widget
/// has more customization and uses dialog similar to one which is used
/// on [http://quilljs.com].
class MediaButton extends StatelessWidget {
  const MediaButton({
    required this.controller,
    required this.icon,
    this.type = QuillMediaType.image,
    this.iconSize = kDefaultIconSize,
    this.fillColor,
    this.mediaFilePicker = _defaultMediaPicker,
    this.onMediaPickedCallback,
    this.iconTheme,
    this.dialogTheme,
    this.tooltip,
    this.childrenSpacing = 16.0,
    this.labelText,
    this.hintText,
    this.submitButtonText,
    this.submitButtonSize,
    this.galleryButtonText,
    this.linkButtonText,
    this.autovalidateMode = AutovalidateMode.disabled,
    Key? key,
    this.validationMessage,
  })  : assert(type == QuillMediaType.image,
            'Video selection is not supported yet'),
        super(key: key);

  final QuillController controller;
  final IconData icon;
  final double iconSize;
  final Color? fillColor;
  final QuillMediaType type;
  final QuillIconTheme? iconTheme;
  final QuillDialogTheme? dialogTheme;
  final String? tooltip;
  final MediaFilePicker mediaFilePicker;
  final MediaPickedCallback? onMediaPickedCallback;

  /// The margin between child widgets in the dialog.
  final double childrenSpacing;

  /// The text of label in link add mode.
  final String? labelText;

  /// The hint text for link [TextField].
  final String? hintText;

  /// The text of the submit button.
  final String? submitButtonText;

  /// The size of dialog buttons.
  final Size? submitButtonSize;

  /// The text of the gallery button [MediaSourceSelectorDialog].
  final String? galleryButtonText;

  /// The text of the link button [MediaSourceSelectorDialog].
  final String? linkButtonText;

  final AutovalidateMode autovalidateMode;
  final String? validationMessage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconColor = iconTheme?.iconUnselectedColor ?? theme.iconTheme.color;
    final iconFillColor =
        iconTheme?.iconUnselectedFillColor ?? fillColor ?? theme.canvasColor;

    return QuillIconButton(
      icon: Icon(icon, size: iconSize, color: iconColor),
      tooltip: tooltip,
      highlightElevation: 0,
      hoverElevation: 0,
      size: iconSize * 1.77,
      fillColor: iconFillColor,
      borderRadius: iconTheme?.borderRadius ?? 2,
      onPressed: () => _onPressedHandler(context),
    );
  }

  Future<void> _onPressedHandler(BuildContext context) async {
    if (onMediaPickedCallback != null) {
      final mediaSource = await showDialog<MediaPickSetting>(
        context: context,
        builder: (_) => MediaSourceSelectorDialog(
          dialogTheme: dialogTheme,
          galleryButtonText: galleryButtonText,
          linkButtonText: linkButtonText,
        ),
      );
      if (mediaSource != null) {
        if (mediaSource == MediaPickSetting.Gallery) {
          await _pickImage();
        } else {
          _inputLink(context);
        }
      }
    } else {
      _inputLink(context);
    }
  }

  Future<void> _pickImage() async {
    if (!(kIsWeb || isMobile() || isDesktop())) {
      throw UnsupportedError(
          'Unsupported target platform: ${defaultTargetPlatform.name}');
    }

    final mediaFileUrl = await _pickMediaFileUrl();

    if (mediaFileUrl != null) {
      final index = controller.selection.baseOffset;
      final length = controller.selection.extentOffset - index;
      controller.replaceText(
          index, length, BlockEmbed.image(mediaFileUrl), null);
    }
  }

  Future<MediaFileUrl?> _pickMediaFileUrl() async {
    final mediaFile = await mediaFilePicker(type);
    return mediaFile != null ? onMediaPickedCallback?.call(mediaFile) : null;
  }

  void _inputLink(BuildContext context) {
    showDialog<String>(
      context: context,
      builder: (_) => MediaLinkDialog(
        dialogTheme: dialogTheme,
        labelText: labelText,
        hintText: hintText,
        buttonText: submitButtonText,
        buttonSize: submitButtonSize,
        childrenSpacing: childrenSpacing,
        autovalidateMode: autovalidateMode,
        validationMessage: validationMessage,
      ),
    ).then(_linkSubmitted);
  }

  void _linkSubmitted(String? value) {
    if (value != null && value.isNotEmpty) {
      final index = controller.selection.baseOffset;
      final length = controller.selection.extentOffset - index;
      final data =
          type.isImage ? BlockEmbed.image(value) : BlockEmbed.video(value);
      controller.replaceText(index, length, data, null);
    }
  }
}

/// Provides a dialog for input link to media resource.
class MediaLinkDialog extends StatefulWidget {
  const MediaLinkDialog({
    Key? key,
    this.link,
    this.dialogTheme,
    this.childrenSpacing = 16.0,
    this.labelText,
    this.hintText,
    this.buttonText,
    this.buttonSize,
    this.autovalidateMode = AutovalidateMode.disabled,
    this.validationMessage,
  })  : assert(childrenSpacing > 0),
        super(key: key);

  final String? link;
  final QuillDialogTheme? dialogTheme;

  /// The margin between child widgets in the dialog.
  final double childrenSpacing;

  /// The text of label in link add mode.
  final String? labelText;

  /// The hint text for link [TextField].
  final String? hintText;

  /// The text of the submit button.
  final String? buttonText;

  /// The size of dialog buttons.
  final Size? buttonSize;

  final AutovalidateMode autovalidateMode;
  final String? validationMessage;

  @override
  State<MediaLinkDialog> createState() => _MediaLinkDialogState();
}

class _MediaLinkDialogState extends State<MediaLinkDialog> {
  final _linkFocus = FocusNode();
  final _linkController = TextEditingController();

  @override
  void dispose() {
    _linkFocus.dispose();
    _linkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final constraints = widget.dialogTheme?.linkDialogConstraints ??
        () {
          final mediaQuery = MediaQuery.of(context);
          final maxWidth =
              kIsWeb ? mediaQuery.size.width / 4 : mediaQuery.size.width - 80;
          return BoxConstraints(maxWidth: maxWidth, maxHeight: 80);
        }();

    final buttonStyle = widget.buttonSize != null
        ? Theme.of(context)
            .elevatedButtonTheme
            .style
            ?.copyWith(fixedSize: MaterialStatePropertyAll(widget.buttonSize))
        : widget.dialogTheme?.buttonStyle;

    final isWrappable = widget.dialogTheme?.isWrappable ?? false;

    final children = [
      Text(widget.labelText ?? 'Enter media'.i18n),
      UtilityWidgets.maybeWidget(
        enabled: !isWrappable,
        wrapper: (child) => Expanded(
          child: child,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: widget.childrenSpacing),
          child: TextFormField(
            controller: _linkController,
            focusNode: _linkFocus,
            style: widget.dialogTheme?.inputTextStyle,
            keyboardType: TextInputType.url,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              labelStyle: widget.dialogTheme?.labelTextStyle,
              hintText: widget.hintText,
            ),
            autofocus: true,
            autovalidateMode: widget.autovalidateMode,
            validator: _validateLink,
            onChanged: _linkChanged,
          ),
        ),
      ),
      ElevatedButton(
        onPressed: _canPress() ? _submitLink : null,
        style: buttonStyle,
        child: Text(widget.buttonText ?? 'Ok'.i18n),
      ),
    ];

    return Dialog(
      backgroundColor: widget.dialogTheme?.dialogBackgroundColor,
      shape: widget.dialogTheme?.shape ??
          DialogTheme.of(context).shape ??
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      child: ConstrainedBox(
        constraints: constraints,
        child: Padding(
          padding:
              widget.dialogTheme?.linkDialogPadding ?? const EdgeInsets.all(16),
          child: isWrappable
              ? Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  runSpacing: widget.dialogTheme?.runSpacing ?? 0.0,
                  children: children,
                )
              : Row(
                  children: children,
                ),
        ),
      ),
    );
  }

  bool _canPress() => _validateLink(_linkController.text) == null;

  void _linkChanged(String value) {
    setState(() {
      _linkController.text = value;
    });
  }

  void _submitLink() => Navigator.pop(context, _linkController.text);

  String? _validateLink(String? value) {
    if ((value?.isEmpty ?? false) ||
        !AutoFormatMultipleLinksRule.linkRegExp.hasMatch(value!)) {
      return widget.validationMessage ?? 'That is not a valid URL';
    }

    return null;
  }
}

/// Media souce selector.
class MediaSourceSelectorDialog extends StatelessWidget {
  const MediaSourceSelectorDialog({
    Key? key,
    this.dialogTheme,
    this.galleryButtonText,
    this.linkButtonText,
  }) : super(key: key);

  final QuillDialogTheme? dialogTheme;

  /// The text of the gallery button [MediaSourceSelectorDialog].
  final String? galleryButtonText;

  /// The text of the link button [MediaSourceSelectorDialog].
  final String? linkButtonText;

  @override
  Widget build(BuildContext context) {
    final constraints = dialogTheme?.mediaSelectorDialogConstraints ??
        () {
          final mediaQuery = MediaQuery.of(context);
          double maxWidth, maxHeight;
          if (kIsWeb) {
            maxWidth = mediaQuery.size.width / 7;
            maxHeight = mediaQuery.size.height / 7;
          } else {
            maxWidth = mediaQuery.size.width - 80;
            maxHeight = maxWidth / 2;
          }
          return BoxConstraints(maxWidth: maxWidth, maxHeight: maxHeight);
        }();

    final shape = dialogTheme?.shape ??
        DialogTheme.of(context).shape ??
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(4));

    return Dialog(
      backgroundColor: dialogTheme?.dialogBackgroundColor,
      shape: shape,
      child: ConstrainedBox(
        constraints: constraints,
        child: Padding(
          padding: dialogTheme?.mediaSelectorDialogPadding ??
              const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: TextButtonWithIcon(
                  icon: Icons.collections,
                  label: galleryButtonText ?? 'Gallery'.i18n,
                  onPressed: () =>
                      Navigator.pop(context, MediaPickSetting.Gallery),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextButtonWithIcon(
                  icon: Icons.link,
                  label: linkButtonText ?? 'Link'.i18n,
                  onPressed: () =>
                      Navigator.pop(context, MediaPickSetting.Link),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class TextButtonWithIcon extends StatelessWidget {
  const TextButtonWithIcon({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.textStyle,
    Key? key,
  }) : super(key: key);

  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scale = MediaQuery.maybeOf(context)?.textScaleFactor ?? 1;
    final gap = scale <= 1 ? 8.0 : lerpDouble(8, 4, math.min(scale - 1, 1))!;
    final buttonStyle = TextButtonTheme.of(context).style;
    final shape = buttonStyle?.shape?.resolve({}) ??
        const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(4)));
    return Material(
      shape: shape,
      textStyle: textStyle ??
          theme.textButtonTheme.style?.textStyle?.resolve({}) ??
          theme.textTheme.labelLarge,
      elevation: buttonStyle?.elevation?.resolve({}) ?? 0,
      child: InkWell(
        customBorder: shape,
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(icon),
              SizedBox(height: gap),
              Flexible(child: Text(label)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Default file picker.
Future<QuillFile?> _defaultMediaPicker(QuillMediaType mediaType) async {
  final pickedFile = mediaType.isImage
      ? await ImagePicker().pickImage(source: ImageSource.gallery)
      : await ImagePicker().pickVideo(source: ImageSource.gallery);

  if (pickedFile != null) {
    return QuillFile(
      name: pickedFile.name,
      path: pickedFile.path,
      bytes: await pickedFile.readAsBytes(),
    );
  }

  return null;
}
