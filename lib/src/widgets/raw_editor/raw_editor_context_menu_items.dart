// import 'package:flutter/widgets.dart' show TextSelectionDelegate;

// class QuillEditorTextSelectionDelegate implements TextSelectionDelegate {
//   /// Copy current selection to [Clipboard].
//   @override
//   void copySelection(SelectionChangedCause cause) {
//     controller.copiedImageUrl = null;
//     _pastePlainText = controller.getPlainText();
//     _pasteStyleAndEmbed = controller.getAllIndividualSelectionStylesAndEmbed();

//     final selection = textEditingValue.selection;
//     final text = textEditingValue.text;
//     if (selection.isCollapsed) {
//       return;
//     }
//     Clipboard.setData(ClipboardData(text: selection.textInside(text)));

//     if (cause == SelectionChangedCause.toolbar) {
//       bringIntoView(textEditingValue.selection.extent);

//       // Collapse the selection and hide the toolbar and handles.
//       userUpdateTextEditingValue(
//         TextEditingValue(
//           text: textEditingValue.text,
//           selection:
//               TextSelection.collapsed(offset: textEditingValue.selection.end),
//         ),
//         SelectionChangedCause.toolbar,
//       );
//     }
//   }

//   /// Cut current selection to [Clipboard].
//   @override
//   void cutSelection(SelectionChangedCause cause) {
//     controller.copiedImageUrl = null;
//     _pastePlainText = controller.getPlainText();
//     _pasteStyleAndEmbed = controller.getAllIndividualSelectionStylesAndEmbed();

//     if (widget.configurations.readOnly) {
//       return;
//     }
//     final selection = textEditingValue.selection;
//     final text = textEditingValue.text;
//     if (selection.isCollapsed) {
//       return;
//     }
//     Clipboard.setData(ClipboardData(text: selection.textInside(text)));
//     _replaceText(ReplaceTextIntent(textEditingValue, '', selection, cause));

//     if (cause == SelectionChangedCause.toolbar) {
//       bringIntoView(textEditingValue.selection.extent);
//       hideToolbar();
//     }
//   }

//   /// Paste text from [Clipboard].
//   @override
//   Future<void> pasteText(SelectionChangedCause cause) async {
//     if (widget.configurations.readOnly) {
//       return;
//     }

//     if (controller.copiedImageUrl != null) {
//       final index = textEditingValue.selection.baseOffset;
//       final length = textEditingValue.selection.extentOffset - index;
//       final copied = controller.copiedImageUrl!;
//       controller.replaceText(
//         index,
//         length,
//         BlockEmbed.image(copied.url),
//         null,
//       );
//       if (copied.styleString.isNotEmpty) {
//         controller.formatText(
//           getEmbedNode(controller, index + 1).offset,
//           1,
//           StyleAttribute(copied.styleString),
//         );
//       }
//       controller.copiedImageUrl = null;
//       await Clipboard.setData(
//         const ClipboardData(text: ''),
//       );
//       return;
//     }

//     final selection = textEditingValue.selection;
//     if (!selection.isValid) {
//       return;
//     }
//     // Snapshot the input before using `await`.
//     // See https://github.com/flutter/flutter/issues/11427
//     final text = await Clipboard.getData(Clipboard.kTextPlain);
//     if (text != null) {
//       _replaceText(
//         ReplaceTextIntent(
//           textEditingValue,
//           text.text!,
//           selection,
//           cause,
//         ),
//       );

//       bringIntoView(textEditingValue.selection.extent);

//       // Collapse the selection and hide the toolbar and handles.
//       userUpdateTextEditingValue(
//         TextEditingValue(
//           text: textEditingValue.text,
//           selection: TextSelection.collapsed(
//             offset: textEditingValue.selection.end,
//           ),
//         ),
//         cause,
//       );

//       return;
//     }

//     final onImagePaste = widget.configurations.onImagePaste;
//     if (onImagePaste != null) {
//       final reader = await ClipboardReader.readClipboard();
//       if (!reader.canProvide(Formats.png)) {
//         return;
//       }
//       reader.getFile(Formats.png, (value) async {
//         final image = value;

//         final imageUrl = await onImagePaste(await image.readAll());
//         if (imageUrl == null) {
//           return;
//         }

//         controller.replaceText(
//           textEditingValue.selection.end,
//           0,
//           BlockEmbed.image(imageUrl),
//           null,
//         );
//       });
//     }
//   }

//   /// Select the entire text value.
//   @override
//   void selectAll(SelectionChangedCause cause) {
//     userUpdateTextEditingValue(
//       textEditingValue.copyWith(
//         selection: TextSelection(
//             baseOffset: 0, extentOffset: textEditingValue.text.length),
//       ),
//       cause,
//     );

//     if (cause == SelectionChangedCause.toolbar) {
//       bringIntoView(textEditingValue.selection.extent);
//     }
//   }
// }
