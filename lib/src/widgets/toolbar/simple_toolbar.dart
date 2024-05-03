import 'package:flutter/material.dart';

import '../../extensions/quill_configurations_ext.dart';
import '../../models/config/toolbar/toolbar_configurations.dart';
import '../../models/documents/attribute.dart';
import '../utils/provider.dart';
import 'base_toolbar.dart';
import 'buttons/alignment/select_alignment_buttons.dart';
import 'buttons/arrow_indicated_list_button.dart';

class QuillSimpleToolbar extends StatelessWidget
    implements PreferredSizeWidget {
  const QuillSimpleToolbar({
    required this.configurations,
    super.key,
  });

  /// The configurations for the toolbar widget of flutter quill
  final QuillSimpleToolbarConfigurations configurations;

  double get _toolbarSize => configurations.toolbarSize * 1.4;

  @override
  Widget build(BuildContext context) {
    final theEmbedButtons = configurations.embedButtons;

    final isButtonGroupShown = [
      configurations.showFontFamily ||
          configurations.showFontSize ||
          configurations.showBoldButton ||
          configurations.showItalicButton ||
          configurations.showSmallButton ||
          configurations.showUnderLineButton ||
          configurations.showStrikeThrough ||
          configurations.showInlineCode ||
          configurations.showColorButton ||
          configurations.showBackgroundColorButton ||
          configurations.showClearFormat ||
          theEmbedButtons?.isNotEmpty == true,
      configurations.showLeftAlignment ||
          configurations.showCenterAlignment ||
          configurations.showRightAlignment ||
          configurations.showJustifyAlignment ||
          configurations.showDirection,
      configurations.showHeaderStyle,
      configurations.showListNumbers ||
          configurations.showListBullets ||
          configurations.showListCheck ||
          configurations.showCodeBlock,
      configurations.showQuote || configurations.showIndent,
      configurations.showLink || configurations.showSearchButton
    ];

    List<Widget> childrenBuilder(BuildContext context) {
      final toolbarConfigurations =
          context.requireQuillSimpleToolbarConfigurations;

      final globalIconSize = toolbarConfigurations.buttonOptions.base.iconSize;

      final axis = toolbarConfigurations.axis;
      final globalController = configurations.controller;

      final divider = SizedBox(
          height: _toolbarSize,
          child: QuillToolbarDivider(
            axis,
            color: configurations.sectionDividerColor,
            space: configurations.sectionDividerSpace,
          ));

      return [
        if (configurations.showUndo)
          QuillToolbarHistoryButton(
            isUndo: true,
            options: toolbarConfigurations.buttonOptions.undoHistory,
            controller: globalController,
          ),
        if (configurations.showRedo)
          QuillToolbarHistoryButton(
            isUndo: false,
            options: toolbarConfigurations.buttonOptions.redoHistory,
            controller: globalController,
          ),
        if (configurations.showFontFamily)
          QuillToolbarFontFamilyButton(
            options: toolbarConfigurations.buttonOptions.fontFamily,
            controller: globalController,
          ),
        if (configurations.showFontSize)
          QuillToolbarFontSizeButton(
            options: toolbarConfigurations.buttonOptions.fontSize,
            controller: globalController,
          ),
        if (configurations.showBoldButton)
          QuillToolbarToggleStyleButton(
            attribute: Attribute.bold,
            options: toolbarConfigurations.buttonOptions.bold,
            controller: globalController,
          ),
        if (configurations.showItalicButton)
          QuillToolbarToggleStyleButton(
            attribute: Attribute.italic,
            options: toolbarConfigurations.buttonOptions.italic,
            controller: globalController,
          ),
        if (configurations.showUnderLineButton)
          QuillToolbarToggleStyleButton(
            attribute: Attribute.underline,
            options: toolbarConfigurations.buttonOptions.underLine,
            controller: globalController,
          ),
        if (configurations.showStrikeThrough)
          QuillToolbarToggleStyleButton(
            attribute: Attribute.strikeThrough,
            options: toolbarConfigurations.buttonOptions.strikeThrough,
            controller: globalController,
          ),
        if (configurations.showInlineCode)
          QuillToolbarToggleStyleButton(
            attribute: Attribute.inlineCode,
            options: toolbarConfigurations.buttonOptions.inlineCode,
            controller: globalController,
          ),
        if (configurations.showSubscript)
          QuillToolbarToggleStyleButton(
            attribute: Attribute.subscript,
            options: toolbarConfigurations.buttonOptions.subscript,
            controller: globalController,
          ),
        if (configurations.showSuperscript)
          QuillToolbarToggleStyleButton(
            attribute: Attribute.superscript,
            options: toolbarConfigurations.buttonOptions.superscript,
            controller: globalController,
          ),
        if (configurations.showSmallButton)
          QuillToolbarToggleStyleButton(
            attribute: Attribute.small,
            options: toolbarConfigurations.buttonOptions.small,
            controller: globalController,
          ),
        if (configurations.showColorButton)
          QuillToolbarColorButton(
            controller: globalController,
            isBackground: false,
            options: toolbarConfigurations.buttonOptions.color,
          ),
        if (configurations.showBackgroundColorButton)
          QuillToolbarColorButton(
            options: toolbarConfigurations.buttonOptions.backgroundColor,
            controller: globalController,
            isBackground: true,
          ),
        if (configurations.showClearFormat)
          QuillToolbarClearFormatButton(
            controller: globalController,
            options: toolbarConfigurations.buttonOptions.clearFormat,
          ),
        if (theEmbedButtons != null)
          for (final builder in theEmbedButtons)
            builder(
                globalController,
                globalIconSize ?? kDefaultIconSize,
                context.quillToolbarBaseButtonOptions?.iconTheme,
                configurations.dialogTheme),
        if (configurations.showDividers &&
            isButtonGroupShown[0] &&
            (isButtonGroupShown[1] ||
                isButtonGroupShown[2] ||
                isButtonGroupShown[3] ||
                isButtonGroupShown[4] ||
                isButtonGroupShown[5]))
          divider,
        if (configurations.showAlignmentButtons)
          QuillToolbarSelectAlignmentButtons(
            controller: globalController,
            options: toolbarConfigurations.buttonOptions.selectAlignmentButtons
                .copyWith(
              showLeftAlignment: configurations.showLeftAlignment,
              showCenterAlignment: configurations.showCenterAlignment,
              showRightAlignment: configurations.showRightAlignment,
              showJustifyAlignment: configurations.showJustifyAlignment,
            ),
          ),
        if (configurations.showDirection)
          QuillToolbarToggleStyleButton(
            attribute: Attribute.rtl,
            options: toolbarConfigurations.buttonOptions.direction,
            controller: globalController,
          ),
        if (configurations.showDividers &&
            isButtonGroupShown[1] &&
            (isButtonGroupShown[2] ||
                isButtonGroupShown[3] ||
                isButtonGroupShown[4] ||
                isButtonGroupShown[5]))
          divider,
        if (configurations.showHeaderStyle) ...[
          if (configurations.headerStyleType.isOriginal)
            QuillToolbarSelectHeaderStyleDropdownButton(
              controller: globalController,
              options: toolbarConfigurations
                  .buttonOptions.selectHeaderStyleDropdownButton,
            )
          else
            QuillToolbarSelectHeaderStyleButtons(
              controller: globalController,
              options:
                  toolbarConfigurations.buttonOptions.selectHeaderStyleButtons,
            ),
        ],
        if (configurations.showDividers &&
            configurations.showHeaderStyle &&
            isButtonGroupShown[2] &&
            (isButtonGroupShown[3] ||
                isButtonGroupShown[4] ||
                isButtonGroupShown[5]))
          divider,
        if (configurations.showListNumbers)
          QuillToolbarToggleStyleButton(
            attribute: Attribute.ol,
            options: toolbarConfigurations.buttonOptions.listNumbers,
            controller: globalController,
          ),
        if (configurations.showListBullets)
          QuillToolbarToggleStyleButton(
            attribute: Attribute.ul,
            options: toolbarConfigurations.buttonOptions.listBullets,
            controller: globalController,
          ),
        if (configurations.showListCheck)
          QuillToolbarToggleCheckListButton(
            options: toolbarConfigurations.buttonOptions.toggleCheckList,
            controller: globalController,
          ),
        if (configurations.showCodeBlock)
          QuillToolbarToggleStyleButton(
            attribute: Attribute.codeBlock,
            options: toolbarConfigurations.buttonOptions.codeBlock,
            controller: globalController,
          ),
        if (configurations.showDividers &&
            isButtonGroupShown[3] &&
            (isButtonGroupShown[4] || isButtonGroupShown[5])) ...[
          divider,
        ],
        if (configurations.showQuote)
          QuillToolbarToggleStyleButton(
            options: toolbarConfigurations.buttonOptions.quote,
            controller: globalController,
            attribute: Attribute.blockQuote,
          ),
        if (configurations.showIndent)
          QuillToolbarIndentButton(
            controller: globalController,
            isIncrease: true,
            options: toolbarConfigurations.buttonOptions.indentIncrease,
          ),
        if (configurations.showIndent)
          QuillToolbarIndentButton(
            controller: globalController,
            isIncrease: false,
            options: toolbarConfigurations.buttonOptions.indentDecrease,
          ),
        if (configurations.showDividers &&
            isButtonGroupShown[4] &&
            isButtonGroupShown[5])
          divider,
        if (configurations.showLink)
          toolbarConfigurations.linkStyleType.isOriginal
              ? QuillToolbarLinkStyleButton(
                  controller: globalController,
                  options: toolbarConfigurations.buttonOptions.linkStyle,
                )
              : QuillToolbarLinkStyleButton2(
                  controller: globalController,
                  options: toolbarConfigurations.buttonOptions.linkStyle2,
                ),
        if (configurations.showSearchButton)
          QuillToolbarSearchButton(
            controller: globalController,
            options: toolbarConfigurations.buttonOptions.search,
          ),
        if (configurations.showClipboardCut)
          QuillToolbarClipboardButton(
            options: toolbarConfigurations.buttonOptions.clipboardCut,
            controller: globalController,
            clipboardAction: ClipboardAction.cut,
          ),
        if (configurations.showClipboardCopy)
          QuillToolbarClipboardButton(
            options: toolbarConfigurations.buttonOptions.clipboardCopy,
            controller: globalController,
            clipboardAction: ClipboardAction.copy,
          ),
        if (configurations.showClipboardPaste)
          QuillToolbarClipboardButton(
            options: toolbarConfigurations.buttonOptions.clipboardPaste,
            controller: globalController,
            clipboardAction: ClipboardAction.paste,
          ),
        if (configurations.customButtons.isNotEmpty) ...[
          if (configurations.showDividers) divider,
          for (final customButton in configurations.customButtons)
            QuillToolbarCustomButton(
              options: customButton,
              controller: globalController,
            ),
          // if (customButton.child != null) ...[
          //   InkWell(
          //     onTap: customButton.onTap,
          //     child: customButton.child,
          //   ),
          // ] else ...[
          //   QuillToolbarCustomButton(
          //     options:
          //         toolbarConfigurations.buttonOptions.customButtons,
          //     controller: toolbarConfigurations
          //             .buttonOptions.customButtons.controller ??
          //         globalController,
          //   ),
          // ],
        ],
      ];
    }

    return QuillSimpleToolbarProvider(
      toolbarConfigurations: configurations,
      child: QuillToolbar(
        configurations: QuillToolbarConfigurations(
          buttonOptions: configurations.buttonOptions,
        ),
        child: Builder(
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
                    color:
                        configurations.color ?? Theme.of(context).canvasColor,
                  ),
              constraints: BoxConstraints.tightFor(
                height: configurations.axis == Axis.horizontal
                    ? _toolbarSize
                    : null,
                width:
                    configurations.axis == Axis.vertical ? _toolbarSize : null,
              ),
              child: QuillToolbarArrowIndicatedButtonList(
                axis: configurations.axis,
                buttons: childrenBuilder(context),
              ),
            );
          },
        ),
      ),
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
