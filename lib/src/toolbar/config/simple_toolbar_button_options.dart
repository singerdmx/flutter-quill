import 'package:meta/meta.dart';

import 'base_button_options.dart';
import 'buttons/clear_format_options.dart';
import 'buttons/clipboard_button_options.dart';
import 'buttons/color_options.dart';
import 'buttons/custom_button_options.dart';
import 'buttons/font_family_options.dart';
import 'buttons/font_size_options.dart';
import 'buttons/history_options.dart';
import 'buttons/indent_options.dart';
import 'buttons/link_style2_options.dart';
import 'buttons/link_style_options.dart';
import 'buttons/search_options.dart';
import 'buttons/select_alignment_options.dart';
import 'buttons/select_header_style_buttons_options.dart';
import 'buttons/select_header_style_dropdown_button_options.dart';
import 'buttons/select_line_height_style_dropdown_button_options.dart';
import 'buttons/toggle_check_list_options.dart';
import 'buttons/toggle_style_options.dart';

export '../buttons/search/search_dialog.dart';
export 'base_button_options.dart';
export 'buttons/clear_format_options.dart';
export 'buttons/clipboard_button_options.dart';
export 'buttons/color_options.dart';
export 'buttons/custom_button_options.dart';
export 'buttons/font_family_options.dart';
export 'buttons/font_size_options.dart';
export 'buttons/history_options.dart';
export 'buttons/indent_options.dart';
export 'buttons/link_style2_options.dart';
export 'buttons/link_style_options.dart';
export 'buttons/search_options.dart';
export 'buttons/select_alignment_options.dart';
export 'buttons/select_header_style_buttons_options.dart';
export 'buttons/select_header_style_dropdown_button_options.dart';
export 'buttons/toggle_check_list_options.dart';
export 'buttons/toggle_style_options.dart';

/// The configurations for the buttons of the toolbar widget of flutter quill
@immutable
class QuillSimpleToolbarButtonOptions {
  const QuillSimpleToolbarButtonOptions({
    this.base = const QuillToolbarBaseButtonOptions(),
    this.undoHistory = const QuillToolbarHistoryButtonOptions(),
    this.redoHistory = const QuillToolbarHistoryButtonOptions(),
    this.fontFamily = const QuillToolbarFontFamilyButtonOptions(),
    this.fontSize = const QuillToolbarFontSizeButtonOptions(),
    this.bold = const QuillToolbarToggleStyleButtonOptions(),
    this.subscript = const QuillToolbarToggleStyleButtonOptions(),
    this.superscript = const QuillToolbarToggleStyleButtonOptions(),
    this.italic = const QuillToolbarToggleStyleButtonOptions(),
    this.small = const QuillToolbarToggleStyleButtonOptions(),
    this.underLine = const QuillToolbarToggleStyleButtonOptions(),
    this.strikeThrough = const QuillToolbarToggleStyleButtonOptions(),
    this.inlineCode = const QuillToolbarToggleStyleButtonOptions(),
    this.direction = const QuillToolbarToggleStyleButtonOptions(),
    this.listNumbers = const QuillToolbarToggleStyleButtonOptions(),
    this.listBullets = const QuillToolbarToggleStyleButtonOptions(),
    this.codeBlock = const QuillToolbarToggleStyleButtonOptions(),
    this.quote = const QuillToolbarToggleStyleButtonOptions(),
    this.toggleCheckList = const QuillToolbarToggleCheckListButtonOptions(),
    this.indentIncrease = const QuillToolbarIndentButtonOptions(),
    this.indentDecrease = const QuillToolbarIndentButtonOptions(),
    this.color = const QuillToolbarColorButtonOptions(),
    this.backgroundColor = const QuillToolbarColorButtonOptions(),
    this.clearFormat = const QuillToolbarClearFormatButtonOptions(),
    this.selectAlignmentButtons =
        const QuillToolbarSelectAlignmentButtonOptions(),
    this.search = const QuillToolbarSearchButtonOptions(),
    this.selectHeaderStyleButtons =
        const QuillToolbarSelectHeaderStyleButtonsOptions(),
    this.selectHeaderStyleDropdownButton =
        const QuillToolbarSelectHeaderStyleDropdownButtonOptions(),
    this.selectLineHeightStyleDropdownButton =
        const QuillToolbarSelectLineHeightStyleDropdownButtonOptions(),
    this.linkStyle = const QuillToolbarLinkStyleButtonOptions(),
    this.linkStyle2 = const QuillToolbarLinkStyleButton2Options(),
    this.customButtons = const QuillToolbarCustomButtonOptions(),
    @experimental
    this.clipboardCut = const QuillToolbarClipboardButtonOptions(),
    @experimental
    this.clipboardCopy = const QuillToolbarClipboardButtonOptions(),
    @experimental
    this.clipboardPaste = const QuillToolbarClipboardButtonOptions(),
  });

  /// The base options that will apply to all buttons,
  /// will prefer the specific button options if set over the base.
  final QuillToolbarBaseButtonOptions base;

  final QuillToolbarHistoryButtonOptions undoHistory;
  final QuillToolbarHistoryButtonOptions redoHistory;
  final QuillToolbarFontFamilyButtonOptions fontFamily;
  final QuillToolbarFontSizeButtonOptions fontSize;
  final QuillToolbarToggleStyleButtonOptions bold;
  final QuillToolbarToggleStyleButtonOptions subscript;
  final QuillToolbarToggleStyleButtonOptions superscript;
  final QuillToolbarToggleStyleButtonOptions italic;
  final QuillToolbarToggleStyleButtonOptions small;
  final QuillToolbarToggleStyleButtonOptions underLine;
  final QuillToolbarToggleStyleButtonOptions strikeThrough;
  final QuillToolbarToggleStyleButtonOptions inlineCode;
  final QuillToolbarToggleStyleButtonOptions direction;
  final QuillToolbarToggleStyleButtonOptions listNumbers;
  final QuillToolbarToggleStyleButtonOptions listBullets;
  final QuillToolbarToggleStyleButtonOptions codeBlock;
  final QuillToolbarToggleStyleButtonOptions quote;
  final QuillToolbarToggleCheckListButtonOptions toggleCheckList;
  final QuillToolbarIndentButtonOptions indentIncrease;
  final QuillToolbarIndentButtonOptions indentDecrease;
  final QuillToolbarColorButtonOptions color;
  final QuillToolbarColorButtonOptions backgroundColor;
  final QuillToolbarClearFormatButtonOptions clearFormat;

  final QuillToolbarSelectAlignmentButtonOptions selectAlignmentButtons;

  final QuillToolbarSearchButtonOptions search;

  @experimental
  final QuillToolbarClipboardButtonOptions clipboardCut;
  @experimental
  final QuillToolbarClipboardButtonOptions clipboardCopy;
  @experimental
  final QuillToolbarClipboardButtonOptions clipboardPaste;

  final QuillToolbarSelectHeaderStyleButtonsOptions selectHeaderStyleButtons;

  final QuillToolbarSelectHeaderStyleDropdownButtonOptions
      selectHeaderStyleDropdownButton;

  final QuillToolbarSelectLineHeightStyleDropdownButtonOptions
      selectLineHeightStyleDropdownButton;

  final QuillToolbarLinkStyleButtonOptions linkStyle;
  final QuillToolbarLinkStyleButton2Options linkStyle2;

  final QuillToolbarCustomButtonOptions customButtons;
}
