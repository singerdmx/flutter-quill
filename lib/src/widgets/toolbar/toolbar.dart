import 'package:flutter/material.dart';

import '../../extensions/quill_provider.dart';
import '../../l10n/extensions/localizations.dart';
import '../../models/config/toolbar/base_toolbar_configurations.dart';
import '../../models/documents/attribute.dart';
import '../utils/provider.dart';
import 'base_toolbar.dart';

class QuillToolbar extends StatelessWidget implements PreferredSizeWidget {
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
                  defaultDispalyText: context.loc.font,
                ),
                spacerWidget,
              ],
              if (configurations.showFontSize) ...[
                QuillToolbarFontSizeButton(
                  options: toolbarConfigurations.buttonOptions.fontSize,
                  controller: toolbarConfigurations
                          .buttonOptions.fontFamily.controller ??
                      globalController,
                  defaultDisplayText: context.loc.fontSize,
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
                  controller:
                      toolbarConfigurations.buttonOptions.color.controller ??
                          globalController,
                  isBackground: false,
                  options: toolbarConfigurations.buttonOptions.color,
                ),
                spacerWidget,
              ],
              if (configurations.showBackgroundColorButton) ...[
                QuillToolbarColorButton(
                  options: toolbarConfigurations.buttonOptions.backgroundColor,
                  controller:
                      toolbarConfigurations.buttonOptions.color.controller ??
                          globalController,
                  isBackground: true,
                ),
                spacerWidget,
              ],
              if (configurations.showClearFormat) ...[
                QuillToolbarClearFormatButton(
                  controller: toolbarConfigurations
                          .buttonOptions.clearFormat.controller ??
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
                QuillToolbarSelectAlignmentButton(
                  controller: toolbarConfigurations
                          .buttonOptions.selectAlignmentButtons.controller ??
                      globalController,
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
                  controller: toolbarConfigurations
                          .buttonOptions.selectHeaderStyleButtons.controller ??
                      globalController,
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
                  controller:
                      toolbarConfigurations.buttonOptions.search.controller ??
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
