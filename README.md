<p align="center" style="background-color:#282C34">
  <img src="https://user-images.githubusercontent.com/10923085/119221946-2de89000-baf2-11eb-8285-68168a78c658.png" width="600px">
</p>
<h1 align="center">A rich text editor for Flutter</h1>

[![MIT License][license-badge]][license-link]
[![PRs Welcome][prs-badge]][prs-link]
[![Watch on GitHub][github-watch-badge]][github-watch-link]
[![Star on GitHub][github-star-badge]][github-star-link]
[![Watch on GitHub][github-forks-badge]][github-forks-link]

[license-badge]: https://img.shields.io/github/license/singerdmx/flutter-quill.svg?style=for-the-badge
[license-link]: https://github.com/singerdmx/flutter-quill/blob/master/LICENSE
[prs-badge]: https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=for-the-badge
[prs-link]: https://github.com/singerdmx/flutter-quill/issues
[github-watch-badge]: https://img.shields.io/github/watchers/singerdmx/flutter-quill.svg?style=for-the-badge&logo=github&logoColor=ffffff
[github-watch-link]: https://github.com/singerdmx/flutter-quill/watchers
[github-star-badge]: https://img.shields.io/github/stars/singerdmx/flutter-quill.svg?style=for-the-badge&logo=github&logoColor=ffffff
[github-star-link]: https://github.com/singerdmx/flutter-quill/stargazers
[github-forks-badge]: https://img.shields.io/github/forks/singerdmx/flutter-quill.svg?style=for-the-badge&logo=github&logoColor=ffffff
[github-forks-link]: https://github.com/singerdmx/flutter-quill/network/members

---

FlutterQuill is a rich text editor and a [Quill] component for [Flutter].

This library is a WYSIWYG editor built for the modern Android, iOS, web and desktop platforms. Check out our [Youtube Playlist] or [Code Introduction] to take a detailed walkthrough of the code base. You can join our [Slack Group] for discussion.

Pub: [FlutterQuill]

## Demo

<p float="left">
  <img width="400" alt="1" src="https://user-images.githubusercontent.com/122956/103142422-9bb19c80-46b7-11eb-83e4-dd0538a9236e.png">
  <img width="400" alt="1" src="https://user-images.githubusercontent.com/122956/103142455-0531ab00-46b8-11eb-89f8-26a77de9227f.png">
</p>

<p float="left">
  <img width="400" alt="1" src="https://user-images.githubusercontent.com/122956/102963021-f28f5a00-449c-11eb-8f5f-6e9dd60844c4.png">
  <img width="400" alt="1" src="https://user-images.githubusercontent.com/122956/102977404-c9c88e00-44b7-11eb-9423-b68f3b30b0e0.png">
</p>

---

## Usage

See the `example` directory for a minimal example of how to use FlutterQuill.  You typically just need to instantiate a controller:

```dart
QuillController _controller = QuillController.basic();
```

and then embed the toolbar and the editor, within your app.  For example:

```dart
Column(
  children: [
    QuillToolbar.basic(controller: _controller),
    Expanded(
      child: Container(
        child: QuillEditor.basic(
          controller: _controller,
          readOnly: false, // true for view only mode
        ),
      ),
    )
  ],
)
```

Check out [Sample Page] for advanced usage.

## Input / Output

This library uses [Quill] as an internal data format.

* Use `_controller.document.toDelta()` to extract the deltas.
* Use `_controller.document.toPlainText()` to extract plain text.

FlutterQuill provides some JSON serialization support, so that you can save and open documents.  To save a document as JSON, do something like the following:

```dart
var json = jsonEncode(_controller.document.toDelta().toJson());
```

You can then write this to storage.

To open a FlutterQuill editor with an existing JSON representation that you've previously stored, you can do something like this:

```dart
var myJSON = jsonDecode(r'{"insert":"hello\n"}');
_controller = QuillController(
          document: Document.fromJson(myJSON),
          selection: TextSelection.collapsed(offset: 0),
        );
```

## Web

For web development, use `flutter config --enable-web` for flutter or use [ReactQuill] for React.

It is required to provide `EmbedBuilder`, e.g. [defaultEmbedBuildersWeb](https://github.com/singerdmx/flutter-quill/blob/master/example/lib/universal_ui/universal_ui.dart#L99).
Also it is required to provide `webImagePickImpl`, e.g. [Sample Page](https://github.com/singerdmx/flutter-quill/blob/master/example/lib/pages/home_page.dart#L317).

## Desktop

It is required to provide `filePickImpl` for toolbar image button, e.g. [Sample Page](https://github.com/singerdmx/flutter-quill/blob/master/example/lib/pages/home_page.dart#L297).

## Configuration

The `QuillToolbar` class lets you customize which formatting options are available.
[Sample Page] provides sample code for advanced usage and configuration.

### Font Size

Within the editor toolbar, a drop-down with font-sizing capabilities is available. This can be enabled or disabled with `showFontSize`.

When enabled, the default font-size values can be modified via _optional_ `fontSizeValues`.  `fontSizeValues` accepts a `Map<String, String>` consisting of a `String` title for the font size and a `String` value for the font size.  Example:

```dart
fontSizeValues: const {'Small': '8', 'Medium': '24.5', 'Large': '46'}
```

Font size can be cleared with a value of `0`, for example:

```dart
fontSizeValues: const {'Small': '8', 'Medium': '24.5', 'Large': '46', 'Clear': '0'}
```

### Font Family

To use your own fonts, update your [assets folder](https://github.com/singerdmx/flutter-quill/tree/master/example/assets/fonts) and pass in `fontFamilyValues`. More details at [this change](https://github.com/singerdmx/flutter-quill/commit/71d06f6b7be1b7b6dba2ea48e09fed0d7ff8bbaa), [this article](https://stackoverflow.com/questions/55075834/fontfamily-property-not-working-properly-in-flutter) and [this](https://www.flutterbeads.com/change-font-family-flutter/).

### Custom Buttons

You may add custom buttons to the _end_ of the toolbar, via the `customButtons` option, which is a `List` of `QuillCustomButton`.

To add an Icon, we should use a new QuillCustomButton class

```dart
    QuillCustomButton(
        icon:Icons.ac_unit,
        onTap: () {
          debugPrint('snowflake');
        }
    ),
```

Each `QuillCustomButton` is used as part of the `customButtons` option as follows:

```dart
QuillToolbar.basic(
   (...),
    customButtons: [
        QuillCustomButton(
            icon:Icons.ac_unit,
            onTap: () {
              debugPrint('snowflake1');
            }
        ),

        QuillCustomButton(
            icon:Icons.ac_unit,
            onTap: () {
              debugPrint('snowflake2');
            }
        ),

        QuillCustomButton(
            icon:Icons.ac_unit,
            onTap: () {
              debugPrint('snowflake3');
            }
        ),
    ]
```

## Embed Blocks

As of version 6.0, embed blocks are not provided by default as part of this package. Instead, this package provides an interface to all the user to provide there own implementations for embed blocks. Implementations for image, video and formula embed blocks is proved in a separate package [`flutter_quill_extensions`](https://pub.dev/packages/flutter_quill_extensions).

Provide a list of embed

### Using the embed blocks from `flutter_quill_extensions`

```dart
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';

QuillEditor.basic(
  controller: controller,
  embedBuilders: FlutterQuillEmbeds.builders(),
);

QuillToolbar.basic(
  controller: controller,
  embedButtons: FlutterQuillEmbeds.buttons(),
);
```

### Custom Size Image for Mobile

Define `mobileWidth`, `mobileHeight`, `mobileMargin`, `mobileAlignment` as follows:

```dart
{
      "insert": {
         "image": "https://user-images.githubusercontent.com/122956/72955931-ccc07900-3d52-11ea-89b1-d468a6e2aa2b.png"
      },
      "attributes":{
         "style":"mobileWidth: 50; mobileHeight: 50; mobileMargin: 10; mobileAlignment: topLeft"
      }
}
```

### Custom Embed Blocks

Sometimes you want to add some custom content inside your text, custom widgets inside of them. An example is adding notes to the text, or anything custom that you want to add in your text editor.

The only thing that you need is to add a `CustomBlockEmbed` and provider a builder for it to the `embedBuilders` parameter, to transform the data inside of the Custom Block into a widget!

Here is an example:

Starting with the `CustomBlockEmbed`, here we extend it and add the methods that are useful for the 'Note' widget, that will be the `Document`, used by the `flutter_quill` to render the rich text.

```dart
class NotesBlockEmbed extends CustomBlockEmbed {
  const NotesBlockEmbed(String value) : super(noteType, value);

  static const String noteType = 'notes';

  static NotesBlockEmbed fromDocument(Document document) =>
      NotesBlockEmbed(jsonEncode(document.toDelta().toJson()));

  Document get document => Document.fromJson(jsonDecode(data));
}
```

After that, we need to map this "notes" type into a widget. In that case, I used a `ListTile` with a text to show the plain text resume of the note, and the `onTap` function to edit the note.
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

And finally, we write the function to add/edit this note. The `showDialog` function shows the QuillEditor to edit the note, after the user ends the edition, we check if the document has something, and if it has, we add or edit the `NotesBlockEmbed` inside of a `BlockEmbed.custom` (this is a little detail that will not work if you don't pass the `CustomBlockEmbed` inside of a `BlockEmbed.custom`).

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
        readOnly: false,
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

And voila, we have a custom widget inside of the rich text editor!

<p float="left">
  <img width="400" alt="1" src="https://i.imgur.com/yBTPYeS.png">
</p>

> 1. For more info and a video example, see the [PR of this feature](https://github.com/singerdmx/flutter-quill/pull/877)
> 2. For more details, check out [this YouTube video](https://youtu.be/pI5p5j7cfHc)

### Translation

The package offers translations for the quill toolbar and editor, it will follow the system locale unless you set your own locale with:

```dart
QuillToolbar(locale: Locale('fr'), ...)
QuillEditor(locale: Locale('fr'), ...)
```

Currently, translations are available for these 28 locales:

* `Locale('en')`
* `Locale('ar')`
* `Locale('bn')`
* `Locale('cs')`
* `Locale('de')`
* `Locale('da')`
* `Locale('fr')`
* `Locale('he')`
* `Locale('zh', 'cn')`
* `Locale('zh', 'hk')`
* `Locale('ko')`
* `Locale('ru')`
* `Locale('es')`
* `Locale('tr')`
* `Locale('uk')`
* `Locale('ur')`
* `Locale('pt')`
* `Locale('pl')`
* `Locale('vi')`
* `Locale('id')`
* `Locale('it')`
* `Locale('ms')`
* `Locale('nl')`
* `Locale('no')`
* `Locale('fa')`
* `Locale('hi')`
* `Locale('sr')`
* `Locale('ja')`

#### Contributing to translations

The translation file is located at [toolbar.i18n.dart](lib/src/translations/toolbar.i18n.dart). Feel free to contribute your own translations, just copy the English translations map and replace the values with your translations. Then open a pull request so everyone can benefit from your translations!

## Conversion to HTML

Having your document stored in Quill Delta format is sometimes not enough. Often you'll need to convert
it to other formats such as HTML in order to publish it, or send an email. One option is to use
[vsc_quill_delta_to_html](https://pub.dev/packages/vsc_quill_delta_to_html) to convert your document
to HTML. This package has full support for all Quill operations - including images, videos, formulas,
tables, and mentions. Conversion can be performed in vanilla Dart (i.e., server-side or CLI) or in Flutter.
It is a complete Dart part of the popular and mature [quill-delta-to-html](https://www.npmjs.com/package/quill-delta-to-html)
Typescript/Javascript package.

## Testing

To aid in testing applications using the editor an extension to the flutter `WidgetTester` is provided which includes methods to simplify interacting with the editor in test cases.

Import the test utilities in your test file:

```dart
import 'package:flutter_quill/flutter_quill_test.dart';
```

and then enter text using `quillEnterText`:

```dart
await tester.quillEnterText(find.byType(QuillEditor), 'test\n');
```

## Sponsors

<a href="https://bulletjournal.us/home/index.html">
<img src=
"https://user-images.githubusercontent.com/122956/72955931-ccc07900-3d52-11ea-89b1-d468a6e2aa2b.png"
 width="150px" height="150px"></a>

[Quill]: https://quilljs.com/docs/formats
[Flutter]: https://github.com/flutter/flutter
[FlutterQuill]: https://pub.dev/packages/flutter_quill
[ReactQuill]: https://github.com/zenoamaro/react-quill
[Youtube Playlist]: https://youtube.com/playlist?list=PLbhaS_83B97vONkOAWGJrSXWX58et9zZ2
[Slack Group]: https://join.slack.com/t/bulletjournal1024/shared_invite/zt-fys7t9hi-ITVU5PGDen1rNRyCjdcQ2g
[Sample Page]: https://github.com/singerdmx/flutter-quill/blob/master/example/lib/pages/home_page.dart
[Code Introduction]: https://github.com/singerdmx/flutter-quill/blob/master/CodeIntroduction.md

<hr/>

[中文文档](./doc_cn.md)
