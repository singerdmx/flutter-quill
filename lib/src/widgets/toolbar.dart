import 'package:flutter/material.dart';
import 'package:i18n_extension/i18n_widget.dart';

import '../models/documents/attribute.dart';
import '../models/structs/link_dialog_action.dart';
import '../models/themes/quill_custom_button.dart';
import '../models/themes/quill_dialog_theme.dart';
import '../models/themes/quill_icon_theme.dart';
import '../translations/toolbar.i18n.dart';
import 'controller.dart';
import 'embeds.dart';
import 'toolbar/arrow_indicated_button_list.dart';
import 'toolbar/clear_format_button.dart';
import 'toolbar/color_button.dart';
import 'toolbar/custom_button.dart';
import 'toolbar/enum.dart';
import 'toolbar/history_button.dart';
import 'toolbar/indent_button.dart';
import 'toolbar/link_style_button.dart';
import 'toolbar/quill_font_family_button.dart';
import 'toolbar/quill_font_size_button.dart';
import 'toolbar/search_button.dart';
import 'toolbar/select_alignment_button.dart';
import 'toolbar/select_header_style_button.dart';
import 'toolbar/toggle_check_list_button.dart';
import 'toolbar/toggle_style_button.dart';

export 'toolbar/clear_format_button.dart';
export 'toolbar/color_button.dart';
export 'toolbar/custom_button.dart';
export 'toolbar/history_button.dart';
export 'toolbar/indent_button.dart';
export 'toolbar/link_style_button.dart';
export 'toolbar/link_style_button2.dart';
export 'toolbar/quill_font_family_button.dart';
export 'toolbar/quill_font_size_button.dart';
export 'toolbar/quill_icon_button.dart';
export 'toolbar/search_button.dart';
export 'toolbar/select_alignment_button.dart';
export 'toolbar/select_header_style_button.dart';
export 'toolbar/toggle_check_list_button.dart';
export 'toolbar/toggle_style_button.dart';

/// The default size of the icon of a button.
const double kDefaultIconSize = 18;

/// The factor of how much larger the button is in relation to the icon.
const double kIconButtonFactor = 1.77;

/// The horizontal margin between the contents of each toolbar section.
const double kToolbarSectionSpacing = 4;

class QuillToolbar extends StatelessWidget implements PreferredSizeWidget {
  const QuillToolbar({
    required this.children,
    this.axis = Axis.horizontal,
    this.toolbarSize = kDefaultIconSize * 2,
    this.toolbarSectionSpacing = kToolbarSectionSpacing,
    this.toolbarIconAlignment = WrapAlignment.center,
    this.toolbarIconCrossAlignment = WrapCrossAlignment.center,
    this.multiRowsDisplay = true,
    this.color,
    this.customButtons = const [],
    this.locale,
    VoidCallback? afterButtonPressed,
    this.sectionDividerColor,
    this.sectionDividerSpace,
    this.linkDialogAction,
    Key? key,
  }) : super(key: key);

  factory QuillToolbar.basic({
    required QuillController controller,
    Axis axis = Axis.horizontal,
    double toolbarIconSize = kDefaultIconSize,
    double toolbarSectionSpacing = kToolbarSectionSpacing,
    WrapAlignment toolbarIconAlignment = WrapAlignment.center,
    WrapCrossAlignment toolbarIconCrossAlignment = WrapCrossAlignment.center,
    bool multiRowsDisplay = true,
    bool showDividers = true,
    bool showFontFamily = true,
    bool showFontSize = true,
    bool showBoldButton = true,
    bool showItalicButton = true,
    bool showSmallButton = false,
    bool showUnderLineButton = true,
    bool showStrikeThrough = true,
    bool showInlineCode = true,
    bool showColorButton = true,
    bool showBackgroundColorButton = true,
    bool showClearFormat = true,
    bool showAlignmentButtons = false,
    bool showLeftAlignment = true,
    bool showCenterAlignment = true,
    bool showRightAlignment = true,
    bool showJustifyAlignment = true,
    bool showHeaderStyle = true,
    bool showListNumbers = true,
    bool showListBullets = true,
    bool showListCheck = true,
    bool showCodeBlock = true,
    bool showQuote = true,
    bool showIndent = true,
    bool showLink = true,
    bool showUndo = true,
    bool showRedo = true,
    bool showDirection = false,
    bool showSearchButton = true,
    bool showSubscript = true,
    bool showSuperscript = true,
    List<QuillCustomButton> customButtons = const [],

    ///Map of font sizes in string
    Map<String, String>? fontSizeValues,

    ///Map of font families in string
    Map<String, String>? fontFamilyValues,

    /// Toolbar items to display for controls of embed blocks
    List<EmbedButtonBuilder>? embedButtons,

    ///The theme to use for the icons in the toolbar, uses type [QuillIconTheme]
    QuillIconTheme? iconTheme,

    ///The theme to use for the theming of the [LinkDialog()],
    ///shown when embedding an image, for example
    QuillDialogTheme? dialogTheme,

    /// Callback to be called after any button on the toolbar is pressed.
    /// Is called after whatever logic the button performs has run.
    VoidCallback? afterButtonPressed,

    ///Map of tooltips for toolbar  buttons
    ///
    ///The example is:
    ///```dart
    /// tooltips = <ToolbarButtons, String>{
    ///   ToolbarButtons.undo: 'Undo',
    ///   ToolbarButtons.redo: 'Redo',
    /// }
    ///
    ///```
    ///
    /// To disable tooltips just pass empty map as well.
    Map<ToolbarButtons, String>? tooltips,

    /// The locale to use for the editor toolbar, defaults to system locale
    /// More at https://github.com/singerdmx/flutter-quill#translation
    Locale? locale,

    /// The color of the toolbar
    Color? color,

    /// The color of the toolbar section divider
    Color? sectionDividerColor,

    /// The space occupied by toolbar divider
    double? sectionDividerSpace,

    /// Validate the legitimacy of hyperlinks
    RegExp? linkRegExp,
    LinkDialogAction? linkDialogAction,
    Key? key,
  }) {
    final isButtonGroupShown = [
      showFontFamily ||
          showFontSize ||
          showBoldButton ||
          showItalicButton ||
          showSmallButton ||
          showUnderLineButton ||
          showStrikeThrough ||
          showInlineCode ||
          showColorButton ||
          showBackgroundColorButton ||
          showClearFormat ||
          embedButtons?.isNotEmpty == true,
      showAlignmentButtons || showDirection,
      showLeftAlignment,
      showCenterAlignment,
      showRightAlignment,
      showJustifyAlignment,
      showHeaderStyle,
      showListNumbers || showListBullets || showListCheck || showCodeBlock,
      showQuote || showIndent,
      showLink || showSearchButton
    ];

    //default font size values
    final fontSizes = fontSizeValues ??
        {
          'Small'.i18n: 'small',
          'Large'.i18n: 'large',
          'Huge'.i18n: 'huge',
          'Clear'.i18n: '0'
        };

    //default font family values
    final fontFamilies = fontFamilyValues ??
        {
          'Sans Serif': 'sans-serif',
          'Serif': 'serif',
          'Monospace': 'monospace',
          'Ibarra Real Nova': 'ibarra-real-nova',
          'SquarePeg': 'square-peg',
          'Nunito': 'nunito',
          'Pacifico': 'pacifico',
          'Roboto Mono': 'roboto-mono',
          'Clear'.i18n: 'Clear'
        };

    //default button tooltips
    final buttonTooltips = tooltips ??
        <ToolbarButtons, String>{
          ToolbarButtons.undo: 'Undo'.i18n,
          ToolbarButtons.redo: 'Redo'.i18n,
          ToolbarButtons.fontFamily: 'Font family'.i18n,
          ToolbarButtons.fontSize: 'Font size'.i18n,
          ToolbarButtons.bold: 'Bold'.i18n,
          ToolbarButtons.subscript: 'Subscript'.i18n,
          ToolbarButtons.superscript: 'Superscript'.i18n,
          ToolbarButtons.italic: 'Italic'.i18n,
          ToolbarButtons.small: 'Small'.i18n,
          ToolbarButtons.underline: 'Underline'.i18n,
          ToolbarButtons.strikeThrough: 'Strike through'.i18n,
          ToolbarButtons.inlineCode: 'Inline code'.i18n,
          ToolbarButtons.color: 'Font color'.i18n,
          ToolbarButtons.backgroundColor: 'Background color'.i18n,
          ToolbarButtons.clearFormat: 'Clear format'.i18n,
          ToolbarButtons.leftAlignment: 'Align left'.i18n,
          ToolbarButtons.centerAlignment: 'Align center'.i18n,
          ToolbarButtons.rightAlignment: 'Align right'.i18n,
          ToolbarButtons.justifyAlignment: 'Justify win width'.i18n,
          ToolbarButtons.direction: 'Text direction'.i18n,
          ToolbarButtons.headerStyle: 'Header style'.i18n,
          ToolbarButtons.listNumbers: 'Numbered list'.i18n,
          ToolbarButtons.listBullets: 'Bullet list'.i18n,
          ToolbarButtons.listChecks: 'Checked list'.i18n,
          ToolbarButtons.codeBlock: 'Code block'.i18n,
          ToolbarButtons.quote: 'Quote'.i18n,
          ToolbarButtons.indentIncrease: 'Increase indent'.i18n,
          ToolbarButtons.indentDecrease: 'Decrease indent'.i18n,
          ToolbarButtons.link: 'Insert URL'.i18n,
          ToolbarButtons.search: 'Search'.i18n,
        };

    return QuillToolbar(
      key: key,
      axis: axis,
      color: color,
      toolbarSize: toolbarIconSize * 2,
      toolbarSectionSpacing: toolbarSectionSpacing,
      toolbarIconAlignment: toolbarIconAlignment,
      toolbarIconCrossAlignment: toolbarIconCrossAlignment,
      multiRowsDisplay: multiRowsDisplay,
      customButtons: customButtons,
      locale: locale,
      afterButtonPressed: afterButtonPressed,
      children: [
        if (showUndo)
          HistoryButton(
            icon: Icons.undo_outlined,
            iconSize: toolbarIconSize,
            tooltip: buttonTooltips[ToolbarButtons.undo],
            controller: controller,
            undo: true,
            iconTheme: iconTheme,
            afterButtonPressed: afterButtonPressed,
          ),
        if (showRedo)
          HistoryButton(
            icon: Icons.redo_outlined,
            iconSize: toolbarIconSize,
            tooltip: buttonTooltips[ToolbarButtons.redo],
            controller: controller,
            undo: false,
            iconTheme: iconTheme,
            afterButtonPressed: afterButtonPressed,
          ),
        if (showFontFamily)
          QuillFontFamilyButton(
            iconTheme: iconTheme,
            iconSize: toolbarIconSize,
            tooltip: buttonTooltips[ToolbarButtons.fontFamily],
            attribute: Attribute.font,
            controller: controller,
            rawItemsMap: fontFamilies,
            afterButtonPressed: afterButtonPressed,
          ),
        if (showFontSize)
          QuillFontSizeButton(
            iconTheme: iconTheme,
            iconSize: toolbarIconSize,
            tooltip: buttonTooltips[ToolbarButtons.fontSize],
            attribute: Attribute.size,
            controller: controller,
            rawItemsMap: fontSizes,
            afterButtonPressed: afterButtonPressed,
          ),
        if (showBoldButton)
          ToggleStyleButton(
            attribute: Attribute.bold,
            icon: Icons.format_bold,
            iconSize: toolbarIconSize,
            tooltip: buttonTooltips[ToolbarButtons.bold],
            controller: controller,
            iconTheme: iconTheme,
            afterButtonPressed: afterButtonPressed,
          ),
        if (showSubscript)
          ToggleStyleButton(
            attribute: Attribute.subscript,
            icon: Icons.subscript,
            iconSize: toolbarIconSize,
            tooltip: buttonTooltips[ToolbarButtons.subscript],
            controller: controller,
            iconTheme: iconTheme,
            afterButtonPressed: afterButtonPressed,
          ),
        if (showSuperscript)
          ToggleStyleButton(
            attribute: Attribute.superscript,
            icon: Icons.superscript,
            iconSize: toolbarIconSize,
            tooltip: buttonTooltips[ToolbarButtons.superscript],
            controller: controller,
            iconTheme: iconTheme,
            afterButtonPressed: afterButtonPressed,
          ),
        if (showItalicButton)
          ToggleStyleButton(
            attribute: Attribute.italic,
            icon: Icons.format_italic,
            iconSize: toolbarIconSize,
            tooltip: buttonTooltips[ToolbarButtons.italic],
            controller: controller,
            iconTheme: iconTheme,
            afterButtonPressed: afterButtonPressed,
          ),
        if (showSmallButton)
          ToggleStyleButton(
            attribute: Attribute.small,
            icon: Icons.format_size,
            iconSize: toolbarIconSize,
            tooltip: buttonTooltips[ToolbarButtons.small],
            controller: controller,
            iconTheme: iconTheme,
            afterButtonPressed: afterButtonPressed,
          ),
        if (showUnderLineButton)
          ToggleStyleButton(
            attribute: Attribute.underline,
            icon: Icons.format_underline,
            iconSize: toolbarIconSize,
            tooltip: buttonTooltips[ToolbarButtons.underline],
            controller: controller,
            iconTheme: iconTheme,
            afterButtonPressed: afterButtonPressed,
          ),
        if (showStrikeThrough)
          ToggleStyleButton(
            attribute: Attribute.strikeThrough,
            icon: Icons.format_strikethrough,
            iconSize: toolbarIconSize,
            tooltip: buttonTooltips[ToolbarButtons.strikeThrough],
            controller: controller,
            iconTheme: iconTheme,
            afterButtonPressed: afterButtonPressed,
          ),
        if (showInlineCode)
          ToggleStyleButton(
            attribute: Attribute.inlineCode,
            icon: Icons.code,
            iconSize: toolbarIconSize,
            tooltip: buttonTooltips[ToolbarButtons.inlineCode],
            controller: controller,
            iconTheme: iconTheme,
            afterButtonPressed: afterButtonPressed,
          ),
        if (showColorButton)
          ColorButton(
            icon: Icons.color_lens,
            iconSize: toolbarIconSize,
            tooltip: buttonTooltips[ToolbarButtons.color],
            controller: controller,
            background: false,
            iconTheme: iconTheme,
            afterButtonPressed: afterButtonPressed,
          ),
        if (showBackgroundColorButton)
          ColorButton(
            icon: Icons.format_color_fill,
            iconSize: toolbarIconSize,
            tooltip: buttonTooltips[ToolbarButtons.backgroundColor],
            controller: controller,
            background: true,
            iconTheme: iconTheme,
            afterButtonPressed: afterButtonPressed,
          ),
        if (showClearFormat)
          ClearFormatButton(
            icon: Icons.format_clear,
            iconSize: toolbarIconSize,
            tooltip: buttonTooltips[ToolbarButtons.clearFormat],
            controller: controller,
            iconTheme: iconTheme,
            afterButtonPressed: afterButtonPressed,
          ),
        if (embedButtons != null)
          for (final builder in embedButtons)
            builder(controller, toolbarIconSize, iconTheme, dialogTheme),
        if (showDividers &&
            isButtonGroupShown[0] &&
            (isButtonGroupShown[1] ||
                isButtonGroupShown[2] ||
                isButtonGroupShown[3] ||
                isButtonGroupShown[4] ||
                isButtonGroupShown[5]))
          QuillDivider(axis,
              color: sectionDividerColor, space: sectionDividerSpace),
        if (showAlignmentButtons)
          SelectAlignmentButton(
            controller: controller,
            tooltips: Map.of(buttonTooltips)
              ..removeWhere((key, value) => ![
                    ToolbarButtons.leftAlignment,
                    ToolbarButtons.centerAlignment,
                    ToolbarButtons.rightAlignment,
                    ToolbarButtons.justifyAlignment,
                  ].contains(key)),
            iconSize: toolbarIconSize,
            iconTheme: iconTheme,
            showLeftAlignment: showLeftAlignment,
            showCenterAlignment: showCenterAlignment,
            showRightAlignment: showRightAlignment,
            showJustifyAlignment: showJustifyAlignment,
            afterButtonPressed: afterButtonPressed,
          ),
        if (showDirection)
          ToggleStyleButton(
            attribute: Attribute.rtl,
            tooltip: buttonTooltips[ToolbarButtons.direction],
            controller: controller,
            icon: Icons.format_textdirection_r_to_l,
            iconSize: toolbarIconSize,
            iconTheme: iconTheme,
            afterButtonPressed: afterButtonPressed,
          ),
        if (showDividers &&
            isButtonGroupShown[1] &&
            (isButtonGroupShown[2] ||
                isButtonGroupShown[3] ||
                isButtonGroupShown[4] ||
                isButtonGroupShown[5]))
          QuillDivider(axis,
              color: sectionDividerColor, space: sectionDividerSpace),
        if (showHeaderStyle)
          SelectHeaderStyleButton(
            tooltip: buttonTooltips[ToolbarButtons.headerStyle],
            controller: controller,
            axis: axis,
            iconSize: toolbarIconSize,
            iconTheme: iconTheme,
            afterButtonPressed: afterButtonPressed,
          ),
        if (showDividers &&
            showHeaderStyle &&
            isButtonGroupShown[2] &&
            (isButtonGroupShown[3] ||
                isButtonGroupShown[4] ||
                isButtonGroupShown[5]))
          QuillDivider(axis,
              color: sectionDividerColor, space: sectionDividerSpace),
        if (showListNumbers)
          ToggleStyleButton(
            attribute: Attribute.ol,
            tooltip: buttonTooltips[ToolbarButtons.listNumbers],
            controller: controller,
            icon: Icons.format_list_numbered,
            iconSize: toolbarIconSize,
            iconTheme: iconTheme,
            afterButtonPressed: afterButtonPressed,
          ),
        if (showListBullets)
          ToggleStyleButton(
            attribute: Attribute.ul,
            tooltip: buttonTooltips[ToolbarButtons.listBullets],
            controller: controller,
            icon: Icons.format_list_bulleted,
            iconSize: toolbarIconSize,
            iconTheme: iconTheme,
            afterButtonPressed: afterButtonPressed,
          ),
        if (showListCheck)
          ToggleCheckListButton(
            attribute: Attribute.unchecked,
            tooltip: buttonTooltips[ToolbarButtons.listChecks],
            controller: controller,
            icon: Icons.check_box,
            iconSize: toolbarIconSize,
            iconTheme: iconTheme,
            afterButtonPressed: afterButtonPressed,
          ),
        if (showCodeBlock)
          ToggleStyleButton(
            attribute: Attribute.codeBlock,
            tooltip: buttonTooltips[ToolbarButtons.codeBlock],
            controller: controller,
            icon: Icons.code,
            iconSize: toolbarIconSize,
            iconTheme: iconTheme,
            afterButtonPressed: afterButtonPressed,
          ),
        if (showDividers &&
            isButtonGroupShown[3] &&
            (isButtonGroupShown[4] || isButtonGroupShown[5]))
          QuillDivider(axis,
              color: sectionDividerColor, space: sectionDividerSpace),
        if (showQuote)
          ToggleStyleButton(
            attribute: Attribute.blockQuote,
            tooltip: buttonTooltips[ToolbarButtons.quote],
            controller: controller,
            icon: Icons.format_quote,
            iconSize: toolbarIconSize,
            iconTheme: iconTheme,
            afterButtonPressed: afterButtonPressed,
          ),
        if (showIndent)
          IndentButton(
            icon: Icons.format_indent_increase,
            iconSize: toolbarIconSize,
            tooltip: buttonTooltips[ToolbarButtons.indentIncrease],
            controller: controller,
            isIncrease: true,
            iconTheme: iconTheme,
            afterButtonPressed: afterButtonPressed,
          ),
        if (showIndent)
          IndentButton(
            icon: Icons.format_indent_decrease,
            iconSize: toolbarIconSize,
            tooltip: buttonTooltips[ToolbarButtons.indentDecrease],
            controller: controller,
            isIncrease: false,
            iconTheme: iconTheme,
            afterButtonPressed: afterButtonPressed,
          ),
        if (showDividers && isButtonGroupShown[4] && isButtonGroupShown[5])
          QuillDivider(axis,
              color: sectionDividerColor, space: sectionDividerSpace),
        if (showLink)
          LinkStyleButton(
            tooltip: buttonTooltips[ToolbarButtons.link],
            controller: controller,
            iconSize: toolbarIconSize,
            iconTheme: iconTheme,
            dialogTheme: dialogTheme,
            afterButtonPressed: afterButtonPressed,
            linkRegExp: linkRegExp,
            linkDialogAction: linkDialogAction,
          ),
        if (showSearchButton)
          SearchButton(
            icon: Icons.search,
            iconSize: toolbarIconSize,
            tooltip: buttonTooltips[ToolbarButtons.search],
            controller: controller,
            iconTheme: iconTheme,
            dialogTheme: dialogTheme,
            afterButtonPressed: afterButtonPressed,
          ),
        if (customButtons.isNotEmpty)
          if (showDividers)
            QuillDivider(axis,
                color: sectionDividerColor, space: sectionDividerSpace),
        for (var customButton in customButtons)
          if (customButton.child != null) ...[
            InkWell(
              onTap: customButton.onTap,
              child: customButton.child,
            ),
          ] else ...[
            CustomButton(
              onPressed: customButton.onTap,
              icon: customButton.icon,
              iconColor: customButton.iconColor,
              iconSize: toolbarIconSize,
              iconTheme: iconTheme,
              afterButtonPressed: afterButtonPressed,
              tooltip: customButton.tooltip,
            ),
          ],
      ],
    );
  }

  final List<Widget> children;
  final Axis axis;
  final double toolbarSize;
  final double toolbarSectionSpacing;
  final WrapAlignment toolbarIconAlignment;
  final WrapCrossAlignment toolbarIconCrossAlignment;
  final bool multiRowsDisplay;

  // Overrides the action in the _LinkDialog widget
  final LinkDialogAction? linkDialogAction;

  /// The color of the toolbar.
  ///
  /// Defaults to [ThemeData.canvasColor] of the current [Theme] if no color
  /// is given.
  final Color? color;

  /// The locale to use for the editor toolbar, defaults to system locale
  /// More https://github.com/singerdmx/flutter-quill#translation
  final Locale? locale;

  /// List of custom buttons
  final List<QuillCustomButton> customButtons;

  /// The color to use when painting the toolbar section divider.
  ///
  /// If this is null, then the [DividerThemeData.color] is used. If that is
  /// also null, then [ThemeData.dividerColor] is used.
  final Color? sectionDividerColor;

  /// The space occupied by toolbar section divider.
  final double? sectionDividerSpace;

  @override
  Size get preferredSize => axis == Axis.horizontal
      ? Size.fromHeight(toolbarSize)
      : Size.fromWidth(toolbarSize);

  @override
  Widget build(BuildContext context) {
    return I18n(
      initialLocale: locale,
      child: multiRowsDisplay
          ? Wrap(
              direction: axis,
              alignment: toolbarIconAlignment,
              crossAxisAlignment: toolbarIconCrossAlignment,
              runSpacing: 4,
              spacing: toolbarSectionSpacing,
              children: children,
            )
          : Container(
              constraints: BoxConstraints.tightFor(
                height: axis == Axis.horizontal ? toolbarSize : null,
                width: axis == Axis.vertical ? toolbarSize : null,
              ),
              color: color ?? Theme.of(context).canvasColor,
              child: ArrowIndicatedButtonList(
                axis: axis,
                buttons: children,
              ),
            ),
    );
  }
}

/// The divider which is used for separation of buttons in the toolbar.
///
/// It can be used outside of this package, for example when user does not use
/// [QuillToolbar.basic] and compose toolbar's children on its own.
class QuillDivider extends StatelessWidget {
  const QuillDivider(
    this.axis, {
    Key? key,
    this.color,
    this.space,
  }) : super(key: key);

  /// Provides a horizontal divider for vertical toolbar.
  const QuillDivider.horizontal({Color? color, double? space})
      : this(Axis.horizontal, color: color, space: space);

  /// Provides a horizontal divider for horizontal toolbar.
  const QuillDivider.vertical({Color? color, double? space})
      : this(Axis.vertical, color: color, space: space);

  /// The axis along which the toolbar is.
  final Axis axis;

  /// The color to use when painting this divider's line.
  final Color? color;

  /// The divider's space (width or height) depending of [axis].
  final double? space;

  @override
  Widget build(BuildContext context) {
    // Vertical toolbar requires horizontal divider, and vice versa
    return axis == Axis.vertical
        ? Divider(
            height: space,
            color: color,
            indent: 12,
            endIndent: 12,
          )
        : VerticalDivider(
            width: space,
            color: color,
            indent: 12,
            endIndent: 12,
          );
  }
}
