import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';

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
    Key? key,
  }) : super(key: key);

  final QuillController controller;
  final IconData? icon;
  final double iconSize;
  final QuillIconTheme? iconTheme;
  final QuillDialogTheme? dialogTheme;
  final VoidCallback? afterButtonPressed;

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

  void _openLinkDialog(BuildContext context) {
    showDialog<dynamic>(
      context: context,
      builder: (ctx) {
        final link = _getLinkAttributeValue();
        final index = widget.controller.selection.start;

        var text;
        if (link != null) {
          // text should be the link's corresponding text, not selection
          final leaf =
              widget.controller.document.querySegmentLeafNode(index).item2;
          if (leaf != null) {
            text = leaf.toPlainText();
          }
        }

        final len = widget.controller.selection.end - index;
        text ??=
            len == 0 ? '' : widget.controller.document.getPlainText(index, len);
        return _LinkDialog(
            dialogTheme: widget.dialogTheme, link: link, text: text);
      },
    ).then(
      (value) {
        if (value != null) _linkSubmitted(value);
      },
    );
  }

  String? _getLinkAttributeValue() {
    return widget.controller
        .getSelectionStyle()
        .attributes[Attribute.link.key]
        ?.value;
  }

  void _linkSubmitted(dynamic value) {
    // text.isNotEmpty && link.isNotEmpty
    final String text = (value as Tuple2).item1;
    final String link = value.item2.trim();

    var index = widget.controller.selection.start;
    var length = widget.controller.selection.end - index;
    if (_getLinkAttributeValue() != null) {
      // text should be the link's corresponding text, not selection
      final leaf = widget.controller.document.querySegmentLeafNode(index).item2;
      if (leaf != null) {
        final range = getLinkRange(leaf);
        index = range.start;
        length = range.end - range.start;
      }
    }
    widget.controller.replaceText(index, length, text, null);
    widget.controller.formatText(index, text.length, LinkAttribute(link));
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
    Navigator.pop(context, Tuple2(_text.trim(), _link.trim()));
  }
}
