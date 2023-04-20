import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/extensions.dart';
import 'package:flutter_quill/flutter_quill.dart' hide Text;
import 'package:flutter_quill/translations.dart';
import 'package:image_picker/image_picker.dart';

import '../embed_types.dart';
import 'image_video_utils.dart' hide LinkDialog;

/// Alternative version of [ImageButton]. This widget has more customization
/// and uses dialog similar to one which is used on [http://quilljs.com].
class ImageButton2 extends StatelessWidget {
  const ImageButton2({
    required this.controller,
    required this.icon,
    this.iconSize = kDefaultIconSize,
    this.fillColor,
    this.onImagePickCallback,
    this.webImagePickImpl,
    this.filePickImpl,
    this.mediaPickSettingSelector,
    this.iconTheme,
    this.dialogTheme,
    this.tooltip,
    this.childrenSpacing = 16.0,
    this.contentPadding = const EdgeInsets.all(16),
    this.constraints,
    this.buttonSize,
    this.labelText,
    this.hintText,
    this.buttonText,
    this.autovalidateMode = AutovalidateMode.disabled,
    Key? key,
    this.validationMessage,
  }) : super(key: key);

  final QuillController controller;
  final IconData icon;
  final double iconSize;
  final Color? fillColor;
  final OnImagePickCallback? onImagePickCallback;
  final WebImagePickImpl? webImagePickImpl;
  final FilePickImpl? filePickImpl;
  final MediaPickSettingSelector? mediaPickSettingSelector;
  final QuillIconTheme? iconTheme;
  final QuillDialogTheme? dialogTheme;
  final String? tooltip;

  /// The margin between child widgets in the dialog.
  final double childrenSpacing;

  /// The padding for content of dialog.
  final EdgeInsetsGeometry contentPadding;

  /// The constrains for dialog.
  final BoxConstraints? constraints;

  /// The size of dialog buttons.
  final Size? buttonSize;

  /// The text of label in link add mode.
  final String? labelText;

  /// The hint text for link [TextField].
  final String? hintText;

  /// The text of the submit button.
  final String? buttonText;

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

  void _pickImage(BuildContext context) {
    ImageVideoUtils.handleImageButtonTap(
      context,
      controller,
      ImageSource.gallery,
      onImagePickCallback!,
      filePickImpl: filePickImpl,
      webImagePickImpl: webImagePickImpl,
    );
  }

  void _typeLink(BuildContext context) {
    showDialog<String>(
      context: context,
      builder: (_) => EmbedLinkDialog(
        dialogTheme: dialogTheme,
        constraints: constraints,
        labelText: labelText,
        childrenSpacing: childrenSpacing,
        autovalidateMode: autovalidateMode,
        validationMessage: validationMessage,
        buttonSize: buttonSize,
      ),
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

///
class EmbedLinkDialog extends StatefulWidget {
  const EmbedLinkDialog({
    Key? key,
    this.link,
    this.dialogTheme,
    this.contentPadding = const EdgeInsets.all(16),
    this.childrenSpacing = 16.0,
    this.constraints,
    this.buttonSize,
    this.labelText,
    this.hintText,
    this.buttonText,
    this.autovalidateMode = AutovalidateMode.disabled,
    this.validationMessage,
  })  : assert(childrenSpacing > 0),
        super(key: key);

  final String? link;
  final QuillDialogTheme? dialogTheme;

  /// The margin between child widgets in the dialog.
  final double childrenSpacing;

  /// The padding for content of dialog.
  final EdgeInsetsGeometry contentPadding;

  /// The constrains for dialog.
  final BoxConstraints? constraints;

  /// The size of dialog buttons.
  final Size? buttonSize;

  /// The text of label in link add mode.
  final String? labelText;

  /// The hint text for link [TextField].
  final String? hintText;

  /// The text of the submit button.
  final String? buttonText;

  final AutovalidateMode autovalidateMode;
  final String? validationMessage;

  @override
  State<EmbedLinkDialog> createState() => _EmbedLinkDialogState();
}

class _EmbedLinkDialogState extends State<EmbedLinkDialog> {
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
      Text(widget.labelText ?? 'Enter link'.i18n),
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
          padding: widget.contentPadding,
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
