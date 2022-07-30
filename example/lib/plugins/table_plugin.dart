/*
 * @Author: joahyan joahyan@163.com
 * @Date: 2022-07-27 20:39:44
 * @LastEditors: joahyan joahyan@163.com
 * @LastEditTime: 2022-07-29 10:21:42
 * @FilePath: \flutter-quill\example\lib\plugins\table_plugin.dart
 * @Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
 */

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import '../annotion/plugin_annotation.dart';
import 'plugin.dart';

@PluginAnnotation(attributeName: 'tables')
class TablePlugin extends PluginRegistor {
  @override
  String get attributeName => 'tables';
  @override
  Widget buildWidget(
    BuildContext context,
    QuillController controller,
    CustomBlockEmbed block,
    bool readOnly,
  ) {
    return Container(
      //表格边框样式
      padding: EdgeInsets.only(top: 10, left: 20, right: 20),
      child: Table(
        border: TableBorder.all(
          color: Colors.black,
          width: 1.0,
          style: BorderStyle.solid,
        ),
        defaultColumnWidth: FixedColumnWidth(100.0),
        children: [
          TableRow(children: [
            TextField(),
            TextField(),
          ])
        ],
      ),
    );
  }

  @override
  void initFunction(
    BuildContext context,
    QuillController controller, {
    Document? document,
  }) {
    final quillEditorController = QuillController(
      document: document ?? Document(),
      selection: const TextSelection.collapsed(offset: 0),
    );
    final block = BlockEmbed.custom(
      TableBlockEmbed.fromDocument(quillEditorController.document),
    );
    final index = controller.selection.baseOffset;
    final length = controller.selection.extentOffset - index;

    controller.replaceText(index, length, block, null);
  }
}

class TableBlockEmbed extends CustomBlockEmbed {
  const TableBlockEmbed(String value) : super(noteType, value);

  static const String noteType = 'tables';

  static TableBlockEmbed fromDocument(Document document) =>
      TableBlockEmbed(jsonEncode(document.toDelta().toJson()));

  Document get document => Document.fromJson(jsonDecode(data));
}
