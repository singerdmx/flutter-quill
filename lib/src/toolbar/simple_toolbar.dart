import 'package:flutter/material.dart';

import '../controller/quill_controller.dart';
import '../document/attribute.dart';
import 'buttons/alignment/select_alignment_buttons.dart';
import 'buttons/arrow_indicated_list_button.dart';
import 'embed/embed_button_builder.dart';
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
export 'buttons/link_style/link_style2_button.dart';
export 'buttons/link_style/link_style_button.dart';
export 'buttons/quill_icon_button.dart';
export 'buttons/search/search_button.dart';
export 'buttons/select_line_height_dropdown_button.dart';
export 'buttons/toggle_check_list_button.dart';
export 'buttons/toggle_style_button.dart';
export 'config/base_button_options.dart';
export 'config/simple_toolbar_config.dart';

class QuillSimpleToolbar extends StatelessWidget
    implements PreferredSizeWidget {
  const QuillSimpleToolbar({
    required this.controller,
    this.config = const QuillSimpleToolbarConfig(),
    super.key,
  });

  final QuillController controller;

  final QuillSimpleToolbarConfig config;

  double get _toolbarSize => config.toolbarSize * 1.4;

  @override
  Widget build(BuildContext context) {
    final embedButtons = config.embedButtons;

    List<Widget> childrenBuilder(BuildContext context) {
      final axis = config.axis;

      final divider = SizedBox(
          height: _toolbarSize,
          child: QuillToolbarDivider(
            axis,
            color: config.sectionDividerColor,
            space: config.sectionDividerSpace,
          ));

      final groups = [
        [
          if (config.showUndo)
            QuillToolbarHistoryButton(
              isUndo: true,
              options: config.buttonOptions.undoHistory,
              controller: controller,
              baseOptions: config.buttonOptions.base,
            ),
          if (config.showRedo)
            QuillToolbarHistoryButton(
              isUndo: false,
              options: config.buttonOptions.redoHistory,
              controller: controller,
              baseOptions: config.buttonOptions.base,
            ),
          if (config.showFontFamily)
            QuillToolbarFontFamilyButton(
              options: config.buttonOptions.fontFamily,
              controller: controller,
              baseOptions: config.buttonOptions.base,
            ),
          if (config.showFontSize)
            QuillToolbarFontSizeButton(
              options: config.buttonOptions.fontSize,
              controller: controller,
              baseOptions: config.buttonOptions.base,
            ),
          if (config.showBoldButton)
            QuillToolbarToggleStyleButton(
              attribute: Attribute.bold,
              options: config.buttonOptions.bold,
              controller: controller,
              baseOptions: config.buttonOptions.base,
            ),
          if (config.showItalicButton)
            QuillToolbarToggleStyleButton(
              attribute: Attribute.italic,
              options: config.buttonOptions.italic,
              controller: controller,
              baseOptions: config.buttonOptions.base,
            ),
          if (config.showUnderLineButton)
            QuillToolbarToggleStyleButton(
              attribute: Attribute.underline,
              options: config.buttonOptions.underLine,
              controller: controller,
              baseOptions: config.buttonOptions.base,
            ),
          if (config.showStrikeThrough)
            QuillToolbarToggleStyleButton(
              attribute: Attribute.strikeThrough,
              options: config.buttonOptions.strikeThrough,
              controller: controller,
              baseOptions: config.buttonOptions.base,
            ),
          if (config.showInlineCode)
            QuillToolbarToggleStyleButton(
              attribute: Attribute.inlineCode,
              options: config.buttonOptions.inlineCode,
              controller: controller,
              baseOptions: config.buttonOptions.base,
            ),
          if (config.showSubscript)
            QuillToolbarToggleStyleButton(
              attribute: Attribute.subscript,
              options: config.buttonOptions.subscript,
              controller: controller,
              baseOptions: config.buttonOptions.base,
            ),
          if (config.showSuperscript)
            QuillToolbarToggleStyleButton(
              attribute: Attribute.superscript,
              options: config.buttonOptions.superscript,
              controller: controller,
              baseOptions: config.buttonOptions.base,
            ),
          if (config.showSmallButton)
            QuillToolbarToggleStyleButton(
              attribute: Attribute.small,
              options: config.buttonOptions.small,
              controller: controller,
              baseOptions: config.buttonOptions.base,
            ),
          if (config.showColorButton)
            QuillToolbarColorButton(
              controller: controller,
              isBackground: false,
              options: config.buttonOptions.color,
              baseOptions: config.buttonOptions.base,
            ),
          if (config.showBackgroundColorButton)
            QuillToolbarColorButton(
              options: config.buttonOptions.backgroundColor,
              controller: controller,
              isBackground: true,
              baseOptions: config.buttonOptions.base,
            ),
          if (config.showClearFormat)
            QuillToolbarClearFormatButton(
              controller: controller,
              options: config.buttonOptions.clearFormat,
              baseOptions: config.buttonOptions.base,
            ),
          if (embedButtons != null)
            for (final builder in embedButtons)
              builder(
                context,
                EmbedButtonContext(
                  controller: controller,
                  toolbarIconSize: kDefaultIconSize,
                  iconTheme: config.iconTheme,
                  dialogTheme: config.dialogTheme,
                  baseButtonOptions: config.buttonOptions.base,
                ),
              ),
        ],
        [
          if (config.showAlignmentButtons)
            QuillToolbarSelectAlignmentButtons(
              controller: controller,
              options: config.buttonOptions.selectAlignmentButtons.copyWith(
                showLeftAlignment: config.showLeftAlignment,
                showCenterAlignment: config.showCenterAlignment,
                showRightAlignment: config.showRightAlignment,
                showJustifyAlignment: config.showJustifyAlignment,
              ),
              baseOptions: config.buttonOptions.base,
            ),
          if (config.showDirection)
            QuillToolbarToggleStyleButton(
              attribute: Attribute.rtl,
              options: config.buttonOptions.direction,
              controller: controller,
              baseOptions: config.buttonOptions.base,
            ),
        ],
        [
          if (config.showLineHeightButton)
            QuillToolbarSelectLineHeightStyleDropdownButton(
              controller: controller,
              options: config.buttonOptions.selectLineHeightStyleDropdownButton,
              baseOptions: config.buttonOptions.base,
            ),
          if (config.showHeaderStyle) ...[
            if (config.headerStyleType.isOriginal)
              QuillToolbarSelectHeaderStyleDropdownButton(
                controller: controller,
                options: config.buttonOptions.selectHeaderStyleDropdownButton,
                baseOptions: config.buttonOptions.base,
              )
            else
              QuillToolbarSelectHeaderStyleButtons(
                controller: controller,
                options: config.buttonOptions.selectHeaderStyleButtons,
                baseOptions: config.buttonOptions.base,
              ),
          ],
        ],
        [
          if (config.showListNumbers)
            QuillToolbarToggleStyleButton(
              attribute: Attribute.ol,
              options: config.buttonOptions.listNumbers,
              controller: controller,
              baseOptions: config.buttonOptions.base,
            ),
          if (config.showListBullets)
            QuillToolbarToggleStyleButton(
              attribute: Attribute.ul,
              options: config.buttonOptions.listBullets,
              controller: controller,
              baseOptions: config.buttonOptions.base,
            ),
          if (config.showListCheck)
            QuillToolbarToggleCheckListButton(
              options: config.buttonOptions.toggleCheckList,
              controller: controller,
              baseOptions: config.buttonOptions.base,
            ),
          if (config.showCodeBlock)
            QuillToolbarToggleStyleButton(
              attribute: Attribute.codeBlock,
              options: config.buttonOptions.codeBlock,
              controller: controller,
              baseOptions: config.buttonOptions.base,
            ),
        ],
        [
          if (config.showQuote)
            QuillToolbarToggleStyleButton(
              options: config.buttonOptions.quote,
              controller: controller,
              attribute: Attribute.blockQuote,
              baseOptions: config.buttonOptions.base,
            ),
          if (config.showIndent)
            QuillToolbarIndentButton(
              controller: controller,
              isIncrease: true,
              options: config.buttonOptions.indentIncrease,
              baseOptions: config.buttonOptions.base,
            ),
          if (config.showIndent)
            QuillToolbarIndentButton(
              controller: controller,
              isIncrease: false,
              options: config.buttonOptions.indentDecrease,
              baseOptions: config.buttonOptions.base,
            ),
        ],
        [
          if (config.showLink)
            config.linkStyleType.isOriginal
                ? QuillToolbarLinkStyleButton(
                    controller: controller,
                    options: config.buttonOptions.linkStyle,
                    baseOptions: config.buttonOptions.base,
                  )
                : QuillToolbarLinkStyleButton2(
                    controller: controller,
                    options: config.buttonOptions.linkStyle2,
                    baseOptions: config.buttonOptions.base,
                  ),
          if (config.showSearchButton)
            QuillToolbarSearchButton(
              baseOptions: config.buttonOptions.base,
              controller: controller,
              options: config.buttonOptions.search,
            ),
          if (config.showClipboardCut)
            QuillToolbarClipboardButton(
              baseOptions: config.buttonOptions.base,
              options: config.buttonOptions.clipboardCut,
              controller: controller,
              clipboardAction: ClipboardAction.cut,
            ),
          if (config.showClipboardCopy)
            QuillToolbarClipboardButton(
              baseOptions: config.buttonOptions.base,
              options: config.buttonOptions.clipboardCopy,
              controller: controller,
              clipboardAction: ClipboardAction.copy,
            ),
          if (config.showClipboardPaste)
            QuillToolbarClipboardButton(
              baseOptions: config.buttonOptions.base,
              options: config.buttonOptions.clipboardPaste,
              controller: controller,
              clipboardAction: ClipboardAction.paste,
            ),
        ],
        [
          for (final customButton in config.customButtons)
            QuillToolbarCustomButton(
              baseOptions: config.buttonOptions.base,
              options: customButton,
              controller: controller,
            ),
        ],
      ];

      final buttonsAll = <Widget>[];

      for (var i = 0; i < groups.length; i++) {
        final buttons = groups[i];

        if (buttons.isNotEmpty) {
          if (buttonsAll.isNotEmpty && config.showDividers) {
            buttonsAll.add(divider);
          }
          buttonsAll.addAll(buttons);
        }
      }

      return buttonsAll;
    }

    return Builder(
      builder: (context) {
        if (config.multiRowsDisplay) {
          return Wrap(
            direction: config.axis,
            alignment: config.toolbarIconAlignment,
            crossAxisAlignment: config.toolbarIconCrossAlignment,
            runSpacing: config.toolbarRunSpacing,
            spacing: config.toolbarSectionSpacing,
            children: childrenBuilder(context),
          );
        }
        return Container(
          decoration: config.decoration ??
              BoxDecoration(
                color: config.color ?? Theme.of(context).canvasColor,
              ),
          constraints: BoxConstraints.tightFor(
            height: config.axis == Axis.horizontal ? _toolbarSize : null,
            width: config.axis == Axis.vertical ? _toolbarSize : null,
          ),
          child: QuillToolbarArrowIndicatedButtonList(
            axis: config.axis,
            buttons: childrenBuilder(context),
          ),
        );
      },
    );
  }

  @override
  Size get preferredSize => config.axis == Axis.horizontal
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
