import 'package:flutter/material.dart';

import '../../../flutter_quill.dart';

class QuillToolbar extends StatelessWidget {
  const QuillToolbar({
    super.key,
    this.configurations = const QuillToolbarConfigurations(),
  });

  /// The configurations for the toolbar widget of flutter quill
  final QuillToolbarConfigurations configurations;

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

    return QuillToolbarProvider(
      toolbarConfigurations: configurations,
      child: QuillBaseToolbar(
        configurations: QuillBaseToolbarConfigurations(
          color: configurations.color,
          decoration: configurations.decoration,
          toolbarSectionSpacing: configurations.toolbarSectionSpacing,
          toolbarIconAlignment: configurations.toolbarIconAlignment,
          toolbarIconCrossAlignment: configurations.toolbarIconCrossAlignment,
          customButtons: configurations.customButtons,
          linkDialogAction: configurations.linkDialogAction,
          multiRowsDisplay: configurations.multiRowsDisplay,
          sectionDividerColor: configurations.sectionDividerColor,
          axis: configurations.axis,
          sectionDividerSpace: configurations.sectionDividerSpace,
          toolbarSize: configurations.toolbarSize,
          childrenBuilder: (context) {
            final controller = context.requireQuillController;

            final toolbarConfigurations =
                context.requireQuillToolbarConfigurations;

            final globalIconSize =
                toolbarConfigurations.buttonOptions.base.globalIconSize;

            final axis = toolbarConfigurations.axis;
            final globalController = context.requireQuillController;

            final spacerWidget =
                configurations.spacerWidget ?? const SizedBox.shrink();

            return [
              if (configurations.showUndo) ...[
                QuillToolbarHistoryButton(
                  options: toolbarConfigurations.buttonOptions.undoHistory,
                  controller: toolbarConfigurations
                          .buttonOptions.undoHistory.controller ??
                      globalController,
                ),
                spacerWidget,
              ],
              if (configurations.showRedo) ...[
                QuillToolbarHistoryButton(
                  options: toolbarConfigurations.buttonOptions.redoHistory,
                  controller: toolbarConfigurations
                          .buttonOptions.redoHistory.controller ??
                      globalController,
                ),
                spacerWidget,
              ],
              if (configurations.showFontFamily) ...[
                QuillToolbarFontFamilyButton(
                  options: toolbarConfigurations.buttonOptions.fontFamily,
                  controller: toolbarConfigurations
                          .buttonOptions.fontFamily.controller ??
                      globalController,
                ),
                spacerWidget,
              ],
              if (configurations.showFontSize) ...[
                QuillToolbarFontSizeButton(
                  options: toolbarConfigurations.buttonOptions.fontSize,
                  controller: toolbarConfigurations
                          .buttonOptions.fontFamily.controller ??
                      globalController,
                ),
                spacerWidget,
              ],
              if (configurations.showBoldButton) ...[
                QuillToolbarToggleStyleButton(
                  attribute: Attribute.bold,
                  options: toolbarConfigurations.buttonOptions.bold,
                  controller:
                      toolbarConfigurations.buttonOptions.bold.controller ??
                          globalController,
                ),
                spacerWidget,
              ],
              if (configurations.showSubscript) ...[
                QuillToolbarToggleStyleButton(
                  attribute: Attribute.subscript,
                  options: toolbarConfigurations.buttonOptions.subscript,
                  controller: toolbarConfigurations
                          .buttonOptions.subscript.controller ??
                      globalController,
                ),
                spacerWidget,
              ],
              if (configurations.showSuperscript) ...[
                QuillToolbarToggleStyleButton(
                  attribute: Attribute.superscript,
                  options: toolbarConfigurations.buttonOptions.superscript,
                  controller: toolbarConfigurations
                          .buttonOptions.superscript.controller ??
                      globalController,
                ),
                spacerWidget,
              ],
              if (configurations.showItalicButton) ...[
                QuillToolbarToggleStyleButton(
                  attribute: Attribute.italic,
                  options: toolbarConfigurations.buttonOptions.italic,
                  controller:
                      toolbarConfigurations.buttonOptions.italic.controller ??
                          globalController,
                ),
                spacerWidget,
              ],
              if (configurations.showSmallButton) ...[
                QuillToolbarToggleStyleButton(
                  attribute: Attribute.small,
                  options: toolbarConfigurations.buttonOptions.small,
                  controller:
                      toolbarConfigurations.buttonOptions.small.controller ??
                          globalController,
                ),
                spacerWidget,
              ],
              if (configurations.showUnderLineButton) ...[
                QuillToolbarToggleStyleButton(
                  attribute: Attribute.underline,
                  options: toolbarConfigurations.buttonOptions.underLine,
                  controller: toolbarConfigurations
                          .buttonOptions.underLine.controller ??
                      globalController,
                ),
                spacerWidget,
              ],
              if (configurations.showStrikeThrough) ...[
                QuillToolbarToggleStyleButton(
                  attribute: Attribute.strikeThrough,
                  options: toolbarConfigurations.buttonOptions.strikeThrough,
                  controller: toolbarConfigurations
                          .buttonOptions.strikeThrough.controller ??
                      globalController,
                ),
                spacerWidget,
              ],
              if (configurations.showInlineCode) ...[
                QuillToolbarToggleStyleButton(
                  attribute: Attribute.inlineCode,
                  options: toolbarConfigurations.buttonOptions.inlineCode,
                  controller: toolbarConfigurations
                          .buttonOptions.inlineCode.controller ??
                      globalController,
                ),
                spacerWidget,
              ],
              if (configurations.showColorButton) ...[
                QuillToolbarColorButton(
                  controller: controller,
                  isBackground: false,
                  options: toolbarConfigurations.buttonOptions.color,
                ),
                spacerWidget,
              ],
              if (configurations.showBackgroundColorButton) ...[
                QuillToolbarColorButton(
                  options: toolbarConfigurations.buttonOptions.backgroundColor,
                  controller: controller,
                  isBackground: true,
                ),
                spacerWidget,
              ],
              if (configurations.showClearFormat) ...[
                QuillToolbarClearFormatButton(
                  controller: controller,
                  options: toolbarConfigurations.buttonOptions.clearFormat,
                ),
                spacerWidget,
              ],
              if (theEmbedButtons != null)
                for (final builder in theEmbedButtons)
                  builder(
                      controller,
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
                QuillToolbarSelectAlignmentButton(
                  controller: controller,
                  options: toolbarConfigurations
                      .buttonOptions.selectAlignmentButtons,
                  // tooltips: Map.of(buttonTooltips)
                  //   ..removeWhere((key, value) => ![
                  //         ToolbarButtons.leftAlignment,
                  //         ToolbarButtons.centerAlignment,
                  //         ToolbarButtons.rightAlignment,
                  //         ToolbarButtons.justifyAlignment,
                  //       ].contains(key)),
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
                  controller: toolbarConfigurations
                          .buttonOptions.direction.controller ??
                      context.requireQuillController,
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
                QuillToolbarSelectHeaderStyleButtons(
                  controller: controller,
                  options: toolbarConfigurations
                      .buttonOptions.selectHeaderStyleButtons,
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
                  controller: toolbarConfigurations
                          .buttonOptions.listNumbers.controller ??
                      globalController,
                ),
                spacerWidget,
              ],
              if (configurations.showListBullets) ...[
                QuillToolbarToggleStyleButton(
                  attribute: Attribute.ul,
                  options: toolbarConfigurations.buttonOptions.listBullets,
                  controller: toolbarConfigurations
                          .buttonOptions.listBullets.controller ??
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
                  controller: toolbarConfigurations
                          .buttonOptions.codeBlock.controller ??
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
                  controller:
                      toolbarConfigurations.buttonOptions.quote.controller ??
                          globalController,
                  attribute: Attribute.blockQuote,
                ),
                spacerWidget,
              ],
              if (configurations.showIndent) ...[
                QuillToolbarIndentButton(
                  controller: toolbarConfigurations
                          .buttonOptions.indentIncrease.controller ??
                      globalController,
                  isIncrease: true,
                  options: toolbarConfigurations.buttonOptions.indentIncrease,
                ),
                spacerWidget,
              ],
              if (configurations.showIndent) ...[
                QuillToolbarIndentButton(
                  controller: toolbarConfigurations
                          .buttonOptions.indentDecrease.controller ??
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
                QuillToolbarLinkStyleButton(
                  controller: controller,
                  options: toolbarConfigurations.buttonOptions.linkStyle,
                ),
                spacerWidget,
              ],
              if (configurations.showSearchButton) ...[
                QuillToolbarSearchButton(
                  controller: controller,
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
                  if (customButton.child != null) ...[
                    InkWell(
                      onTap: customButton.onTap,
                      child: customButton.child,
                    ),
                  ] else ...[
                    CustomButton(
                      onPressed: customButton.onTap,
                      icon: customButton.iconData ??
                          context.quillToolbarBaseButtonOptions?.iconData,
                      iconColor: customButton.iconColor,
                      iconSize: customButton.iconSize ?? globalIconSize,
                      iconTheme: context
                          .requireQuillToolbarBaseButtonOptions.iconTheme,
                      afterButtonPressed: customButton.afterButtonPressed ??
                          context.quillToolbarBaseButtonOptions
                              ?.afterButtonPressed,
                      tooltip: customButton.tooltip ??
                          context.quillToolbarBaseButtonOptions?.tooltip,
                    ),
                  ],
                spacerWidget,
              ],
            ];
          },
        ),
      ),
    );
  }
}
