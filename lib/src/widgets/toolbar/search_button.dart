import 'package:flutter/material.dart';

import '../../models/themes/quill_dialog_theme.dart';
import '../../models/themes/quill_icon_theme.dart';
import '../../translations/toolbar.i18n.dart';
import '../controller.dart';
import '../toolbar.dart';

class SearchButton extends StatelessWidget {
  const SearchButton({
    required this.icon,
    required this.controller,
    this.iconSize = kDefaultIconSize,
    this.fillColor,
    this.iconTheme,
    this.dialogTheme,
    Key? key,
  }) : super(key: key);

  final IconData icon;
  final double iconSize;

  final QuillController controller;
  final Color? fillColor;
  final QuillIconTheme? iconTheme;

  final QuillDialogTheme? dialogTheme;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final iconColor = iconTheme?.iconUnselectedColor ?? theme.iconTheme.color;
    final iconFillColor =
        iconTheme?.iconUnselectedFillColor ?? (fillColor ?? theme.canvasColor);

    return QuillIconButton(
      icon: Icon(icon, size: iconSize, color: iconColor),
      highlightElevation: 0,
      hoverElevation: 0,
      size: iconSize * 1.77,
      fillColor: iconFillColor,
      borderRadius: iconTheme?.borderRadius ?? 2,
      onPressed: () => _onPressedHandler(context),
    );
  }

  Future<void> _onPressedHandler(BuildContext context) async {
    await showDialog<String>(
      context: context,
      builder: (_) => _SearchDialog(
          controller: controller, dialogTheme: dialogTheme, text: ''),
    ).then(_searchSubmitted);
  }

  void _searchSubmitted(String? value) {}
}

class _SearchDialog extends StatefulWidget {
  const _SearchDialog(
      {required this.controller, this.dialogTheme, this.text, Key? key})
      : super(key: key);

  final QuillController controller;
  final QuillDialogTheme? dialogTheme;
  final String? text;

  @override
  _SearchDialogState createState() => _SearchDialogState();
}

class _SearchDialogState extends State<_SearchDialog> {
  late String _text;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _text = widget.text ?? '';
    _controller = TextEditingController(text: _text);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: widget.dialogTheme?.dialogBackgroundColor,
      content: TextField(
        keyboardType: TextInputType.multiline,
        maxLines: null,
        style: widget.dialogTheme?.inputTextStyle,
        decoration: InputDecoration(
            labelText: 'Search'.i18n,
            labelStyle: widget.dialogTheme?.labelTextStyle,
            floatingLabelStyle: widget.dialogTheme?.labelTextStyle),
        autofocus: true,
        onChanged: _textChanged,
        controller: _controller,
      ),
      actions: [
        TextButton(
          onPressed: () {
            final offsets = widget.controller.document.search(_text);
            debugPrint(offsets.toString());
          },
          child: Text(
            'Ok'.i18n,
            style: widget.dialogTheme?.labelTextStyle,
          ),
        ),
      ],
    );
  }

  void _textChanged(String value) {
    setState(() {
      _text = value;
    });
  }
}
