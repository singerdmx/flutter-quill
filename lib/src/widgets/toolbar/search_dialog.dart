import 'package:flutter/material.dart';

import '../../../translations.dart';
import '../../models/documents/document.dart';
import '../../models/themes/quill_dialog_theme.dart';
import '../controller.dart';

class SearchDialog extends StatefulWidget {
  const SearchDialog(
      {required this.controller, this.dialogTheme, this.text, Key? key})
      : super(key: key);

  final QuillController controller;
  final QuillDialogTheme? dialogTheme;
  final String? text;

  @override
  _SearchDialogState createState() => _SearchDialogState();
}

class _SearchDialogState extends State<SearchDialog> {
  late String _text;
  late TextEditingController _controller;
  late List<int>? _offsets;
  late int _index;

  @override
  void initState() {
    super.initState();
    _text = widget.text ?? '';
    _offsets = null;
    _index = 0;
    _controller = TextEditingController(text: _text);
  }

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(builder: (context, setState) {
      var label = '';
      if (_offsets != null) {
        label = '${_offsets!.length} ${'matches'.i18n}';
        if (_offsets!.isNotEmpty) {
          label += ', ${'showing match'.i18n} ${_index + 1}';
        }
      }
      return AlertDialog(
        backgroundColor: widget.dialogTheme?.dialogBackgroundColor,
        content: Container(
          height: 100,
          child: Column(
            children: [
              TextField(
                keyboardType: TextInputType.multiline,
                style: widget.dialogTheme?.inputTextStyle,
                decoration: InputDecoration(
                    labelText: 'Search'.i18n,
                    labelStyle: widget.dialogTheme?.labelTextStyle,
                    floatingLabelStyle: widget.dialogTheme?.labelTextStyle),
                autofocus: true,
                onChanged: _textChanged,
                controller: _controller,
              ),
              if (_offsets != null)
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(label, textAlign: TextAlign.left),
                ),
            ],
          ),
        ),
        actions: [
          if (_offsets != null && _offsets!.isNotEmpty && _index > 0)
            TextButton(
              onPressed: () {
                setState(() {
                  _index -= 1;
                });
                _moveToPosition();
              },
              child: Text(
                'Prev'.i18n,
                style: widget.dialogTheme?.labelTextStyle,
              ),
            ),
          if (_offsets != null &&
              _offsets!.isNotEmpty &&
              _index < _offsets!.length - 1)
            TextButton(
              onPressed: () {
                setState(() {
                  _index += 1;
                });
                _moveToPosition();
              },
              child: Text(
                'Next'.i18n,
                style: widget.dialogTheme?.labelTextStyle,
              ),
            ),
          if (_offsets == null && _text.isNotEmpty)
            TextButton(
              onPressed: () {
                setState(() {
                  _offsets = widget.controller.document.search(_text);
                  _index = 0;
                });
                if (_offsets!.isNotEmpty) {
                  _moveToPosition();
                }
              },
              child: Text(
                'Ok'.i18n,
                style: widget.dialogTheme?.labelTextStyle,
              ),
            ),
        ],
      );
    });
  }

  void _moveToPosition() {
    widget.controller.updateSelection(
        TextSelection(
            baseOffset: _offsets![_index],
            extentOffset: _offsets![_index] + _text.length),
        ChangeSource.LOCAL);
  }

  void _textChanged(String value) {
    setState(() {
      _text = value;
      _offsets = null;
      _index = 0;
    });
  }
}
