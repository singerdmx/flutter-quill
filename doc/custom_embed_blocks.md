# Custom Embed Blocks

Sometimes you want to add some custom content inside your text, custom widgets inside them.
An example is adding
notes to the text, or anything custom that you want to add in your text editor.

The only thing that you need is to add a `CustomBlockEmbed` and provide a builder for it to the `embedBuilders`
parameter, to transform the data inside the Custom Block into a widget!

Here is an example:

Starting with the `CustomBlockEmbed`, here we extend it and add the methods that are useful for the 'Note' widget, which
will be the `Document`, used by the `flutter_quill` to render the rich text.

```dart
class NotesBlockEmbed extends CustomBlockEmbed {
  const NotesBlockEmbed(String value) : super(noteType, value);

  static const String noteType = 'notes';

  static NotesBlockEmbed fromDocument(Document document) =>
      NotesBlockEmbed(jsonEncode(document.toDelta().toJson()));

  Document get document => Document.fromJson(jsonDecode(data));
}
```

After that, we need to map this "notes" type into a widget. In that case, I used a `ListTile` with a text to show the
plain text resume of the note, and the `onTap` function to edit the note.
Don't forget to add this method to the `QuillEditor` after that!

```dart
class NotesEmbedBuilder extends EmbedBuilder {
  NotesEmbedBuilder({required this.addEditNote});

  Future<void> Function(BuildContext context, {Document? document}) addEditNote;

  @override
  String get key => 'notes';

  @override
  Widget build(
    BuildContext context,
    QuillController controller,
    Embed node,
    bool readOnly,
    bool inline,
    TextStyle textStyle,
  ) {
    final notes = NotesBlockEmbed(node.value.data).document;

    return Material(
      color: Colors.transparent,
      child: ListTile(
        title: Text(
          notes.toPlainText().replaceAll('\n', ' '),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
        leading: const Icon(Icons.notes),
        onTap: () => addEditNote(context, document: notes),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: Colors.grey),
        ),
      ),
    );
  }
}
```

And finally, we write the function to add/edit this note.
The `showDialog` function shows the QuillEditor to edit the
note after the user ends the edition, we check if the document has something, and if it has, we add or edit
the `NotesBlockEmbed` inside of a `BlockEmbed.custom` (this is a little detail that will not work if you don't pass
the `CustomBlockEmbed` inside of a `BlockEmbed.custom`).

```dart
Future<void> _addEditNote(BuildContext context, {Document? document}) async {
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
        configurations: const QuillEditorConfigurations(),
      ),
    ),
  );

  if (quillEditorController.document.isEmpty()) return;

  final block = BlockEmbed.custom(
    NotesBlockEmbed.fromDocument(quillEditorController.document),
  );
  final controller = _controller!;
  final index = controller.selection.baseOffset;
  final length = controller.selection.extentOffset - index;

  if (isEditing) {
    final offset = getEmbedNode(controller, controller.selection.start).offset;
    controller.replaceText(
        offset, 1, block, TextSelection.collapsed(offset: offset));
  } else {
    controller.replaceText(index, length, block, null);
  }
}
```

And voilà, we have a custom widget inside the rich text editor!

<p float="left">
  <img width="400" alt="1" src="https://i.imgur.com/yBTPYeS.png">
</p>

> 1. For more info and a video example, see
     the [PR of this feature](https://github.com/singerdmx/flutter-quill/pull/877)
> 2. For more details, check out [this YouTube video](https://youtu.be/pI5p5j7cfHc)
