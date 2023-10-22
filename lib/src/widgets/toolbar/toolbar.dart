import 'package:flutter/material.dart';
import 'package:i18n_extension/i18n_widget.dart';

import '../../../flutter_quill.dart';
import '../../translations/toolbar.i18n.dart';
import '../../utils/extensions/build_context.dart';
import 'buttons/arrow_indicated_list.dart';

export '../../models/config/toolbar/buttons/base.dart';
export '../../models/config/toolbar/configurations.dart';
export 'buttons/clear_format.dart';
export 'buttons/color.dart';
export 'buttons/custom_button.dart';
export 'buttons/font_family.dart';
export 'buttons/font_size.dart';
export 'buttons/history.dart';
export 'buttons/indent.dart';
export 'buttons/link_style.dart';
export 'buttons/link_style2.dart';
export 'buttons/quill_icon.dart';
export 'buttons/search.dart';
export 'buttons/select_alignment.dart';
export 'buttons/select_header_style.dart';
export 'buttons/toggle_check_list.dart';
export 'buttons/toggle_style.dart';

typedef QuillToolbarChildrenBuilder = List<Widget> Function(
  BuildContext context,
);

class QuillToolbar extends StatelessWidget implements PreferredSizeWidget {
  const QuillToolbar({
    required this.childrenBuilder,
    this.axis = Axis.horizontal,
    // this.toolbarSize = kDefaultIconSize * 2,
    this.toolbarSectionSpacing = kToolbarSectionSpacing,
    this.toolbarIconAlignment = WrapAlignment.center,
    this.toolbarIconCrossAlignment = WrapCrossAlignment.center,
    this.color,
    this.customButtons = const [],
    VoidCallback? afterButtonPressed,
    this.sectionDividerColor,
    this.sectionDividerSpace,
    this.linkDialogAction,
    this.decoration,
    Key? key,
  }) : super(key: key);

  factory QuillToolbar.basic({
    Axis axis = Axis.horizontal,
    double toolbarSectionSpacing = kToolbarSectionSpacing,
    WrapAlignment toolbarIconAlignment = WrapAlignment.center,
    WrapCrossAlignment toolbarIconCrossAlignment = WrapCrossAlignment.center,
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

    /// The decoration to use for the toolbar.
    Decoration? decoration,

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
      showLeftAlignment ||
          showCenterAlignment ||
          showRightAlignment ||
          showJustifyAlignment ||
          showDirection,
      showHeaderStyle,
      showListNumbers || showListBullets || showListCheck || showCodeBlock,
      showQuote || showIndent,
      showLink || showSearchButton
    ];

    //default button tooltips
    final buttonTooltips = tooltips ??
        <ToolbarButtons, String>{
          ToolbarButtons.headerStyle: 'Header style'.i18n,
          ToolbarButtons.link: 'Insert URL'.i18n,
          ToolbarButtons.search: 'Search'.i18n,
        };

    return QuillToolbar(
      key: key,
      axis: axis,
      color: color,
      decoration: decoration,
      toolbarSectionSpacing: toolbarSectionSpacing,
      toolbarIconAlignment: toolbarIconAlignment,
      toolbarIconCrossAlignment: toolbarIconCrossAlignment,
      customButtons: customButtons,
      afterButtonPressed: afterButtonPressed,
      childrenBuilder: (context) {
        final controller = context.requireQuillController;

        final toolbarConfigurations = context.requireQuillToolbarConfigurations;

        final toolbarIconSize =
            toolbarConfigurations.buttonOptions.base.globalIconSize;

        return [
          if (showUndo)
            QuillToolbarHistoryButton(
              options: toolbarConfigurations.buttonOptions.undoHistory,
            ),
          if (showRedo)
            QuillToolbarHistoryButton(
              options: toolbarConfigurations.buttonOptions.redoHistory,
            ),
          if (showFontFamily)
            QuillToolbarFontFamilyButton(
              options: toolbarConfigurations.buttonOptions.fontFamily,
              controller:
                  toolbarConfigurations.buttonOptions.fontFamily.controller ??
                      context.requireQuillController,
            ),
          if (showFontSize)
            QuillToolbarFontSizeButton(
              options: toolbarConfigurations.buttonOptions.fontSize,
              controller:
                  toolbarConfigurations.buttonOptions.fontFamily.controller ??
                      context.requireQuillController,
            ),
          if (showBoldButton)
            QuillToolbarToggleStyleButton(
              attribute: Attribute.bold,
              options: toolbarConfigurations.buttonOptions.bold,
              controller: toolbarConfigurations.buttonOptions.bold.controller ??
                  context.requireQuillController,
            ),
          if (showSubscript)
            QuillToolbarToggleStyleButton(
              attribute: Attribute.subscript,
              options: toolbarConfigurations.buttonOptions.subscript,
              controller:
                  toolbarConfigurations.buttonOptions.subscript.controller ??
                      context.requireQuillController,
            ),
          if (showSuperscript)
            QuillToolbarToggleStyleButton(
              attribute: Attribute.superscript,
              options: toolbarConfigurations.buttonOptions.superscript,
              controller:
                  toolbarConfigurations.buttonOptions.superscript.controller ??
                      context.requireQuillController,
            ),
          if (showItalicButton)
            QuillToolbarToggleStyleButton(
              attribute: Attribute.italic,
              options: toolbarConfigurations.buttonOptions.italic,
              controller:
                  toolbarConfigurations.buttonOptions.italic.controller ??
                      context.requireQuillController,
            ),
          if (showSmallButton)
            QuillToolbarToggleStyleButton(
              attribute: Attribute.small,
              options: toolbarConfigurations.buttonOptions.small,
              controller:
                  toolbarConfigurations.buttonOptions.small.controller ??
                      context.requireQuillController,
            ),
          if (showUnderLineButton)
            QuillToolbarToggleStyleButton(
              attribute: Attribute.underline,
              options: toolbarConfigurations.buttonOptions.underLine,
              controller:
                  toolbarConfigurations.buttonOptions.underLine.controller ??
                      context.requireQuillController,
            ),
          if (showStrikeThrough)
            QuillToolbarToggleStyleButton(
              attribute: Attribute.strikeThrough,
              options: toolbarConfigurations.buttonOptions.strikeThrough,
              controller: toolbarConfigurations
                      .buttonOptions.strikeThrough.controller ??
                  context.requireQuillController,
            ),
          if (showInlineCode)
            QuillToolbarToggleStyleButton(
              attribute: Attribute.inlineCode,
              options: toolbarConfigurations.buttonOptions.inlineCode,
              controller:
                  toolbarConfigurations.buttonOptions.inlineCode.controller ??
                      context.requireQuillController,
            ),
          if (showColorButton)
            QuillToolbarColorButton(
              controller: controller,
              isBackground: false,
              options: toolbarConfigurations.buttonOptions.color,
            ),
          if (showBackgroundColorButton)
            QuillToolbarColorButton(
              options: toolbarConfigurations.buttonOptions.backgroundColor,
              controller: controller,
              isBackground: true,
            ),
          if (showClearFormat)
            QuillToolbarClearFormatButton(
              controller: controller,
              options: toolbarConfigurations.buttonOptions.clearFormat,
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
            QuillToolbarDivider(
              axis,
              color: sectionDividerColor,
              space: sectionDividerSpace,
            ),
          if (showAlignmentButtons)
            QuillToolbarSelectAlignmentButton(
              controller: controller,
              options:
                  toolbarConfigurations.buttonOptions.selectAlignmentButtons,
              // tooltips: Map.of(buttonTooltips)
              //   ..removeWhere((key, value) => ![
              //         ToolbarButtons.leftAlignment,
              //         ToolbarButtons.centerAlignment,
              //         ToolbarButtons.rightAlignment,
              //         ToolbarButtons.justifyAlignment,
              //       ].contains(key)),
              showLeftAlignment: showLeftAlignment,
              showCenterAlignment: showCenterAlignment,
              showRightAlignment: showRightAlignment,
              showJustifyAlignment: showJustifyAlignment,
            ),
          if (showDirection)
            QuillToolbarToggleStyleButton(
              attribute: Attribute.rtl,
              options: toolbarConfigurations.buttonOptions.direction,
              controller:
                  toolbarConfigurations.buttonOptions.direction.controller ??
                      context.requireQuillController,
            ),
          if (showDividers &&
              isButtonGroupShown[1] &&
              (isButtonGroupShown[2] ||
                  isButtonGroupShown[3] ||
                  isButtonGroupShown[4] ||
                  isButtonGroupShown[5]))
            QuillToolbarDivider(
              axis,
              color: sectionDividerColor,
              space: sectionDividerSpace,
            ),
          if (showHeaderStyle)
            QuillToolbarSelectHeaderStyleButton(
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
            QuillToolbarDivider(
              axis,
              color: sectionDividerColor,
              space: sectionDividerSpace,
            ),
          if (showListNumbers)
            QuillToolbarToggleStyleButton(
              attribute: Attribute.ol,
              options: toolbarConfigurations.buttonOptions.listNumbers,
              controller:
                  toolbarConfigurations.buttonOptions.listNumbers.controller ??
                      context.requireQuillController,
            ),
          if (showListBullets)
            QuillToolbarToggleStyleButton(
              attribute: Attribute.ul,
              options: toolbarConfigurations.buttonOptions.listBullets,
              controller:
                  toolbarConfigurations.buttonOptions.listBullets.controller ??
                      context.requireQuillController,
            ),
          if (showListCheck)
            QuillToolbarToggleCheckListButton(
              options: toolbarConfigurations.buttonOptions.toggleCheckList,
              controller: toolbarConfigurations
                      .buttonOptions.toggleCheckList.controller ??
                  context.requireQuillController,
            ),
          if (showCodeBlock)
            QuillToolbarToggleStyleButton(
              attribute: Attribute.codeBlock,
              options: toolbarConfigurations.buttonOptions.codeBlock,
              controller:
                  toolbarConfigurations.buttonOptions.codeBlock.controller ??
                      context.requireQuillController,
            ),
          if (showDividers &&
              isButtonGroupShown[3] &&
              (isButtonGroupShown[4] || isButtonGroupShown[5]))
            QuillToolbarDivider(axis,
                color: sectionDividerColor, space: sectionDividerSpace),
          if (showQuote)
            QuillToolbarToggleStyleButton(
              options: toolbarConfigurations.buttonOptions.quote,
              controller:
                  toolbarConfigurations.buttonOptions.quote.controller ??
                      context.requireQuillController,
              attribute: Attribute.blockQuote,
            ),
          if (showIndent)
            QuillToolbarIndentButton(
              controller: toolbarConfigurations
                      .buttonOptions.indentIncrease.controller ??
                  context.requireQuillController,
              isIncrease: true,
              options: toolbarConfigurations.buttonOptions.indentIncrease,
            ),
          if (showIndent)
            QuillToolbarIndentButton(
              controller: toolbarConfigurations
                      .buttonOptions.indentDecrease.controller ??
                  context.requireQuillController,
              isIncrease: false,
              options: toolbarConfigurations.buttonOptions.indentDecrease,
            ),
          if (showDividers && isButtonGroupShown[4] && isButtonGroupShown[5])
            QuillToolbarDivider(axis,
                color: sectionDividerColor, space: sectionDividerSpace),
          if (showLink)
            QuillToolbarLinkStyleButton(
              tooltip: buttonTooltips[ToolbarButtons.link],
              controller: controller,
              iconSize: toolbarIconSize,
              iconTheme: iconTheme,
              dialogTheme: dialogTheme,
              afterButtonPressed: afterButtonPressed,
              linkRegExp: linkRegExp,
              linkDialogAction: linkDialogAction,
              dialogBarrierColor:
                  context.requireQuillSharedConfigurations.dialogBarrierColor,
            ),
          if (showSearchButton)
            QuillToolbarSearchButton(
              icon: Icons.search,
              iconSize: toolbarIconSize,
              dialogBarrierColor:
                  context.requireQuillSharedConfigurations.dialogBarrierColor,
              tooltip: buttonTooltips[ToolbarButtons.search],
              controller: controller,
              iconTheme: iconTheme,
              dialogTheme: dialogTheme,
              afterButtonPressed: afterButtonPressed,
            ),
          if (customButtons.isNotEmpty)
            if (showDividers)
              QuillToolbarDivider(
                axis,
                color: sectionDividerColor,
                space: sectionDividerSpace,
              ),
          for (final customButton in customButtons)
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
        ];
      },
    );
  }

  final QuillToolbarChildrenBuilder childrenBuilder;
  final Axis axis;
  final double toolbarSectionSpacing;
  final WrapAlignment toolbarIconAlignment;
  final WrapCrossAlignment toolbarIconCrossAlignment;

  // Overrides the action in the _LinkDialog widget
  final LinkDialogAction? linkDialogAction;

  /// The color of the toolbar.
  ///
  /// Defaults to [ThemeData.canvasColor] of the current [Theme] if no color
  /// is given.
  final Color? color;

  /// List of custom buttons
  final List<QuillCustomButton> customButtons;

  /// The color to use when painting the toolbar section divider.
  ///
  /// If this is null, then the [DividerThemeData.color] is used. If that is
  /// also null, then [ThemeData.dividerColor] is used.
  final Color? sectionDividerColor;

  /// The space occupied by toolbar section divider.
  final double? sectionDividerSpace;

  /// The decoration to use for the toolbar.
  final Decoration? decoration;

  // We can't get the modified [toolbarSize] by the developer
  // but I tested the [QuillToolbar] on the [appBar] and I didn't notice
  // a difference no matter what the value is so I will leave it to the
  // default
  @override
  Size get preferredSize => axis == Axis.horizontal
      ? const Size.fromHeight(defaultToolbarSize)
      : const Size.fromWidth(defaultToolbarSize);

  @override
  Widget build(BuildContext context) {
    final toolbarConfigurations = context.requireQuillToolbarConfigurations;
    final toolbarSize = toolbarConfigurations.toolbarSize;
    return I18n(
      initialLocale: context.quillSharedConfigurations?.locale,
      child: (toolbarConfigurations.multiRowsDisplay)
          ? Wrap(
              direction: axis,
              alignment: toolbarIconAlignment,
              crossAxisAlignment: toolbarIconCrossAlignment,
              runSpacing: 4,
              spacing: toolbarSectionSpacing,
              children: childrenBuilder(context),
            )
          : Container(
              decoration: decoration ??
                  BoxDecoration(
                    color: color ?? Theme.of(context).canvasColor,
                  ),
              constraints: BoxConstraints.tightFor(
                height: axis == Axis.horizontal ? toolbarSize : null,
                width: axis == Axis.vertical ? toolbarSize : null,
              ),
              child: QuillToolbarArrowIndicatedButtonList(
                axis: axis,
                buttons: childrenBuilder(context),
              ),
            ),
    );
  }
}

/// The divider which is used for separation of buttons in the toolbar.
///
/// It can be used outside of this package, for example when user does not use
/// [QuillToolbar.basic] and compose toolbar's children on its own.
class QuillToolbarDivider extends StatelessWidget {
  const QuillToolbarDivider(
    this.axis, {
    super.key,
    this.color,
    this.space,
  });

  /// Provides a horizontal divider for vertical toolbar.
  const QuillToolbarDivider.horizontal({Color? color, double? space})
      : this(Axis.horizontal, color: color, space: space);

  /// Provides a horizontal divider for horizontal toolbar.
  const QuillToolbarDivider.vertical({Color? color, double? space})
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
