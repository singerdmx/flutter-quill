import 'dart:async';

import 'package:flutter/material.dart';

import '../../../common/utils/platform.dart';
import '../../../controller/quill_controller.dart';
import '../../../document/document.dart';
import '../../../document/nodes/leaf.dart';
import '../../../l10n/extensions/localizations_ext.dart';
import '../../simple_toolbar.dart';
import '../../theme/quill_dialog_theme.dart';
import '../../theme/quill_icon_theme.dart';

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
    this.searchBarAlignment,
    this.size,
    this.iconTheme,
    super.key,
  });

  final QuillController controller;
  final QuillDialogTheme? dialogTheme;
  final String? text;
  final QuillToolbarSearchDialogChildBuilder? childBuilder;
  final AlignmentGeometry? searchBarAlignment;
  final double? size;
  final QuillIconTheme? iconTheme;

  @override
  QuillToolbarSearchDialogState createState() =>
      QuillToolbarSearchDialogState();
}

class QuillToolbarSearchDialogState extends State<QuillToolbarSearchDialog> {
  final TextEditingController _textController = TextEditingController();
  late String _text;
  List<int> _offsets = [];
  int _index = 0;
  bool _caseSensitive = false;
  bool _wholeWord = false;
  bool _searchSettingsUnfolded = false;
  Timer? _searchTimer;

  @override
  void initState() {
    super.initState();
    _text = widget.text ?? '';
  }

  @override
  void dispose() {
    _textController.dispose();
    _searchTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final childBuilder = widget.childBuilder;
    if (childBuilder != null) {
      return childBuilder(
        QuillToolbarSearchDialogChildBuilderExtraOptions(
          onFindTextPressed: _findText,
          onEditingComplete: _findText,
          onTextChanged: _textChanged,
          caseSensitive: _caseSensitive,
          textEditingController: _textController,
          index: _index,
          offsets: _offsets,
          text: _text,
          wholeWord: _wholeWord,
          moveToNext: _moveToNext,
          moveToPrevious: _moveToPosition,
        ),
      );
    }

    final searchBarAlignment =
        widget.searchBarAlignment ?? Alignment.bottomCenter;
    final searchBarAtBottom = (searchBarAlignment == Alignment.bottomCenter) ||
        (searchBarAlignment == Alignment.bottomLeft) ||
        (searchBarAlignment == Alignment.bottomRight);
    final addBottomPadding = searchBarAtBottom && isMobile;
    String? matchShown;
    if (_text.isNotEmpty) {
      if (_offsets.isEmpty) {
        matchShown = '0/0';
      } else {
        matchShown = '${_index + 1}/${_offsets.length}';
      }
    }

    const buttonBox = BoxConstraints.tightFor(width: 40, height: 40);
    const buttonStyle = ButtonStyle(
      shape: WidgetStatePropertyAll<OutlinedBorder?>(CircleBorder()),
    );
    final iconTheme = widget.iconTheme?.copyWith(
          iconButtonUnselectedData: const IconButtonData(
            visualDensity: VisualDensity.compact,
            constraints: buttonBox,
            style: buttonStyle,
          ),
          iconButtonSelectedData: const IconButtonData(
            visualDensity: VisualDensity.compact,
            constraints: buttonBox,
            style: buttonStyle,
          ),
        ) ??
        const QuillIconTheme(
          iconButtonUnselectedData: IconButtonData(
            visualDensity: VisualDensity.compact,
            constraints: buttonBox,
            style: buttonStyle,
          ),
          iconButtonSelectedData: IconButtonData(
            visualDensity: VisualDensity.compact,
            constraints: buttonBox,
            style: buttonStyle,
          ),
        );

    final searchBar = Container(
      height: addBottomPadding ? 52 : 40,
      padding: addBottomPadding ? const EdgeInsets.only(bottom: 12) : null,
      child: Row(
        children: [
          QuillToolbarIconButton(
            tooltip: context.loc.close,
            icon: Icon(
              Icons.close,
              size: widget.size,
            ),
            isSelected: false,
            onPressed: () {
              Navigator.of(context).pop();
            },
            iconTheme: iconTheme,
          ),
          QuillToolbarIconButton(
            tooltip: context.loc.searchSettings,
            icon: Icon(
              Icons.more_vert,
              size: widget.size,
            ),
            isSelected: _caseSensitive || _wholeWord,
            onPressed: () {
              setState(() {
                _searchSettingsUnfolded = !_searchSettingsUnfolded;
              });
            },
            iconTheme: iconTheme,
          ),
          Expanded(
            child: TextField(
              style: widget.dialogTheme?.inputTextStyle,
              decoration: InputDecoration(
                isDense: true,
                suffixText: matchShown,
                suffixStyle: widget.dialogTheme?.labelTextStyle,
                contentPadding: const EdgeInsets.symmetric(horizontal: 4),
              ),
              autofocus: true,
              onChanged: _textChanged,
              textInputAction: TextInputAction.done,
              keyboardType: TextInputType.text,
              controller: _textController,
            ),
          ),
          QuillToolbarIconButton(
            tooltip: context.loc.moveToPreviousOccurrence,
            icon: Icon(
              Icons.keyboard_arrow_up,
              size: widget.size,
            ),
            isSelected: false,
            onPressed: (_offsets.isNotEmpty) ? _moveToPrevious : null,
            iconTheme: iconTheme,
          ),
          QuillToolbarIconButton(
            tooltip: context.loc.moveToNextOccurrence,
            icon: Icon(
              Icons.keyboard_arrow_down,
              size: widget.size,
            ),
            isSelected: false,
            onPressed: (_offsets.isNotEmpty) ? _moveToNext : null,
            iconTheme: iconTheme,
          ),
        ],
      ),
    );

    final searchSettings = SizedBox(
      height: 40,
      child: Row(
        children: [
          Expanded(
            child: CheckboxListTile(
              controlAffinity: ListTileControlAffinity.leading,
              visualDensity: VisualDensity.compact,
              contentPadding: EdgeInsets.zero,
              title: Text(
                context.loc.caseSensitive,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              value: _caseSensitive,
              onChanged: (value) {
                setState(() {
                  _caseSensitive = value!;
                  _findText();
                });
              },
            ),
          ),
          Expanded(
            child: CheckboxListTile(
              controlAffinity: ListTileControlAffinity.leading,
              visualDensity: VisualDensity.compact,
              contentPadding: EdgeInsets.zero,
              title: Text(
                context.loc.wholeWord,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              value: _wholeWord,
              onChanged: (value) {
                setState(() {
                  _wholeWord = value!;
                  _findText();
                });
              },
            ),
          ),
        ],
      ),
    );

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
      ),
      backgroundColor: widget.dialogTheme?.dialogBackgroundColor,
      alignment: searchBarAlignment,
      insetPadding: EdgeInsets.zero,
      child: Builder(
        builder: (context) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_searchSettingsUnfolded && searchBarAtBottom) searchSettings,
              searchBar,
              if (_searchSettingsUnfolded && !searchBarAtBottom) searchSettings,
            ],
          );
        },
      ),
    );
  }

  void _textChanged(String text) {
    _text = text;
    if (_searchTimer?.isActive ?? false) {
      _searchTimer?.cancel();
    }
    _searchTimer = Timer(
      const Duration(milliseconds: 300),
      _findText,
    );
  }

  void _findText() {
    void clearSelection() {
      widget.controller.updateSelection(
        TextSelection(
          baseOffset: widget.controller.selection.baseOffset,
          extentOffset: widget.controller.selection.baseOffset,
        ),
        ChangeSource.local,
      );
    }

    if (_text.isEmpty) {
      setState(() {
        _offsets = [];
        _index = 0;
        clearSelection();
      });
      return;
    }
    setState(() {
      final currPos = _offsets.isNotEmpty ? _offsets[_index] : 0;
      _offsets = widget.controller.document.search(
        _text,
        caseSensitive: _caseSensitive,
        wholeWord: _wholeWord,
      );
      _index = 0;
      if (_offsets.isEmpty) {
        clearSelection();
      } else {
        //  Select the next hit position
        for (var n = 0; n < _offsets.length; n++) {
          if (_offsets[n] >= currPos) {
            _index = n;
            break;
          }
        }
        _moveToPosition();
      }
    });
  }

  void _moveToPosition() {
    final offset = _offsets[_index];
    var len = _text.length;

    /// Trap search hit within embed must only show selection of the embed
    final leaf = widget.controller.queryNode(offset);
    if (leaf is Embed) {
      len = 1;
    }
    widget.controller.updateSelection(
      TextSelection(
        baseOffset: offset,
        extentOffset: offset + len,
      ),
      ChangeSource.local,
    );
  }

  void _moveToPrevious() {
    if (_offsets.isEmpty) {
      return;
    }
    setState(() {
      if (_index > 0) {
        _index -= 1;
      } else {
        _index = _offsets.length - 1;
      }
    });
    _moveToPosition();
  }

  void _moveToNext() {
    if (_offsets.isEmpty) {
      return;
    }
    setState(() {
      if (_index < _offsets.length - 1) {
        _index += 1;
      } else {
        _index = 0;
      }
    });
    _moveToPosition();
  }
}
