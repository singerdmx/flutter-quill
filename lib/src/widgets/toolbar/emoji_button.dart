/*
 * @Author: joahyan joahyan@163.com
 * @Date: 2022-07-18 12:34:30
 * @LastEditors: joahyan joahyan@163.com
 * @LastEditTime: 2022-07-18 16:39:08
 * @FilePath: \flutter-quill\lib\src\widgets\toolbar\emoji_button.dart
 * @Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
 */


import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';

import '../../../flutter_quill.dart' hide Text;

class EmojiButton extends StatefulWidget {
  const EmojiButton({
    required this.icon,
    required this.controller,
    required this.selectEmoji,
    this.iconSize = kDefaultIconSize,
    this.iconTheme,
    Key? key,
    this.imageConfig,
  }) : super(key: key);
  final IconData icon;
  final double iconSize;
  final Function selectEmoji;
  final QuillController controller;
  final QuillIconTheme? iconTheme;
  final Config? imageConfig;

  @override
  _EmojiButtonState createState() => _EmojiButtonState();
}

class _EmojiButtonState extends State<EmojiButton> {
  Color? _iconColor;
  late ThemeData theme;

  // 默认配置
  final _config = const Config(
    columns: 10,
    emojiSizeMax: 28,
    bgColor: Color(0xffF2F2F2),
    iconColor: Colors.grey,
    iconColorSelected: Color(0xff333333),
    indicatorColor: Color(0xff333333),
    progressIndicatorColor: Color(0xff333333),
    buttonMode: ButtonMode.CUPERTINO,
    initCategory: Category.RECENT,
  );

  // emoji弹窗
  void _showEmojiDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        contentPadding: EdgeInsets.zero,
        content: SingleChildScrollView(
          child: Container(
            height: 400,
            width: 500,
            decoration: const BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
            child: Column(
              children: [
                Expanded(
                  child: EmojiPicker(
                    config: widget.imageConfig ?? _config,
                    onEmojiSelected: (category, emoji) {
                      _insertEmoji(emoji);
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 选择emoji插入至markdown
  void _insertEmoji(Emoji emoji) {
    final baseOffset = widget.controller.selection.baseOffset;
    final extentOffset = widget.controller.selection.extentOffset;
    final replaceLen = extentOffset - baseOffset;
    final selection = widget.controller.selection.copyWith(
      baseOffset: baseOffset + emoji.emoji.length,
      extentOffset: baseOffset + emoji.emoji.length,
    );

    widget.controller
        .replaceText(baseOffset, replaceLen, emoji.emoji, selection);
  }

  @override
  Widget build(BuildContext context) {
    return QuillIconButton(
      icon: Icon(widget.icon, size: widget.iconSize),
      onPressed: () {
        _showEmojiDialog();
        print('aa');
      },
    );
  }
}
