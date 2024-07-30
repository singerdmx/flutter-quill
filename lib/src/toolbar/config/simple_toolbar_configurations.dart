import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter/widgets.dart'
    show Axis, WrapAlignment, WrapCrossAlignment;

import '../../controller/quill_controller.dart';
import '../buttons/hearder_style/select_header_style_buttons.dart';
import '../buttons/hearder_style/select_header_style_dropdown_button.dart';
import '../buttons/link_style2_button.dart';
import '../buttons/link_style_button.dart';
import '../buttons/search/legacy/legacy_search_button.dart';
import '../buttons/search/search_button.dart';
import '../embed/embed_button_builder.dart';
import '../theme/quill_dialog_theme.dart';
import '../theme/quill_icon_theme.dart';
import 'simple_toolbar_button_options.dart';
import 'toolbar_shared_configurations.dart';

export '../buttons/search/search_dialog.dart';
export 'base_button_configurations.dart';
export 'buttons/clear_format_configurations.dart';
export 'buttons/color_configurations.dart';
export 'buttons/custom_button_configurations.dart';
export 'buttons/font_family_configurations.dart';
export 'buttons/font_size_configurations.dart';
export 'buttons/history_configurations.dart';
export 'buttons/indent_configurations.dart';
export 'buttons/link_style2_configurations.dart';
export 'buttons/link_style_configurations.dart';
export 'buttons/search_configurations.dart';
export 'buttons/select_alignment_configurations.dart';
export 'buttons/select_header_style_buttons_configurations.dart';
export 'buttons/select_header_style_dropdown_button_configurations.dart';
export 'buttons/toggle_check_list_configurations.dart';
export 'buttons/toggle_style_configurations.dart';
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

enum SearchButtonType {
  /// Will use [QuillToolbarSearchButton]
  legacy,

  /// Will use [QuillToolbarLegacySearchButton]
  modern,
}

/// The configurations for the toolbar widget of flutter quill
@immutable
class QuillSimpleToolbarConfigurations extends QuillSharedToolbarProperties {
  const QuillSimpleToolbarConfigurations({
    @Deprecated(
        'controller should be passed directly to the toolbar - this parameter will be removed in future versions.')
    this.controller,
    super.sharedConfigurations,
    super.toolbarSectionSpacing = kToolbarSectionSpacing,
    super.toolbarIconAlignment = WrapAlignment.center,
    super.toolbarIconCrossAlignment = WrapCrossAlignment.center,
    super.buttonOptions = const QuillSimpleToolbarButtonOptions(),
    this.customButtons = const [],
    this.fontFamilyValues,
    super.multiRowsDisplay = true,
    this.fontSizesValues,
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
    this.showClipboardCut = true,
    this.showClipboardCopy = true,
    this.showClipboardPaste = true,
    this.linkStyleType = LinkStyleType.original,
    this.headerStyleType = HeaderStyleType.original,
    this.searchButtonType = SearchButtonType.modern,

    /// The decoration to use for the toolbar.
    super.decoration,

    /// Toolbar items to display for controls of embed blocks
    this.embedButtons,
    super.linkDialogAction,

    ///The theme to use for the icons in the toolbar, uses type [QuillIconTheme]
    // this.iconTheme,
    this.dialogTheme,
    super.axis = Axis.horizontal,
    super.color,
    super.sectionDividerColor,
    super.sectionDividerSpace,

    /// By default it will calculated based on the [globalIconSize] from
    /// [base] in [QuillToolbarButtonOptions]
    /// You can change it but the the change only apply if
    /// the [multiRowsDisplay] is false, if [multiRowsDisplay] then the value
    /// will be [kDefaultIconSize] * 2
    super.toolbarSize,
  }) : _toolbarSize = toolbarSize;

  final double? _toolbarSize;

  /// The toolbar size, by default it will be `baseButtonOptions.iconSize * 2`
  @override
  double get toolbarSize {
    final alternativeToolbarSize = _toolbarSize;
    if (alternativeToolbarSize != null) {
      return alternativeToolbarSize;
    }
    return (buttonOptions.base.iconSize ?? kDefaultIconSize) * 2;
  }

  final Map<String, String>? fontFamilyValues;

  @Deprecated('controller will be removed in future versions.')
  final QuillController? controller;

  /// By default it will be
  /// ```dart
  /// {
  ///   'Small'.i18n: 'small',
  ///   'Large'.i18n: 'large',
  ///   'Huge'.i18n: 'huge',
  ///   'Clear'.loc: '0'
  /// }
  /// ```
  final Map<String, String>? fontSizesValues;

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
  final bool showClipboardCut;
  final bool showClipboardCopy;
  final bool showClipboardPaste;

  /// This activates a functionality that is only implemented in [flutter_quill] and is NOT originally
  /// used in the [Quill Js API]. So it could cause conflicts if you use this attribute with the original Delta format of Quill Js
  final bool showLineHeightButton;

  /// Toolbar items to display for controls of embed blocks
  final List<EmbedButtonBuilder>? embedButtons;

  // ///The theme to use for the icons in the toolbar, uses type [QuillIconTheme]
  // final QuillIconTheme? iconTheme;

  ///The theme to use for the theming of the [LinkDialog()],
  ///shown when embedding an image, for example
  final QuillDialogTheme? dialogTheme;

  /// Defines which dialog is used for applying link attribute.
  final LinkStyleType linkStyleType;

  /// Defines which dialog is used for applying header attribute.
  final HeaderStyleType headerStyleType;

  /// Define which button type should be used for the [showSearchButton]
  final SearchButtonType searchButtonType;

  @override
  List<Object?> get props => [
        buttonOptions,
        multiRowsDisplay,
        fontSizesValues,
        toolbarSize,
        axis,
      ];
}
