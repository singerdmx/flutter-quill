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
  bool _caseSensitive = false;
  bool _wholeWord = false;

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
    var matchShown = '';
    if (_offsets != null) {
      if (_offsets!.isEmpty) {
        matchShown = '0/0';
      } else {
        matchShown = '${_index + 1}/${_offsets!.length}';
      }
    }

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
      ),
      backgroundColor: widget.dialogTheme?.dialogBackgroundColor,
      alignment: Alignment.bottomCenter,
      insetPadding: EdgeInsets.zero,
      child: SizedBox(
        height: 45,
        child: Row(
          children: [
            Tooltip(
              message: 'Case sensitivity and whole word search'.i18n,
              child: ToggleButtons(
                onPressed: (index) {
                  if (index == 0) {
                    _changeCaseSensitivity();
                  } else if (index == 1) {
                    _changeWholeWord();
                  }
                },
                borderRadius: const BorderRadius.all(Radius.circular(2)),
                isSelected: [_caseSensitive, _wholeWord],
                children: const [
                  Text(
                    '\u0391\u03b1',
                    style: TextStyle(
                      fontFamily: 'MaterialIcons',
                      fontSize: 24,
                    ),
                  ),
                  Text(
                    '\u201c\u2026\u201d',
                    style: TextStyle(
                      fontFamily: 'MaterialIcons',
                      fontSize: 24,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12, left: 5),
                child: TextField(
                  style: widget.dialogTheme?.inputTextStyle,
                  decoration: InputDecoration(
                    isDense: true,
                    suffixText: (_offsets != null) ? matchShown : '',
                    suffixStyle: widget.dialogTheme?.labelTextStyle,
                  ),
                  autofocus: true,
                  onChanged: _textChanged,
                  textInputAction: TextInputAction.done,
                  onEditingComplete: _findText,
                  controller: _controller,
                ),
              ),
            ),
            if (_offsets == null)
              IconButton(
                icon: const Icon(Icons.search),
                tooltip: 'Find text'.i18n,
                onPressed: _findText,
              ),
            if (_offsets != null)
              IconButton(
                icon: const Icon(Icons.keyboard_arrow_up),
                tooltip: 'Move to previous occurrence'.i18n,
                onPressed: (_offsets!.isNotEmpty) ? _moveToPrevious : null,
              ),
            if (_offsets != null)
              IconButton(
                icon: const Icon(Icons.keyboard_arrow_down),
                tooltip: 'Move to next occurrence'.i18n,
                onPressed: (_offsets!.isNotEmpty) ? _moveToNext : null,
              ),
          ],
        ),
      ),
    );
  }

  void _findText() {
    if (_text.isEmpty) {
      return;
    }
    setState(() {
      _offsets = widget.controller.document.search(
        _text,
        caseSensitive: _caseSensitive,
        wholeWord: _wholeWord,
      );
      _index = 0;
    });
    if (_offsets!.isNotEmpty) {
      _moveToPosition();
    }
  }

  void _moveToPosition() {
    widget.controller.updateSelection(
        TextSelection(
            baseOffset: _offsets![_index],
            extentOffset: _offsets![_index] + _text.length),
        ChangeSource.LOCAL);
  }

  void _moveToPrevious() {
    if (_offsets!.isEmpty) {
      return;
    }
    setState(() {
      if (_index > 0) {
        _index -= 1;
      } else {
        _index = _offsets!.length - 1;
      }
    });
    _moveToPosition();
  }

  void _moveToNext() {
    if (_offsets!.isEmpty) {
      return;
    }
    setState(() {
      if (_index < _offsets!.length - 1) {
        _index += 1;
      } else {
        _index = 0;
      }
    });
    _moveToPosition();
  }

  void _textChanged(String value) {
    setState(() {
      _text = value;
      _offsets = null;
      _index = 0;
    });
  }

  void _changeCaseSensitivity() {
    setState(() {
      _caseSensitive = !_caseSensitive;
      _offsets = null;
      _index = 0;
    });
  }

  void _changeWholeWord() {
    setState(() {
      _wholeWord = !_wholeWord;
      _offsets = null;
      _index = 0;
    });
  }
}
