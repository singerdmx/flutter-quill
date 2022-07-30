/*
 * @Author: joahyan joahyan@163.com
 * @Date: 2022-07-27 21:36:14
 * @LastEditors: joahyan joahyan@163.com
 * @LastEditTime: 2022-07-28 09:57:06
 * @FilePath: \flutter-quill\example\lib\plugins\notes_plugin.dart
 * @Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
 */
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' hide Text;
import '../annotion/plugin_annotation.dart';
import 'plugin.dart';

@PluginAnnotation(attributeName: 'notes')
class NotePlugin extends PluginRegistor {
  @override
  String get attributeName => 'notes';

  @override
  Widget buildWidget(
    BuildContext context,
    QuillController controller,
    CustomBlockEmbed block,
    bool readOnly,
  ) {
    final notes = NoteBlockEmbed(block.data).document;
    return Material(
      color: Colors.transparent,
      child: ListTile(
        title: Text(
          notes.toPlainText().replaceAll('\n', ' '),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
        leading: const Icon(Icons.notes),
        onTap: () => initFunction(context, controller, document: notes),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: Colors.grey),
        ),
      ),
    );
  }

  @override
  Future<void> initFunction(
    BuildContext context,
    QuillController controller, {
    Document? document,
  }) async {
    final isEditing = document != null;
    final quillEditorController = QuillController(
      document: document ?? Document(),
      selection: const TextSelection.collapsed(offset: 0),
    );
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        titlePadding: const EdgeInsets.only(left: 16, top: 8),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${isEditing ? 'Edit' : 'Add'} note'),
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close),
            )
          ],
        ),
        content: QuillEditor.basic(
          controller: quillEditorController,
          readOnly: false,
        ),
      ),
    );

    if (quillEditorController.document.isEmpty()) return;

    final block = BlockEmbed.custom(
      NoteBlockEmbed.fromDocument(quillEditorController.document),
    );
    final index = controller.selection.baseOffset;
    final length = controller.selection.extentOffset - index;

    if (isEditing) {
      final offset = getEmbedNode(controller, controller.selection.start).item1;
      controller.replaceText(
          offset, 1, block, TextSelection.collapsed(offset: offset));
    } else {
      controller.replaceText(index, length, block, null);
    }
  }
}

class NoteBlockEmbed extends CustomBlockEmbed {
  const NoteBlockEmbed(String value) : super(noteType, value);

  static const String noteType = 'notes';

  static NoteBlockEmbed fromDocument(Document document) =>
      NoteBlockEmbed(jsonEncode(document.toDelta().toJson()));

  Document get document => Document.fromJson(jsonDecode(data));
}
