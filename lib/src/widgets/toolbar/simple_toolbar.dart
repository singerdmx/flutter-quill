import 'package:flutter/material.dart';

import '../../../translations.dart';
import '../../extensions/quill_configurations_ext.dart';
import '../../models/config/toolbar/toolbar_configurations.dart';
import '../../models/documents/attribute.dart';
import '../utils/provider.dart';
import 'base_toolbar.dart';
import 'buttons/arrow_indicated_list_button.dart';
import 'buttons/select_alignment_buttons.dart';
import 'buttons/select_header_style_button.dart';

class QuillSimpleToolbar extends StatelessWidget
    implements PreferredSizeWidget {
  const QuillSimpleToolbar({
    required this.configurations,
    super.key,
  });

  /// The configurations for the toolbar widget of flutter quill
  final QuillSimpleToolbarConfigurations configurations;

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

      final globalIconSize =
          toolbarConfigurations.buttonOptions.base.globalIconSize;

      final axis = toolbarConfigurations.axis;
      final globalController = configurations.controller;

      final spacerWidget =
          configurations.spacerWidget ?? const SizedBox.shrink();

      return [
        if (configurations.showUndo) ...[
          QuillToolbarHistoryButton(
            isUndo: true,
            options: toolbarConfigurations.buttonOptions.undoHistory,
            controller:
                toolbarConfigurations.buttonOptions.undoHistory.controller ??
                    globalController,
          ),
          spacerWidget,
        ],
        if (configurations.showRedo) ...[
          QuillToolbarHistoryButton(
            isUndo: false,
            options: toolbarConfigurations.buttonOptions.redoHistory,
            controller:
                toolbarConfigurations.buttonOptions.redoHistory.controller ??
                    globalController,
          ),
          spacerWidget,
        ],
        if (configurations.showFontFamily) ...[
          QuillToolbarFontFamilyButton(
            options: toolbarConfigurations.buttonOptions.fontFamily,
            controller:
                toolbarConfigurations.buttonOptions.fontFamily.controller ??
                    globalController,
            defaultDispalyText: context.loc.font,
          ),
          spacerWidget,
        ],
        if (configurations.showFontSize) ...[
          QuillToolbarFontSizeButton(
            options: toolbarConfigurations.buttonOptions.fontSize,
            controller:
                toolbarConfigurations.buttonOptions.fontFamily.controller ??
                    globalController,
            defaultDisplayText: context.loc.fontSize,
          ),
          spacerWidget,
        ],
        if (configurations.showBoldButton) ...[
          QuillToolbarToggleStyleButton(
            attribute: Attribute.bold,
            options: toolbarConfigurations.buttonOptions.bold,
            controller: toolbarConfigurations.buttonOptions.bold.controller ??
                globalController,
          ),
          spacerWidget,
        ],
        if (configurations.showItalicButton) ...[
          QuillToolbarToggleStyleButton(
            attribute: Attribute.italic,
            options: toolbarConfigurations.buttonOptions.italic,
            controller: toolbarConfigurations.buttonOptions.italic.controller ??
                globalController,
          ),
          spacerWidget,
        ],
        if (configurations.showUnderLineButton) ...[
          QuillToolbarToggleStyleButton(
            attribute: Attribute.underline,
            options: toolbarConfigurations.buttonOptions.underLine,
            controller:
                toolbarConfigurations.buttonOptions.underLine.controller ??
                    globalController,
          ),
          spacerWidget,
        ],
        if (configurations.showInlineCode) ...[
          QuillToolbarToggleStyleButton(
            attribute: Attribute.inlineCode,
            options: toolbarConfigurations.buttonOptions.inlineCode,
            controller:
                toolbarConfigurations.buttonOptions.inlineCode.controller ??
                    globalController,
          ),
          spacerWidget,
        ],
        if (configurations.showSubscript) ...[
          QuillToolbarToggleStyleButton(
            attribute: Attribute.subscript,
            options: toolbarConfigurations.buttonOptions.subscript,
            controller:
                toolbarConfigurations.buttonOptions.subscript.controller ??
                    globalController,
          ),
          spacerWidget,
        ],
        if (configurations.showSuperscript) ...[
          QuillToolbarToggleStyleButton(
            attribute: Attribute.superscript,
            options: toolbarConfigurations.buttonOptions.superscript,
            controller:
                toolbarConfigurations.buttonOptions.superscript.controller ??
                    globalController,
          ),
          spacerWidget,
        ],
        if (configurations.showSmallButton) ...[
          QuillToolbarToggleStyleButton(
            attribute: Attribute.small,
            options: toolbarConfigurations.buttonOptions.small,
            controller: toolbarConfigurations.buttonOptions.small.controller ??
                globalController,
          ),
          spacerWidget,
        ],
        if (configurations.showStrikeThrough) ...[
          QuillToolbarToggleStyleButton(
            attribute: Attribute.strikeThrough,
            options: toolbarConfigurations.buttonOptions.strikeThrough,
            controller:
                toolbarConfigurations.buttonOptions.strikeThrough.controller ??
                    globalController,
          ),
          spacerWidget,
        ],
        if (configurations.showColorButton) ...[
          QuillToolbarColorButton(
            controller: toolbarConfigurations.buttonOptions.color.controller ??
                globalController,
            isBackground: false,
            options: toolbarConfigurations.buttonOptions.color,
          ),
          spacerWidget,
        ],
        if (configurations.showBackgroundColorButton) ...[
          QuillToolbarColorButton(
            options: toolbarConfigurations.buttonOptions.backgroundColor,
            controller: toolbarConfigurations.buttonOptions.color.controller ??
                globalController,
            isBackground: true,
          ),
          spacerWidget,
        ],
        if (configurations.showClearFormat) ...[
          QuillToolbarClearFormatButton(
            controller:
                toolbarConfigurations.buttonOptions.clearFormat.controller ??
                    globalController,
            options: toolbarConfigurations.buttonOptions.clearFormat,
          ),
          spacerWidget,
        ],
        if (theEmbedButtons != null)
          for (final builder in theEmbedButtons)
            builder(
                globalController,
                globalIconSize,
                context.requireQuillToolbarBaseButtonOptions.iconTheme,
                configurations.dialogTheme),
        if (configurations.showDividers &&
            isButtonGroupShown[0] &&
            (isButtonGroupShown[1] ||
                isButtonGroupShown[2] ||
                isButtonGroupShown[3] ||
                isButtonGroupShown[4] ||
                isButtonGroupShown[5]))
          QuillToolbarDivider(
            axis,
            color: configurations.sectionDividerColor,
            space: configurations.sectionDividerSpace,
          ),
        if (configurations.showAlignmentButtons) ...[
          QuillToolbarSelectAlignmentButtons(
            controller: toolbarConfigurations
                    .buttonOptions.selectAlignmentButtons.controller ??
                globalController,
            options: toolbarConfigurations.buttonOptions.selectAlignmentButtons,
            showLeftAlignment: configurations.showLeftAlignment,
            showCenterAlignment: configurations.showCenterAlignment,
            showRightAlignment: configurations.showRightAlignment,
            showJustifyAlignment: configurations.showJustifyAlignment,
          ),
          spacerWidget,
        ],
        if (configurations.showDirection) ...[
          QuillToolbarToggleStyleButton(
            attribute: Attribute.rtl,
            options: toolbarConfigurations.buttonOptions.direction,
            controller:
                toolbarConfigurations.buttonOptions.direction.controller ??
                    globalController,
          ),
          spacerWidget,
        ],
        if (configurations.showDividers &&
            isButtonGroupShown[1] &&
            (isButtonGroupShown[2] ||
                isButtonGroupShown[3] ||
                isButtonGroupShown[4] ||
                isButtonGroupShown[5]))
          QuillToolbarDivider(
            axis,
            color: configurations.sectionDividerColor,
            space: configurations.sectionDividerSpace,
          ),
        if (configurations.showHeaderStyle) ...[
          QuillToolbarSelectHeaderStyleButton(
            controller: toolbarConfigurations
                    .buttonOptions.selectHeaderStyleButtons.controller ??
                globalController,
            options:
                toolbarConfigurations.buttonOptions.selectHeaderStyleButtons,
          ),
          spacerWidget,
        ],
        if (configurations.showDividers &&
            configurations.showHeaderStyle &&
            isButtonGroupShown[2] &&
            (isButtonGroupShown[3] ||
                isButtonGroupShown[4] ||
                isButtonGroupShown[5]))
          QuillToolbarDivider(
            axis,
            color: configurations.sectionDividerColor,
            space: configurations.sectionDividerSpace,
          ),
        if (configurations.showListNumbers) ...[
          QuillToolbarToggleStyleButton(
            attribute: Attribute.ol,
            options: toolbarConfigurations.buttonOptions.listNumbers,
            controller:
                toolbarConfigurations.buttonOptions.listNumbers.controller ??
                    globalController,
          ),
          spacerWidget,
        ],
        if (configurations.showListBullets) ...[
          QuillToolbarToggleStyleButton(
            attribute: Attribute.ul,
            options: toolbarConfigurations.buttonOptions.listBullets,
            controller:
                toolbarConfigurations.buttonOptions.listBullets.controller ??
                    globalController,
          ),
          spacerWidget,
        ],
        if (configurations.showListCheck) ...[
          QuillToolbarToggleCheckListButton(
            options: toolbarConfigurations.buttonOptions.toggleCheckList,
            controller: toolbarConfigurations
                    .buttonOptions.toggleCheckList.controller ??
                globalController,
          ),
          spacerWidget,
        ],
        if (configurations.showCodeBlock) ...[
          QuillToolbarToggleStyleButton(
            attribute: Attribute.codeBlock,
            options: toolbarConfigurations.buttonOptions.codeBlock,
            controller:
                toolbarConfigurations.buttonOptions.codeBlock.controller ??
                    globalController,
          ),
          spacerWidget,
        ],
        if (configurations.showDividers &&
            isButtonGroupShown[3] &&
            (isButtonGroupShown[4] || isButtonGroupShown[5])) ...[
          QuillToolbarDivider(
            axis,
            color: configurations.sectionDividerColor,
            space: configurations.sectionDividerSpace,
          ),
        ],
        if (configurations.showQuote) ...[
          QuillToolbarToggleStyleButton(
            options: toolbarConfigurations.buttonOptions.quote,
            controller: toolbarConfigurations.buttonOptions.quote.controller ??
                globalController,
            attribute: Attribute.blockQuote,
          ),
          spacerWidget,
        ],
        if (configurations.showIndent) ...[
          QuillToolbarIndentButton(
            controller:
                toolbarConfigurations.buttonOptions.indentIncrease.controller ??
                    globalController,
            isIncrease: true,
            options: toolbarConfigurations.buttonOptions.indentIncrease,
          ),
          spacerWidget,
        ],
        if (configurations.showIndent) ...[
          QuillToolbarIndentButton(
            controller:
                toolbarConfigurations.buttonOptions.indentDecrease.controller ??
                    globalController,
            isIncrease: false,
            options: toolbarConfigurations.buttonOptions.indentDecrease,
          ),
          spacerWidget,
        ],
        if (configurations.showDividers &&
            isButtonGroupShown[4] &&
            isButtonGroupShown[5])
          QuillToolbarDivider(
            axis,
            color: configurations.sectionDividerColor,
            space: configurations.sectionDividerSpace,
          ),
        if (configurations.showLink) ...[
          toolbarConfigurations.linkStyleType.isOriginal
              ? QuillToolbarLinkStyleButton(
                  controller: toolbarConfigurations
                          .buttonOptions.linkStyle.controller ??
                      globalController,
                  options: toolbarConfigurations.buttonOptions.linkStyle,
                )
              : QuillToolbarLinkStyleButton2(
                  controller: toolbarConfigurations
                          .buttonOptions.linkStyle2.controller ??
                      globalController,
                  options: toolbarConfigurations.buttonOptions.linkStyle2,
                ),
          spacerWidget,
        ],
        if (configurations.showSearchButton) ...[
          QuillToolbarSearchButton(
            controller: toolbarConfigurations.buttonOptions.search.controller ??
                globalController,
            options: toolbarConfigurations.buttonOptions.search,
          ),
          spacerWidget,
        ],
        if (configurations.customButtons.isNotEmpty) ...[
          if (configurations.showDividers)
            QuillToolbarDivider(
              axis,
              color: configurations.sectionDividerColor,
              space: configurations.sectionDividerSpace,
            ),
          for (final customButton in configurations.customButtons)
            QuillToolbarCustomButton(
              options: customButton,
              controller: customButton.controller ?? globalController,
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
          spacerWidget,
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
                runSpacing: 4,
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
                    ? configurations.toolbarSize
                    : null,
                width: configurations.axis == Axis.vertical
                    ? configurations.toolbarSize
                    : null,
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
      ? const Size.fromHeight(defaultToolbarSize)
      : const Size.fromWidth(defaultToolbarSize);
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
