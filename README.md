
<a href="https://bulletjournal.us/home/index.html">
<img src=  
"https://user-images.githubusercontent.com/122956/72955931-ccc07900-3d52-11ea-89b1-d468a6e2aa2b.png"  
 width="150px" height="150px"></a>  
  
# FlutterQuill  
  
FlutterQuill is a rich text editor and a [Quill] component for [Flutter]. 
  
This library is a WYSIWYG editor built for the modern mobile platform, with web compatibility under development. You can join our [Slack Group] for discussion.

Demo App: https://bulletjournal.us/home/index.html

Pub: https://pub.dev/packages/flutter_quill

## Usage 

See the `example` directory for a minimal example of how to use FlutterQuill.  You typically just need to instantiate a controller:

```
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

FlutterQuill provides some JSON serialisation support, so that you can save and open documents.  To save a document as JSON, do something like the following:

```
var json = jsonEncode(_controller.document.toDelta().toJson());
```

You can then write this to storage.

To open a FlutterQuill editor with an existing JSON representation that you've previously stored, you can do something like this:

```
var myJSON = jsonDecode(incomingJSONText);
_controller = QuillController(
          document: Document.fromJson(myJSON),
          selection: TextSelection.collapsed(offset: 0));
```

## Configuration

The `QuillToolbar` class lets you customise which formatting options are available.
[Sample Page] provides sample code for advanced usage and configuration.

## Web

For web development, use `flutter config --enable-web` for flutter and use [ReactQuill] for React.

It is required to provide EmbedBuilder, e.g. [defaultEmbedBuilderWeb](https://github.com/singerdmx/flutter-quill/blob/master/example/lib/universal_ui/universal_ui.dart#L28).

## Migrate Zefyr Data

Check out [code](https://github.com/jwehrle/zefyr_quill_convert) and [doc](https://docs.google.com/document/d/1FUSrpbarHnilb7uDN5J5DDahaI0v1RMXBjj4fFSpSuY/edit?usp=sharing).
  
---  
  
<img width="484" alt="1" src="https://user-images.githubusercontent.com/122956/103142422-9bb19c80-46b7-11eb-83e4-dd0538a9236e.png">  
<img width="484" alt="1" src="https://user-images.githubusercontent.com/122956/103142455-0531ab00-46b8-11eb-89f8-26a77de9227f.png">  
<img width="484" alt="1" src="https://user-images.githubusercontent.com/122956/102963021-f28f5a00-449c-11eb-8f5f-6e9dd60844c4.png">  
<img width="484" alt="1" src="https://user-images.githubusercontent.com/122956/102977404-c9c88e00-44b7-11eb-9423-b68f3b30b0e0.png">
  
[Quill]: https://quilljs.com/docs/formats
[Flutter]: https://github.com/flutter/flutter  
[FlutterQuill]: https://pub.dev/packages/flutter_quill  
[ReactQuill]: https://github.com/zenoamaro/react-quill  
[Slack Group]: https://join.slack.com/t/bulletjournal1024/shared_invite/zt-fys7t9hi-ITVU5PGDen1rNRyCjdcQ2g
[Sample Page]: https://github.com/singerdmx/flutter-quill/blob/master/example/lib/pages/home_page.dart
