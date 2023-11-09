import 'package:flutter/material.dart';

import '../../../models/documents/attribute.dart';
import '../../../models/rules/insert.dart';
import '../../../models/structs/link_dialog_action.dart';
import '../../../models/themes/quill_dialog_theme.dart';
import '../../../models/themes/quill_icon_theme.dart';
import '../../../translations/toolbar.i18n.dart';
import '../../../utils/extensions/build_context.dart';
import '../../controller.dart';
import '../../link.dart';
import '../base_toolbar.dart';

class QuillToolbarLinkStyleButton extends StatefulWidget {
  const QuillToolbarLinkStyleButton({
    required this.controller,
    required this.options,
    super.key,
  });

  final QuillController controller;
  final QuillToolbarLinkStyleButtonOptions options;

  @override
  QuillToolbarLinkStyleButtonState createState() =>
      QuillToolbarLinkStyleButtonState();
}

class QuillToolbarLinkStyleButtonState
    extends State<QuillToolbarLinkStyleButton> {
  void _didChangeSelection() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    controller.addListener(_didChangeSelection);
  }

  @override
  void didUpdateWidget(covariant QuillToolbarLinkStyleButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != controller) {
      oldWidget.controller.removeListener(_didChangeSelection);
      controller.addListener(_didChangeSelection);
    }
  }

  @override
  void dispose() {
    super.dispose();
    controller.removeListener(_didChangeSelection);
  }

  QuillController get controller {
    return widget.controller;
  }

  QuillToolbarLinkStyleButtonOptions get options {
    return widget.options;
  }

  double get iconSize {
    final baseFontSize = baseButtonExtraOptions.globalIconSize;
    final iconSize = options.iconSize;
    return iconSize ?? baseFontSize;
  }

  double get iconButtonFactor {
    final baseIconFactor = baseButtonExtraOptions.globalIconButtonFactor;
    final iconButtonFactor = options.iconButtonFactor;
    return iconButtonFactor ?? baseIconFactor;
  }

  VoidCallback? get afterButtonPressed {
    return options.afterButtonPressed ??
        baseButtonExtraOptions.afterButtonPressed;
  }

  QuillIconTheme? get iconTheme {
    return options.iconTheme ?? baseButtonExtraOptions.iconTheme;
  }

  QuillToolbarBaseButtonOptions get baseButtonExtraOptions {
    return context.requireQuillToolbarBaseButtonOptions;
  }

  String get tooltip {
    return options.tooltip ??
        baseButtonExtraOptions.tooltip ??
        'Insert URL'.i18n;
  }

  IconData get iconData {
    return options.iconData ?? baseButtonExtraOptions.iconData ?? Icons.link;
  }

  Color get dialogBarrierColor {
    return options.dialogBarrierColor ??
        context.requireQuillSharedConfigurations.dialogBarrierColor;
  }

  RegExp? get linkRegExp {
    return options.linkRegExp;
  }

  @override
  Widget build(BuildContext context) {
    final isToggled = _getLinkAttributeValue() != null;

    final childBuilder =
        options.childBuilder ?? baseButtonExtraOptions.childBuilder;
    if (childBuilder != null) {
      return childBuilder(
        QuillToolbarLinkStyleButtonOptions(
          afterButtonPressed: afterButtonPressed,
          controller: controller,
          dialogBarrierColor: dialogBarrierColor,
          dialogTheme: options.dialogTheme,
          iconData: iconData,
          iconSize: iconSize,
          tooltip: tooltip,
          linkDialogAction: options.linkDialogAction,
          linkRegExp: linkRegExp,
          iconTheme: iconTheme,
        ),
        QuillToolbarLinkStyleButtonExtraOptions(
          context: context,
          controller: controller,
          onPressed: () {
            _openLinkDialog(context);
            afterButtonPressed?.call();
          },
        ),
      );
    }
    final theme = Theme.of(context);
    return QuillToolbarIconButton(
      tooltip: tooltip,
      highlightElevation: 0,
      hoverElevation: 0,
      size: iconSize * iconButtonFactor,
      icon: Icon(
        iconData,
        size: iconSize,
        color: isToggled
            ? (iconTheme?.iconSelectedColor ?? theme.primaryIconTheme.color)
            : (iconTheme?.iconUnselectedColor ?? theme.iconTheme.color),
      ),
      fillColor: isToggled
          ? (iconTheme?.iconSelectedFillColor ?? theme.primaryColor)
          : (iconTheme?.iconUnselectedFillColor ?? theme.canvasColor),
      borderRadius: iconTheme?.borderRadius ?? 2,
      onPressed: () => _openLinkDialog(context),
      afterPressed: afterButtonPressed,
    );
  }

  Future<void> _openLinkDialog(BuildContext context) async {
    // TODO: Add a custom call back to customize this just like in the search
    // button
    final value = await showDialog<_TextLink>(
      context: context,
      barrierColor: dialogBarrierColor,
      builder: (ctx) {
        final link = _getLinkAttributeValue();
        final index = controller.selection.start;

        String? text;
        if (link != null) {
          // text should be the link's corresponding text, not selection
          final leaf = controller.document.querySegmentLeafNode(index).leaf;
          if (leaf != null) {
            text = leaf.toPlainText();
          }
        }

        final len = controller.selection.end - index;
        text ??= len == 0 ? '' : controller.document.getPlainText(index, len);
        return _LinkDialog(
          dialogTheme: options.dialogTheme,
          link: link,
          text: text,
          linkRegExp: linkRegExp,
          action: options.linkDialogAction,
        );
      },
    );
    if (value == null) {
      return;
    }
    _linkSubmitted(value);
  }

  String? _getLinkAttributeValue() {
    return controller.getSelectionStyle().attributes[Attribute.link.key]?.value;
  }

  void _linkSubmitted(_TextLink value) {
    var index = controller.selection.start;
    var length = controller.selection.end - index;
    if (_getLinkAttributeValue() != null) {
      // text should be the link's corresponding text, not selection
      final leaf = controller.document.querySegmentLeafNode(index).leaf;
      if (leaf != null) {
        final range = getLinkRange(leaf);
        index = range.start;
        length = range.end - range.start;
      }
    }
    controller
      ..replaceText(index, length, value.text, null)
      ..formatText(
        index,
        value.text.length,
        LinkAttribute(value.link),
      );
  }
}

class _LinkDialog extends StatefulWidget {
  const _LinkDialog({
    this.dialogTheme,
    this.link,
    this.text,
    this.linkRegExp,
    this.action,
  });

  final QuillDialogTheme? dialogTheme;
  final String? link;
  final String? text;
  final RegExp? linkRegExp;
  final LinkDialogAction? action;

  @override
  _LinkDialogState createState() => _LinkDialogState();
}

class _LinkDialogState extends State<_LinkDialog> {
  late String _link;
  late String _text;

  RegExp get linkRegExp {
    return widget.linkRegExp ?? AutoFormatMultipleLinksRule.oneLineLinkRegExp;
  }

  late TextEditingController _linkController;
  late TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _link = widget.link ?? '';
    _text = widget.text ?? '';
    _linkController = TextEditingController(text: _link);
    _textController = TextEditingController(text: _text);
  }

  @override
  void dispose() {
    _linkController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: widget.dialogTheme?.dialogBackgroundColor,
      content: Form(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            TextFormField(
              keyboardType: TextInputType.text,
              style: widget.dialogTheme?.inputTextStyle,
              decoration: InputDecoration(
                labelText: 'Text'.i18n,
                hintText: 'Please enter a text for your link'.i18n,
                labelStyle: widget.dialogTheme?.labelTextStyle,
                floatingLabelStyle: widget.dialogTheme?.labelTextStyle,
              ),
              autofocus: true,
              onChanged: _textChanged,
              controller: _textController,
              textInputAction: TextInputAction.next,
              autofillHints: const [
                AutofillHints.name,
                AutofillHints.url,
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              keyboardType: TextInputType.url,
              style: widget.dialogTheme?.inputTextStyle,
              decoration: InputDecoration(
                labelText: 'Link'.i18n,
                hintText: 'Please enter the link url'.i18n,
                labelStyle: widget.dialogTheme?.labelTextStyle,
                floatingLabelStyle: widget.dialogTheme?.labelTextStyle,
              ),
              onChanged: _linkChanged,
              controller: _linkController,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.url],
              autocorrect: false,
              onEditingComplete: () {
                if (!_canPress()) {
                  return;
                }
                _applyLink();
              },
            ),
          ],
        ),
      ),
      actions: [
        _okButton(),
      ],
    );
  }

  Widget _okButton() {
    if (widget.action != null) {
      return widget.action!.builder(
        _canPress(),
        _applyLink,
      );
    }

    return TextButton(
      onPressed: _canPress() ? _applyLink : null,
      child: Text(
        'Ok'.i18n,
        style: widget.dialogTheme?.buttonTextStyle,
      ),
    );
  }

  bool _canPress() {
    if (_text.isEmpty || _link.isEmpty) {
      return false;
    }
    if (!linkRegExp.hasMatch(_link)) {
      return false;
    }

    return true;
  }

  void _linkChanged(String value) {
    setState(() {
      _link = value;
    });
  }

  void _textChanged(String value) {
    setState(() {
      _text = value;
    });
  }

  void _applyLink() {
    Navigator.pop(context, _TextLink(_text.trim(), _link.trim()));
  }
}

class _TextLink {
  _TextLink(
    this.text,
    this.link,
  );

  final String text;
  final String link;
}
