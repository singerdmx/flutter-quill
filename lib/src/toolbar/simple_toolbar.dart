import 'package:flutter/material.dart';

import '../controller/quill_controller.dart';
import '../document/attribute.dart';
import '../document/document.dart';
import 'base_toolbar.dart';
import 'buttons/alignment/select_alignment_buttons.dart';
import 'buttons/arrow_indicated_list_button.dart';
import 'config/toolbar_configurations.dart';
import 'simple_toolbar_provider.dart';

class QuillSimpleToolbar extends StatelessWidget
    implements PreferredSizeWidget {
  factory QuillSimpleToolbar({
    required QuillSimpleToolbarConfigurations? configurations,
    QuillController? controller,
    Key? key,
  }) {
    // ignore: deprecated_member_use_from_same_package
    controller ??= configurations?.controller;
    assert(controller != null,
        'controller required. Provide controller directly (preferred) or indirectly through configurations (not recommended - will be removed in future versions).');
    controller ??= QuillController(
        document: Document(),
        selection: const TextSelection.collapsed(offset: 0));
    //
    controller.toolbarConfigurations = configurations;
    //
    return QuillSimpleToolbar._(
      controller: controller,
      key: key,
    );
  }

  const QuillSimpleToolbar._({
    required this.controller,
    super.key,
  });

  final QuillController controller;

  /// The configurations for the toolbar widget of flutter quill
  QuillSimpleToolbarConfigurations get configurations =>
      controller.toolbarConfigurations;

  double get _toolbarSize => configurations.toolbarSize * 1.4;

  @override
  Widget build(BuildContext context) {
    final theEmbedButtons = configurations.embedButtons;

    List<Widget> childrenBuilder(BuildContext context) {
      final toolbarConfigurations =
          context.requireQuillSimpleToolbarConfigurations;

      final globalIconSize = toolbarConfigurations.buttonOptions.base.iconSize;

      final axis = toolbarConfigurations.axis;

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
              options: toolbarConfigurations.buttonOptions.undoHistory,
              controller: controller,
            ),
          if (configurations.showRedo)
            QuillToolbarHistoryButton(
              isUndo: false,
              options: toolbarConfigurations.buttonOptions.redoHistory,
              controller: controller,
            ),
          if (configurations.showFontFamily)
            QuillToolbarFontFamilyButton(
              options: toolbarConfigurations.buttonOptions.fontFamily,
              controller: controller,
            ),
          if (configurations.showFontSize)
            QuillToolbarFontSizeButton(
              options: toolbarConfigurations.buttonOptions.fontSize,
              controller: controller,
            ),
          if (configurations.showBoldButton)
            QuillToolbarToggleStyleButton(
              attribute: Attribute.bold,
              options: toolbarConfigurations.buttonOptions.bold,
              controller: controller,
            ),
          if (configurations.showItalicButton)
            QuillToolbarToggleStyleButton(
              attribute: Attribute.italic,
              options: toolbarConfigurations.buttonOptions.italic,
              controller: controller,
            ),
          if (configurations.showUnderLineButton)
            QuillToolbarToggleStyleButton(
              attribute: Attribute.underline,
              options: toolbarConfigurations.buttonOptions.underLine,
              controller: controller,
            ),
          if (configurations.showStrikeThrough)
            QuillToolbarToggleStyleButton(
              attribute: Attribute.strikeThrough,
              options: toolbarConfigurations.buttonOptions.strikeThrough,
              controller: controller,
            ),
          if (configurations.showInlineCode)
            QuillToolbarToggleStyleButton(
              attribute: Attribute.inlineCode,
              options: toolbarConfigurations.buttonOptions.inlineCode,
              controller: controller,
            ),
          if (configurations.showSubscript)
            QuillToolbarToggleStyleButton(
              attribute: Attribute.subscript,
              options: toolbarConfigurations.buttonOptions.subscript,
              controller: controller,
            ),
          if (configurations.showSuperscript)
            QuillToolbarToggleStyleButton(
              attribute: Attribute.superscript,
              options: toolbarConfigurations.buttonOptions.superscript,
              controller: controller,
            ),
          if (configurations.showSmallButton)
            QuillToolbarToggleStyleButton(
              attribute: Attribute.small,
              options: toolbarConfigurations.buttonOptions.small,
              controller: controller,
            ),
          if (configurations.showColorButton)
            QuillToolbarColorButton(
              controller: controller,
              isBackground: false,
              options: toolbarConfigurations.buttonOptions.color,
            ),
          if (configurations.showBackgroundColorButton)
            QuillToolbarColorButton(
              options: toolbarConfigurations.buttonOptions.backgroundColor,
              controller: controller,
              isBackground: true,
            ),
          if (configurations.showClearFormat)
            QuillToolbarClearFormatButton(
              controller: controller,
              options: toolbarConfigurations.buttonOptions.clearFormat,
            ),
          if (theEmbedButtons != null)
            for (final builder in theEmbedButtons)
              builder(
                  controller,
                  globalIconSize ?? kDefaultIconSize,
                  context.quillToolbarBaseButtonOptions?.iconTheme,
                  configurations.dialogTheme),
        ],
        [
          if (configurations.showAlignmentButtons)
            QuillToolbarSelectAlignmentButtons(
              controller: controller,
              options: toolbarConfigurations
                  .buttonOptions.selectAlignmentButtons
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
              controller: controller,
            ),
        ],
        [
          if (configurations.showLineHeightButton)
            QuillToolbarSelectLineHeightStyleDropdownButton(
              controller: controller,
              options: toolbarConfigurations
                  .buttonOptions.selectLineHeightStyleDropdownButton,
            ),
          if (configurations.showHeaderStyle) ...[
            if (configurations.headerStyleType.isOriginal)
              QuillToolbarSelectHeaderStyleDropdownButton(
                controller: controller,
                options: toolbarConfigurations
                    .buttonOptions.selectHeaderStyleDropdownButton,
              )
            else
              QuillToolbarSelectHeaderStyleButtons(
                controller: controller,
                options: toolbarConfigurations
                    .buttonOptions.selectHeaderStyleButtons,
              ),
          ],
        ],
        [
          if (configurations.showListNumbers)
            QuillToolbarToggleStyleButton(
              attribute: Attribute.ol,
              options: toolbarConfigurations.buttonOptions.listNumbers,
              controller: controller,
            ),
          if (configurations.showListBullets)
            QuillToolbarToggleStyleButton(
              attribute: Attribute.ul,
              options: toolbarConfigurations.buttonOptions.listBullets,
              controller: controller,
            ),
          if (configurations.showListCheck)
            QuillToolbarToggleCheckListButton(
              options: toolbarConfigurations.buttonOptions.toggleCheckList,
              controller: controller,
            ),
          if (configurations.showCodeBlock)
            QuillToolbarToggleStyleButton(
              attribute: Attribute.codeBlock,
              options: toolbarConfigurations.buttonOptions.codeBlock,
              controller: controller,
            ),
        ],
        [
          if (configurations.showQuote)
            QuillToolbarToggleStyleButton(
              options: toolbarConfigurations.buttonOptions.quote,
              controller: controller,
              attribute: Attribute.blockQuote,
            ),
          if (configurations.showIndent)
            QuillToolbarIndentButton(
              controller: controller,
              isIncrease: true,
              options: toolbarConfigurations.buttonOptions.indentIncrease,
            ),
          if (configurations.showIndent)
            QuillToolbarIndentButton(
              controller: controller,
              isIncrease: false,
              options: toolbarConfigurations.buttonOptions.indentDecrease,
            ),
        ],
        [
          if (configurations.showLink)
            toolbarConfigurations.linkStyleType.isOriginal
                ? QuillToolbarLinkStyleButton(
                    controller: controller,
                    options: toolbarConfigurations.buttonOptions.linkStyle,
                  )
                : QuillToolbarLinkStyleButton2(
                    controller: controller,
                    options: toolbarConfigurations.buttonOptions.linkStyle2,
                  ),
          if (configurations.showSearchButton)
            switch (configurations.searchButtonType) {
              SearchButtonType.legacy => QuillToolbarLegacySearchButton(
                  controller: controller,
                  options: toolbarConfigurations.buttonOptions.search,
                ),
              SearchButtonType.modern => QuillToolbarSearchButton(
                  controller: controller,
                  options: toolbarConfigurations.buttonOptions.search,
                ),
            },
          if (configurations.showClipboardCut)
            QuillToolbarClipboardButton(
              options: toolbarConfigurations.buttonOptions.clipboardCut,
              controller: controller,
              clipboardAction: ClipboardAction.cut,
            ),
          if (configurations.showClipboardCopy)
            QuillToolbarClipboardButton(
              options: toolbarConfigurations.buttonOptions.clipboardCopy,
              controller: controller,
              clipboardAction: ClipboardAction.copy,
            ),
          if (configurations.showClipboardPaste)
            QuillToolbarClipboardButton(
              options: toolbarConfigurations.buttonOptions.clipboardPaste,
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
          if (buttonsAll.isNotEmpty) {
            buttonsAll.add(divider);
          }
          buttonsAll.addAll(buttons);
        }
      }

      return buttonsAll;
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
