import 'package:flutter/material.dart';

import '../controller/quill_controller.dart';
import '../document/attribute.dart';
import 'buttons/alignment/select_alignment_buttons.dart';
import 'buttons/arrow_indicated_list_button.dart';
import 'simple_toolbar.dart';

export 'buttons/alignment/select_alignment_button.dart';
export 'buttons/clear_format_button.dart';
export 'buttons/clipboard_button.dart';
export 'buttons/color/color_button.dart';
export 'buttons/custom_button_button.dart';
export 'buttons/font_family_button.dart';
export 'buttons/font_size_button.dart';
export 'buttons/hearder_style/select_header_style_buttons.dart';
export 'buttons/hearder_style/select_header_style_dropdown_button.dart';
export 'buttons/history_button.dart';
export 'buttons/indent_button.dart';
export 'buttons/link_style2_button.dart';
export 'buttons/link_style_button.dart';
export 'buttons/quill_icon_button.dart';
export 'buttons/search/search_button.dart';
export 'buttons/select_line_height_dropdown_button.dart';
export 'buttons/toggle_check_list_button.dart';
export 'buttons/toggle_style_button.dart';
export 'config/base_button_configurations.dart';
export 'config/simple_toolbar_configurations.dart';

class QuillSimpleToolbar extends StatelessWidget
    implements PreferredSizeWidget {
  const QuillSimpleToolbar({
    required this.controller,
    this.configurations = const QuillSimpleToolbarConfigurations(),
    super.key,
  });

  final QuillController controller;

  final QuillSimpleToolbarConfigurations configurations;

  double get _toolbarSize => configurations.toolbarSize * 1.4;

  @override
  Widget build(BuildContext context) {
    final embedButtons = configurations.embedButtons;

    List<Widget> childrenBuilder(BuildContext context) {
      final axis = configurations.axis;

      final divider = SizedBox(
          height: _toolbarSize,
          child: QuillToolbarDivider(
            axis,
            color: configurations.sectionDividerColor,
            space: configurations.sectionDividerSpace,
          ));

      final groups = [
        [
          if (configurations.showUndo)
            QuillToolbarHistoryButton(
              isUndo: true,
              options: configurations.buttonOptions.undoHistory,
              controller: controller,
            ),
          if (configurations.showRedo)
            QuillToolbarHistoryButton(
              isUndo: false,
              options: configurations.buttonOptions.redoHistory,
              controller: controller,
            ),
          if (configurations.showFontFamily)
            QuillToolbarFontFamilyButton(
              options: configurations.buttonOptions.fontFamily,
              controller: controller,
            ),
          if (configurations.showFontSize)
            QuillToolbarFontSizeButton(
              options: configurations.buttonOptions.fontSize,
              controller: controller,
            ),
          if (configurations.showBoldButton)
            QuillToolbarToggleStyleButton(
              attribute: Attribute.bold,
              options: configurations.buttonOptions.bold,
              controller: controller,
            ),
          if (configurations.showItalicButton)
            QuillToolbarToggleStyleButton(
              attribute: Attribute.italic,
              options: configurations.buttonOptions.italic,
              controller: controller,
            ),
          if (configurations.showUnderLineButton)
            QuillToolbarToggleStyleButton(
              attribute: Attribute.underline,
              options: configurations.buttonOptions.underLine,
              controller: controller,
            ),
          if (configurations.showStrikeThrough)
            QuillToolbarToggleStyleButton(
              attribute: Attribute.strikeThrough,
              options: configurations.buttonOptions.strikeThrough,
              controller: controller,
            ),
          if (configurations.showInlineCode)
            QuillToolbarToggleStyleButton(
              attribute: Attribute.inlineCode,
              options: configurations.buttonOptions.inlineCode,
              controller: controller,
            ),
          if (configurations.showSubscript)
            QuillToolbarToggleStyleButton(
              attribute: Attribute.subscript,
              options: configurations.buttonOptions.subscript,
              controller: controller,
            ),
          if (configurations.showSuperscript)
            QuillToolbarToggleStyleButton(
              attribute: Attribute.superscript,
              options: configurations.buttonOptions.superscript,
              controller: controller,
            ),
          if (configurations.showSmallButton)
            QuillToolbarToggleStyleButton(
              attribute: Attribute.small,
              options: configurations.buttonOptions.small,
              controller: controller,
            ),
          if (configurations.showColorButton)
            QuillToolbarColorButton(
              controller: controller,
              isBackground: false,
              options: configurations.buttonOptions.color,
            ),
          if (configurations.showBackgroundColorButton)
            QuillToolbarColorButton(
              options: configurations.buttonOptions.backgroundColor,
              controller: controller,
              isBackground: true,
            ),
          if (configurations.showClearFormat)
            QuillToolbarClearFormatButton(
              controller: controller,
              options: configurations.buttonOptions.clearFormat,
            ),
          if (embedButtons != null)
            for (final builder in embedButtons)
              builder(
                controller,
                kDefaultIconSize,
                configurations.iconTheme,
                configurations.dialogTheme,
              ),
        ],
        [
          if (configurations.showAlignmentButtons)
            QuillToolbarSelectAlignmentButtons(
              controller: controller,
              options:
                  configurations.buttonOptions.selectAlignmentButtons.copyWith(
                showLeftAlignment: configurations.showLeftAlignment,
                showCenterAlignment: configurations.showCenterAlignment,
                showRightAlignment: configurations.showRightAlignment,
                showJustifyAlignment: configurations.showJustifyAlignment,
              ),
            ),
          if (configurations.showDirection)
            QuillToolbarToggleStyleButton(
              attribute: Attribute.rtl,
              options: configurations.buttonOptions.direction,
              controller: controller,
            ),
        ],
        [
          if (configurations.showLineHeightButton)
            QuillToolbarSelectLineHeightStyleDropdownButton(
              controller: controller,
              options: configurations
                  .buttonOptions.selectLineHeightStyleDropdownButton,
            ),
          if (configurations.showHeaderStyle) ...[
            if (configurations.headerStyleType.isOriginal)
              QuillToolbarSelectHeaderStyleDropdownButton(
                controller: controller,
                options: configurations
                    .buttonOptions.selectHeaderStyleDropdownButton,
              )
            else
              QuillToolbarSelectHeaderStyleButtons(
                controller: controller,
                options: configurations.buttonOptions.selectHeaderStyleButtons,
              ),
          ],
        ],
        [
          if (configurations.showListNumbers)
            QuillToolbarToggleStyleButton(
              attribute: Attribute.ol,
              options: configurations.buttonOptions.listNumbers,
              controller: controller,
            ),
          if (configurations.showListBullets)
            QuillToolbarToggleStyleButton(
              attribute: Attribute.ul,
              options: configurations.buttonOptions.listBullets,
              controller: controller,
            ),
          if (configurations.showListCheck)
            QuillToolbarToggleCheckListButton(
              options: configurations.buttonOptions.toggleCheckList,
              controller: controller,
            ),
          if (configurations.showCodeBlock)
            QuillToolbarToggleStyleButton(
              attribute: Attribute.codeBlock,
              options: configurations.buttonOptions.codeBlock,
              controller: controller,
            ),
        ],
        [
          if (configurations.showQuote)
            QuillToolbarToggleStyleButton(
              options: configurations.buttonOptions.quote,
              controller: controller,
              attribute: Attribute.blockQuote,
            ),
          if (configurations.showIndent)
            QuillToolbarIndentButton(
              controller: controller,
              isIncrease: true,
              options: configurations.buttonOptions.indentIncrease,
            ),
          if (configurations.showIndent)
            QuillToolbarIndentButton(
              controller: controller,
              isIncrease: false,
              options: configurations.buttonOptions.indentDecrease,
            ),
        ],
        [
          if (configurations.showLink)
            configurations.linkStyleType.isOriginal
                ? QuillToolbarLinkStyleButton(
                    controller: controller,
                    options: configurations.buttonOptions.linkStyle,
                  )
                : QuillToolbarLinkStyleButton2(
                    controller: controller,
                    options: configurations.buttonOptions.linkStyle2,
                  ),
          if (configurations.showSearchButton)
            QuillToolbarSearchButton(
              controller: controller,
              options: configurations.buttonOptions.search,
            ),
          if (configurations.showClipboardCut)
            QuillToolbarClipboardButton(
              options: configurations.buttonOptions.clipboardCut,
              controller: controller,
              clipboardAction: ClipboardAction.cut,
            ),
          if (configurations.showClipboardCopy)
            QuillToolbarClipboardButton(
              options: configurations.buttonOptions.clipboardCopy,
              controller: controller,
              clipboardAction: ClipboardAction.copy,
            ),
          if (configurations.showClipboardPaste)
            QuillToolbarClipboardButton(
              options: configurations.buttonOptions.clipboardPaste,
              controller: controller,
              clipboardAction: ClipboardAction.paste,
            ),
        ],
        [
          for (final customButton in configurations.customButtons)
            QuillToolbarCustomButton(
              options: customButton,
              controller: controller,
            ),
        ],
      ];

      final buttonsAll = <Widget>[];

      for (var i = 0; i < groups.length; i++) {
        final buttons = groups[i];

        if (buttons.isNotEmpty) {
          if (buttonsAll.isNotEmpty && configurations.showDividers) {
            buttonsAll.add(divider);
          }
          buttonsAll.addAll(buttons);
        }
      }

      return buttonsAll;
    }

    return Builder(
      builder: (context) {
        if (configurations.multiRowsDisplay) {
          return Wrap(
            direction: configurations.axis,
            alignment: configurations.toolbarIconAlignment,
            crossAxisAlignment: configurations.toolbarIconCrossAlignment,
            runSpacing: configurations.toolbarRunSpacing,
            spacing: configurations.toolbarSectionSpacing,
            children: childrenBuilder(context),
          );
        }
        return Container(
          decoration: configurations.decoration ??
              BoxDecoration(
                color: configurations.color ?? Theme.of(context).canvasColor,
              ),
          constraints: BoxConstraints.tightFor(
            height:
                configurations.axis == Axis.horizontal ? _toolbarSize : null,
            width: configurations.axis == Axis.vertical ? _toolbarSize : null,
          ),
          child: QuillToolbarArrowIndicatedButtonList(
            axis: configurations.axis,
            buttons: childrenBuilder(context),
          ),
        );
      },
    );
  }

  @override
  Size get preferredSize => configurations.axis == Axis.horizontal
      ? const Size.fromHeight(kDefaultToolbarSize)
      : const Size.fromWidth(kDefaultToolbarSize);
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
  const QuillToolbarDivider.horizontal({Key? key, Color? color, double? space})
      : this(Axis.horizontal, color: color, space: space, key: key);

  /// Provides a horizontal divider for horizontal toolbar.
  const QuillToolbarDivider.vertical({Key? key, Color? color, double? space})
      : this(Axis.vertical, color: color, space: space, key: key);

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
