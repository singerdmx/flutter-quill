import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

import '../buttons/hearder_style/select_header_style_buttons.dart';
import '../buttons/hearder_style/select_header_style_dropdown_button.dart';
import '../buttons/link_style/link_style2_button.dart';
import '../buttons/link_style/link_style_button.dart';
import '../embed/embed_button_builder.dart';
import '../structs/link_dialog_action.dart';
import '../theme/quill_dialog_theme.dart';
import '../theme/quill_icon_theme.dart';
import 'simple_toolbar_button_options.dart';

export '../buttons/search/search_dialog.dart';
export 'base_button_options.dart';
export 'buttons/clear_format_options.dart';
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
export 'buttons/select_line_height_style_dropdown_button_options.dart';
export 'buttons/toggle_check_list_options.dart';
export 'buttons/toggle_style_options.dart';
export 'simple_toolbar_button_options.dart';

/// The default size of the icon of a button.
const double kDefaultIconSize = 15;

/// The default size for the toolbar (width, height)
const double kDefaultToolbarSize = kDefaultIconSize * 2;

/// The factor of how much larger the button is in relation to the icon.
const double kDefaultIconButtonFactor = 1.6;

/// The horizontal margin between the contents of each toolbar section.
const double kToolbarSectionSpacing = 4;

enum LinkStyleType {
  /// Defines the original [QuillToolbarLinkStyleButton].
  original,

  /// Defines the alternative [QuillToolbarLinkStyleButton2].
  alternative;

  bool get isOriginal => this == LinkStyleType.original;
  bool get isAlternative => this == LinkStyleType.alternative;
}

enum HeaderStyleType {
  /// Defines the original [QuillToolbarSelectHeaderStyleDropdownButton].
  original,

  /// Defines the alternative [QuillToolbarSelectHeaderStyleButtons].
  buttons;

  bool get isOriginal => this == HeaderStyleType.original;
  bool get isButtons => this == HeaderStyleType.buttons;
}

/// The configurations for the toolbar widget of flutter quill
@immutable
class QuillSimpleToolbarConfig {
  const QuillSimpleToolbarConfig({
    this.toolbarSectionSpacing = kToolbarSectionSpacing,
    this.toolbarIconAlignment = WrapAlignment.center,
    this.toolbarIconCrossAlignment = WrapCrossAlignment.center,
    this.buttonOptions = const QuillSimpleToolbarButtonOptions(),
    this.customButtons = const [],
    this.multiRowsDisplay = true,
    this.showDividers = true,
    this.showFontFamily = true,
    this.showFontSize = true,
    this.showBoldButton = true,
    this.showItalicButton = true,
    this.showSmallButton = false,
    this.showUnderLineButton = true,
    this.showLineHeightButton = false,
    this.showStrikeThrough = true,
    this.showInlineCode = true,
    this.showColorButton = true,
    this.showBackgroundColorButton = true,
    this.showClearFormat = true,
    this.showAlignmentButtons = false,
    this.showLeftAlignment = true,
    this.showCenterAlignment = true,
    this.showRightAlignment = true,
    this.showJustifyAlignment = true,
    this.showHeaderStyle = true,
    this.showListNumbers = true,
    this.showListBullets = true,
    this.showListCheck = true,
    this.showCodeBlock = true,
    this.showQuote = true,
    this.showIndent = true,
    this.showLink = true,
    this.showUndo = true,
    this.showRedo = true,
    this.showDirection = false,
    this.showSearchButton = true,
    this.showSubscript = true,
    this.showSuperscript = true,
    @experimental this.showClipboardCut = false,
    @experimental this.showClipboardCopy = false,
    @experimental this.showClipboardPaste = false,
    this.linkStyleType = LinkStyleType.original,
    this.headerStyleType = HeaderStyleType.original,

    /// The decoration to use for the toolbar.
    this.decoration,

    /// Toolbar items to display for controls of embed blocks
    this.embedButtons,
    this.linkDialogAction,

    ///The theme to use for the icons in the toolbar, uses type [QuillIconTheme]
    // this.iconTheme,
    this.dialogTheme,
    this.iconTheme,
    this.axis = Axis.horizontal,
    this.color,
    this.sectionDividerColor,
    this.sectionDividerSpace,

    /// The change only applies if [multiRowsDisplay] is `false`
    double? toolbarSize,
    this.toolbarRunSpacing = 4,
  }) : _toolbarSize = toolbarSize;

  final double? _toolbarSize;

  double get toolbarSize {
    final alternativeToolbarSize = _toolbarSize;
    if (alternativeToolbarSize != null) {
      return alternativeToolbarSize;
    }
    return kDefaultIconSize * 2;
  }

  /// List of custom buttons
  final List<QuillToolbarCustomButtonOptions> customButtons;

  final bool showDividers;
  final bool showFontFamily;
  final bool showFontSize;
  final bool showBoldButton;
  final bool showItalicButton;
  final bool showSmallButton;
  final bool showUnderLineButton;
  final bool showStrikeThrough;
  final bool showInlineCode;
  final bool showColorButton;
  final bool showBackgroundColorButton;
  final bool showClearFormat;

  final bool showAlignmentButtons;
  final bool showLeftAlignment;
  final bool showCenterAlignment;
  final bool showRightAlignment;
  final bool showJustifyAlignment;
  final bool showHeaderStyle;
  final bool showListNumbers;
  final bool showListBullets;
  final bool showListCheck;
  final bool showCodeBlock;
  final bool showQuote;
  final bool showIndent;
  final bool showLink;
  final bool showUndo;
  final bool showRedo;
  final bool showDirection;
  final bool showSearchButton;
  final bool showSubscript;
  final bool showSuperscript;
  @experimental
  final bool showClipboardCut;
  @experimental
  final bool showClipboardCopy;
  @experimental
  final bool showClipboardPaste;

  /// This activates a functionality that is only implemented in [flutter_quill] and is NOT originally
  /// used in the [Quill Js API]. So it could cause conflicts if you use this attribute with the original Delta format of Quill Js
  final bool showLineHeightButton;

  /// Toolbar items to display for controls of embed blocks
  final List<EmbedButtonBuilder>? embedButtons;

  @experimental
  final QuillIconTheme? iconTheme;

  @experimental
  final QuillDialogTheme? dialogTheme;

  /// Defines which dialog is used for applying link attribute.
  final LinkStyleType linkStyleType;

  /// Defines which dialog is used for applying header attribute.
  final HeaderStyleType headerStyleType;

  final Axis axis;

  final WrapAlignment toolbarIconAlignment;
  final WrapCrossAlignment toolbarIconCrossAlignment;
  final double toolbarRunSpacing;

  /// Only works if [multiRowsDisplay] is `true`
  final double toolbarSectionSpacing;

  // Overrides the action in the _LinkDialog widget
  final LinkDialogAction? linkDialogAction;

  /// The color of the toolbar.
  ///
  /// Defaults to [ThemeData.canvasColor] of the current [Theme] if no color
  /// is given.
  final Color? color;

  /// The color to use when painting the toolbar section divider.
  ///
  /// If this is null, then the [DividerThemeData.color] is used. If that is
  /// also null, then [ThemeData.dividerColor] is used.
  final Color? sectionDividerColor;

  /// The space occupied by toolbar section divider.
  final double? sectionDividerSpace;

  /// If you want the toolbar to not be a multiple rows pass false
  final bool multiRowsDisplay;

  /// The decoration to use for the toolbar.
  final Decoration? decoration;

  /// If you want change spesefic buttons or all of them
  /// then you came to the right place
  final QuillSimpleToolbarButtonOptions buttonOptions;
}
