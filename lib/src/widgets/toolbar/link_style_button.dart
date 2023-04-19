import 'package:flutter/material.dart';

import '../../models/documents/attribute.dart';
import '../../models/rules/insert.dart';
import '../../models/themes/quill_dialog_theme.dart';
import '../../models/themes/quill_icon_theme.dart';
import '../../translations/toolbar.i18n.dart';
import '../controller.dart';
import '../link.dart';
import '../toolbar.dart';

class LinkStyleButton extends StatefulWidget {
  const LinkStyleButton({
    required this.controller,
    this.iconSize = kDefaultIconSize,
    this.icon,
    this.iconTheme,
    this.dialogTheme,
    this.afterButtonPressed,
    this.tooltip,
    this.useAlternativeDialog = false,
    Key? key,
  }) : super(key: key);

  final QuillController controller;
  final IconData? icon;
  final double iconSize;
  final QuillIconTheme? iconTheme;
  final QuillDialogTheme? dialogTheme;
  final VoidCallback? afterButtonPressed;
  final String? tooltip;
  final bool useAlternativeDialog;

  @override
  _LinkStyleButtonState createState() => _LinkStyleButtonState();
}

class _LinkStyleButtonState extends State<LinkStyleButton> {
  void _didChangeSelection() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_didChangeSelection);
  }

  @override
  void didUpdateWidget(covariant LinkStyleButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_didChangeSelection);
      widget.controller.addListener(_didChangeSelection);
    }
  }

  @override
  void dispose() {
    super.dispose();
    widget.controller.removeListener(_didChangeSelection);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isToggled = _getLinkAttributeValue() != null;
    final pressedHandler = () => _openLinkDialog(context);
    return QuillIconButton(
      tooltip: widget.tooltip,
      highlightElevation: 0,
      hoverElevation: 0,
      size: widget.iconSize * kIconButtonFactor,
      icon: Icon(
        widget.icon ?? Icons.link,
        size: widget.iconSize,
        color: isToggled
            ? (widget.iconTheme?.iconSelectedColor ??
                theme.primaryIconTheme.color)
            : (widget.iconTheme?.iconUnselectedColor ?? theme.iconTheme.color),
      ),
      fillColor: isToggled
          ? (widget.iconTheme?.iconSelectedFillColor ??
              Theme.of(context).primaryColor)
          : (widget.iconTheme?.iconUnselectedFillColor ?? theme.canvasColor),
      borderRadius: widget.iconTheme?.borderRadius ?? 2,
      onPressed: pressedHandler,
      afterPressed: widget.afterButtonPressed,
    );
  }

  Future<void> _openLinkDialog(BuildContext context) async {
    final initialTextLink = QuillTextLink.prepare(widget.controller);

    final textLink = await showDialog<QuillTextLink>(
      context: context,
      builder: (_) {
        return widget.useAlternativeDialog
            ? LinkStyleDialog(
                dialogTheme: widget.dialogTheme,
                text: initialTextLink.text,
                link: initialTextLink.link,
              )
            : _LinkDialog(
                dialogTheme: widget.dialogTheme,
                text: initialTextLink.text,
                link: initialTextLink.link,
              );
      },
    );

    if (textLink != null) {
      textLink.submit(widget.controller);
    }
  }

  String? _getLinkAttributeValue() {
    return widget.controller
        .getSelectionStyle()
        .attributes[Attribute.link.key]
        ?.value;
  }
}

class _LinkDialog extends StatefulWidget {
  const _LinkDialog({this.dialogTheme, this.link, this.text, Key? key})
      : super(key: key);

  final QuillDialogTheme? dialogTheme;
  final String? link;
  final String? text;

  @override
  _LinkDialogState createState() => _LinkDialogState();
}

class _LinkDialogState extends State<_LinkDialog> {
  late String _link;
  late String _text;
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
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: widget.dialogTheme?.dialogBackgroundColor,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          TextField(
            keyboardType: TextInputType.multiline,
            style: widget.dialogTheme?.inputTextStyle,
            decoration: InputDecoration(
                labelText: 'Text'.i18n,
                labelStyle: widget.dialogTheme?.labelTextStyle,
                floatingLabelStyle: widget.dialogTheme?.labelTextStyle),
            autofocus: true,
            onChanged: _textChanged,
            controller: _textController,
          ),
          const SizedBox(height: 16),
          TextField(
            keyboardType: TextInputType.multiline,
            style: widget.dialogTheme?.inputTextStyle,
            decoration: InputDecoration(
                labelText: 'Link'.i18n,
                labelStyle: widget.dialogTheme?.labelTextStyle,
                floatingLabelStyle: widget.dialogTheme?.labelTextStyle),
            autofocus: true,
            onChanged: _linkChanged,
            controller: _linkController,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _canPress() ? _applyLink : null,
          child: Text(
            'Ok'.i18n,
            style: widget.dialogTheme?.labelTextStyle,
          ),
        ),
      ],
    );
  }

  bool _canPress() {
    if (_text.isEmpty || _link.isEmpty) {
      return false;
    }

    if (!AutoFormatMultipleLinksRule.linkRegExp.hasMatch(_link)) {
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
    Navigator.pop(context, QuillTextLink(_text.trim(), _link.trim()));
  }
}

class LinkStyleDialog extends StatefulWidget {
  const LinkStyleDialog({
    Key? key,
    this.dialogTheme,
    this.link,
    this.text,
  }) : super(key: key);

  final QuillDialogTheme? dialogTheme;
  final String? link;
  final String? text;

  @override
  State<LinkStyleDialog> createState() => _LinkStyleDialogState();
}

class _LinkStyleDialogState extends State<LinkStyleDialog> {
  late final TextEditingController _linkController;
  late final TextEditingController _textController;

  late String _link;
  late String _text;

  late bool _isEditMode;

  @override
  void dispose() {
    _linkController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _link = widget.link ?? '';
    _text = widget.text ?? '';
    _linkController = TextEditingController(text: _link);
    _textController = TextEditingController(text: _text);
    _isEditMode = _link.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: widget.dialogTheme?.dialogBackgroundColor,
      shape: widget.dialogTheme?.shape ??
          DialogTheme.of(context).shape ??
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      child: ConstrainedBox(
        constraints: const BoxConstraints.tightFor(width: 200),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              if (_isEditMode) ...[
                Text('Visit link'.i18n),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    widget.link!,
                    style:
                        const TextStyle(decoration: TextDecoration.underline),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isEditMode = !_isEditMode;
                    });
                  },
                  child: Text('Edit'.i18n),
                ),
                const VerticalDivider(
                  width: 10,
                  indent: 2,
                  endIndent: 2,
                ),
                TextButton(
                  onPressed: _removeLink,
                  child: Text('Remove'.i18n),
                ),
              ] else ...[
                Text('Enter link'.i18n),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: TextField(
                    controller: _linkController,
                    keyboardType: TextInputType.url,
                    onChanged: _linkChanged,
                  ),
                ),
                TextButton(
                  onPressed: _canPress() ? _applyLink : null,
                  child: Text('Save'.i18n),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  bool _canPress() {
    if (_link.isEmpty) {
      return false;
    }

    if (!AutoFormatMultipleLinksRule.linkRegExp.hasMatch(_link)) {
      return false;
    }

    return true;
  }

  void _linkChanged(String value) {
    setState(() {
      _link = value;
    });
  }

  void _applyLink() {
    Navigator.pop(context, QuillTextLink(_text.trim(), _link.trim()));
  }

  void _removeLink() {
    Navigator.pop(context, QuillTextLink(_text.trim(), ''));
  }
}

class QuillTextLink {
  QuillTextLink(
    this.text,
    this.link,
  );

  final String text;
  final String link;

  static QuillTextLink prepare(QuillController controller) {
    final link =
        controller.getSelectionStyle().attributes[Attribute.link.key]?.value;
    final index = controller.selection.start;

    var text;
    if (link != null) {
      // text should be the link's corresponding text, not selection
      final leaf = controller.document.querySegmentLeafNode(index).leaf;
      if (leaf != null) {
        text = leaf.toPlainText();
      }
    }

    final len = controller.selection.end - index;
    text ??= len == 0 ? '' : controller.document.getPlainText(index, len);

    return QuillTextLink(text, link);
  }

  void submit(QuillController controller) {
    var index = controller.selection.start;
    var length = controller.selection.end - index;
    final link =
        controller.getSelectionStyle().attributes[Attribute.link.key]?.value;

    if (link != null) {
      // text should be the link's corresponding text, not selection
      final leaf = controller.document.querySegmentLeafNode(index).leaf;
      if (leaf != null) {
        final range = getLinkRange(leaf);
        index = range.start;
        length = range.end - range.start;
      }
    }
    controller
      ..replaceText(index, length, text, null)
      ..formatText(index, text.length, LinkAttribute(link));
  }
}
