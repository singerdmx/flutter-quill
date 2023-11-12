import 'package:flutter/material.dart';

import '../../../../l10n/extensions/localizations.dart';
import '../../../../models/documents/document.dart';
import '../../../../models/themes/quill_dialog_theme.dart';
import '../../../controller.dart';

@immutable
class QuillToolbarSearchDialogChildBuilderExtraOptions {
  const QuillToolbarSearchDialogChildBuilderExtraOptions({
    required this.onFindTextPressed,
    required this.moveToNext,
    required this.moveToPrevious,
    required this.onTextChanged,
    required this.onEditingComplete,
    required this.text,
    required this.textEditingController,
    required this.offsets,
    required this.index,
    required this.caseSensitive,
    required this.wholeWord,
  });
  final VoidCallback? onFindTextPressed;
  final VoidCallback moveToNext;
  final VoidCallback moveToPrevious;
  final ValueChanged<String>? onTextChanged;
  final VoidCallback? onEditingComplete;
  final String text;
  final TextEditingController textEditingController;
  final List<int>? offsets;
  final int index;
  final bool caseSensitive;
  final bool wholeWord;
}

typedef QuillToolbarSearchDialogChildBuilder = Widget Function(
  QuillToolbarSearchDialogChildBuilderExtraOptions extraOptions,
);

class QuillToolbarSearchDialog extends StatefulWidget {
  const QuillToolbarSearchDialog({
    required this.controller,
    this.dialogTheme,
    this.text,
    this.childBuilder,
    super.key,
  });

  final QuillController controller;
  final QuillDialogTheme? dialogTheme;
  final String? text;
  final QuillToolbarSearchDialogChildBuilder? childBuilder;

  @override
  QuillToolbarSearchDialogState createState() =>
      QuillToolbarSearchDialogState();
}

class QuillToolbarSearchDialogState extends State<QuillToolbarSearchDialog> {
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
  void dispose() {
    _controller.dispose();
    super.dispose();
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

    final childBuilder = widget.childBuilder;
    if (childBuilder != null) {
      return childBuilder(
        QuillToolbarSearchDialogChildBuilderExtraOptions(
          onFindTextPressed: _findText,
          onEditingComplete: _findText,
          onTextChanged: _textChanged,
          caseSensitive: _caseSensitive,
          textEditingController: _controller,
          index: _index,
          offsets: _offsets,
          text: _text,
          wholeWord: _wholeWord,
          moveToNext: _moveToNext,
          moveToPrevious: _moveToPosition,
        ),
      );
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
              message: context.loc.caseSensitivityAndWholeWordSearch,
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
                  keyboardType: TextInputType.text,
                  onEditingComplete: _findText,
                  controller: _controller,
                ),
              ),
            ),
            if (_offsets == null)
              IconButton(
                icon: const Icon(Icons.search),
                tooltip: context.loc.findText,
                onPressed: _findText,
              ),
            if (_offsets != null)
              IconButton(
                icon: const Icon(Icons.keyboard_arrow_up),
                tooltip: context.loc.moveToPreviousOccurrence,
                onPressed: (_offsets!.isNotEmpty) ? _moveToPrevious : null,
              ),
            if (_offsets != null)
              IconButton(
                icon: const Icon(Icons.keyboard_arrow_down),
                tooltip: context.loc.moveToNextOccurrence,
                onPressed: (_offsets!.isNotEmpty) ? _moveToNext : null,
              ),
          ],
        ),
      ),
    );
  }

  void _findText() {
    _text = _controller.text;
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
        extentOffset: _offsets![_index] + _text.length,
      ),
      ChangeSource.local,
    );
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
