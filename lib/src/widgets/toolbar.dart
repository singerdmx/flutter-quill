import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/documents/attribute.dart';
import 'controller.dart';
import 'toolbar/clear_format_button.dart';
import 'toolbar/color_button.dart';
import 'toolbar/history_button.dart';
import 'toolbar/image_button.dart';
import 'toolbar/indent_button.dart';
import 'toolbar/insert_embed_button.dart';
import 'toolbar/link_style_button.dart';
import 'toolbar/select_header_style_button.dart';
import 'toolbar/toggle_check_list_button.dart';
import 'toolbar/toggle_style_button.dart';

export 'toolbar/clear_format_button.dart';
export 'toolbar/color_button.dart';
export 'toolbar/history_button.dart';
export 'toolbar/image_button.dart';
export 'toolbar/indent_button.dart';
export 'toolbar/insert_embed_button.dart';
export 'toolbar/link_style_button.dart';
export 'toolbar/quill_dropdown_button.dart';
export 'toolbar/quill_icon_button.dart';
export 'toolbar/select_header_style_button.dart';
export 'toolbar/toggle_check_list_button.dart';
export 'toolbar/toggle_style_button.dart';

typedef OnImagePickCallback = Future<String> Function(File file);
typedef ImagePickImpl = Future<String?> Function(ImageSource source);

// The default size of the icon of a button.
const double kDefaultIconSize = 18;

// The factor of how much larger the button is in relation to the icon.
const double kIconButtonFactor = 1.77;

class QuillToolbar extends StatefulWidget implements PreferredSizeWidget {
  const QuillToolbar({
    required this.children,
    this.toolBarHeight = 36,
    Key? key,
  }) : super(key: key);

  factory QuillToolbar.basic({
    required QuillController controller,
    double toolbarIconSize = kDefaultIconSize,
    bool showBoldButton = true,
    bool showItalicButton = true,
    bool showUnderLineButton = true,
    bool showStrikeThrough = true,
    bool showColorButton = true,
    bool showBackgroundColorButton = true,
    bool showClearFormat = true,
    bool showHeaderStyle = true,
    bool showListNumbers = true,
    bool showListBullets = true,
    bool showListCheck = true,
    bool showCodeBlock = true,
    bool showQuote = true,
    bool showIndent = true,
    bool showLink = true,
    bool showHistory = true,
    bool showHorizontalRule = false,
    OnImagePickCallback? onImagePickCallback,
    Key? key,
  }) {
    return QuillToolbar(
        key: key,
        toolBarHeight: toolbarIconSize * 2,
        children: [
          Visibility(
            visible: showHistory,
            child: HistoryButton(
              icon: Icons.undo_outlined,
              iconSize: toolbarIconSize,
              controller: controller,
              undo: true,
            ),
          ),
          Visibility(
            visible: showHistory,
            child: HistoryButton(
              icon: Icons.redo_outlined,
              iconSize: toolbarIconSize,
              controller: controller,
              undo: false,
            ),
          ),
          const SizedBox(width: 0.6),
          Visibility(
            visible: showBoldButton,
            child: ToggleStyleButton(
              attribute: Attribute.bold,
              icon: Icons.format_bold,
              iconSize: toolbarIconSize,
              controller: controller,
            ),
          ),
          const SizedBox(width: 0.6),
          Visibility(
            visible: showItalicButton,
            child: ToggleStyleButton(
              attribute: Attribute.italic,
              icon: Icons.format_italic,
              iconSize: toolbarIconSize,
              controller: controller,
            ),
          ),
          const SizedBox(width: 0.6),
          Visibility(
            visible: showUnderLineButton,
            child: ToggleStyleButton(
              attribute: Attribute.underline,
              icon: Icons.format_underline,
              iconSize: toolbarIconSize,
              controller: controller,
            ),
          ),
          const SizedBox(width: 0.6),
          Visibility(
            visible: showStrikeThrough,
            child: ToggleStyleButton(
              attribute: Attribute.strikeThrough,
              icon: Icons.format_strikethrough,
              iconSize: toolbarIconSize,
              controller: controller,
            ),
          ),
          const SizedBox(width: 0.6),
          Visibility(
            visible: showColorButton,
            child: ColorButton(
              icon: Icons.color_lens,
              iconSize: toolbarIconSize,
              controller: controller,
              background: false,
            ),
          ),
          const SizedBox(width: 0.6),
          Visibility(
            visible: showBackgroundColorButton,
            child: ColorButton(
              icon: Icons.format_color_fill,
              iconSize: toolbarIconSize,
              controller: controller,
              background: true,
            ),
          ),
          const SizedBox(width: 0.6),
          Visibility(
            visible: showClearFormat,
            child: ClearFormatButton(
              icon: Icons.format_clear,
              iconSize: toolbarIconSize,
              controller: controller,
            ),
          ),
          const SizedBox(width: 0.6),
          Visibility(
            visible: onImagePickCallback != null,
            child: ImageButton(
              icon: Icons.image,
              iconSize: toolbarIconSize,
              controller: controller,
              imageSource: ImageSource.gallery,
              onImagePickCallback: onImagePickCallback,
            ),
          ),
          const SizedBox(width: 0.6),
          Visibility(
            visible: onImagePickCallback != null,
            child: ImageButton(
              icon: Icons.photo_camera,
              iconSize: toolbarIconSize,
              controller: controller,
              imageSource: ImageSource.camera,
              onImagePickCallback: onImagePickCallback,
            ),
          ),
          Visibility(
            visible: showHeaderStyle,
            child: VerticalDivider(
              indent: 12,
              endIndent: 12,
              color: Colors.grey.shade400,
            ),
          ),
          Visibility(
            visible: showHeaderStyle,
            child: SelectHeaderStyleButton(
              controller: controller,
              iconSize: toolbarIconSize,
            ),
          ),
          VerticalDivider(
            indent: 12,
            endIndent: 12,
            color: Colors.grey.shade400,
          ),
          Visibility(
            visible: showListNumbers,
            child: ToggleStyleButton(
              attribute: Attribute.ol,
              controller: controller,
              icon: Icons.format_list_numbered,
              iconSize: toolbarIconSize,
            ),
          ),
          Visibility(
            visible: showListBullets,
            child: ToggleStyleButton(
              attribute: Attribute.ul,
              controller: controller,
              icon: Icons.format_list_bulleted,
              iconSize: toolbarIconSize,
            ),
          ),
          Visibility(
            visible: showListCheck,
            child: ToggleCheckListButton(
              attribute: Attribute.unchecked,
              controller: controller,
              icon: Icons.check_box,
              iconSize: toolbarIconSize,
            ),
          ),
          Visibility(
            visible: showCodeBlock,
            child: ToggleStyleButton(
              attribute: Attribute.codeBlock,
              controller: controller,
              icon: Icons.code,
              iconSize: toolbarIconSize,
            ),
          ),
          Visibility(
            visible: !showListNumbers &&
                !showListBullets &&
                !showListCheck &&
                !showCodeBlock,
            child: VerticalDivider(
              indent: 12,
              endIndent: 12,
              color: Colors.grey.shade400,
            ),
          ),
          Visibility(
            visible: showQuote,
            child: ToggleStyleButton(
              attribute: Attribute.blockQuote,
              controller: controller,
              icon: Icons.format_quote,
              iconSize: toolbarIconSize,
            ),
          ),
          Visibility(
            visible: showIndent,
            child: IndentButton(
              icon: Icons.format_indent_increase,
              iconSize: toolbarIconSize,
              controller: controller,
              isIncrease: true,
            ),
          ),
          Visibility(
            visible: showIndent,
            child: IndentButton(
              icon: Icons.format_indent_decrease,
              iconSize: toolbarIconSize,
              controller: controller,
              isIncrease: false,
            ),
          ),
          Visibility(
            visible: showQuote,
            child: VerticalDivider(
              indent: 12,
              endIndent: 12,
              color: Colors.grey.shade400,
            ),
          ),
          Visibility(
            visible: showLink,
            child: LinkStyleButton(
              controller: controller,
              iconSize: toolbarIconSize,
            ),
          ),
          Visibility(
            visible: showHorizontalRule,
            child: InsertEmbedButton(
              controller: controller,
              icon: Icons.horizontal_rule,
              iconSize: toolbarIconSize,
            ),
          ),
        ]);
  }

  final List<Widget> children;
  final double toolBarHeight;

  @override
  _QuillToolbarState createState() => _QuillToolbarState();

  @override
  Size get preferredSize => Size.fromHeight(toolBarHeight);
}

class _QuillToolbarState extends State<QuillToolbar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      constraints: BoxConstraints.tightFor(height: widget.preferredSize.height),
      color: Theme.of(context).canvasColor,
      child: CustomScrollView(
        scrollDirection: Axis.horizontal,
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: widget.children,
            ),
          ),
        ],
      ),
    );
  }
}
