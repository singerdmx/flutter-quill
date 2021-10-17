import 'package:flutter/material.dart';

import '../models/themes/quill_dialog_theme.dart';
import '../translations/toolbar.i18n.dart';

class LinkDialog extends StatefulWidget {
  const LinkDialog({this.dialogTheme, Key? key}) : super(key: key);

  final QuillDialogTheme? dialogTheme;

  @override
  LinkDialogState createState() => LinkDialogState();
}

class LinkDialogState extends State<LinkDialog> {
  String _link = '';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: widget.dialogTheme?.dialogBackgroundColor,
      content: TextField(
        style: widget.dialogTheme?.inputTextStyle,
        decoration: InputDecoration(
            labelText: 'Paste a link'.i18n,
            labelStyle: widget.dialogTheme?.labelTextStyle,
            floatingLabelStyle: widget.dialogTheme?.labelTextStyle),
        autofocus: true,
        onChanged: _linkChanged,
      ),
      actions: [
        TextButton(
          onPressed: _link.isNotEmpty ? _applyLink : null,
          child: Text(
            'Ok'.i18n,
            style: widget.dialogTheme?.labelTextStyle,
          ),
        ),
      ],
    );
  }

  void _linkChanged(String value) {
    setState(() {
      _link = value;
    });
  }

  void _applyLink() {
    Navigator.pop(context, _link);
  }
}
