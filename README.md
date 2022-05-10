<p align="center">
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


FlutterQuill is a rich text editor and a [Quill] component for [Flutter].

This library is a WYSIWYG editor built for the modern mobile platform, with web compatibility under development. Check out our [Youtube Playlist] to take a detailed walkthrough of the code base. You can join our [Slack Group] for discussion.

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

### Font Size
Within the editor toolbar, a drop-down with font-sizing capabilties is available.  This can be enabled or disabled with `showFontSize`.  

When enabled, the default font-size values can be modified via _optional_ `fontSizeValues`.  `fontSizeValues` accepts a `Map<String, int>` consisting of a `String` title for the font size and an `int` value for the font size.  Example:
```
fontSizeValues: const {'Small':8, 'Medium':24, 'Large':46}
```
If a font size of `0` is used, then font sizing is removed from the given block of text.
```
fontSizeValues: const {'Default':0, 'Small':8, 'Medium':24, 'Large':46}
```

The initial value for font-size in the editor can also be defined via _optional_ `initialFontSizeValue` which corresponds to the index value within your map.  For example, if you would like the Medium font size to be the default start size in the above example, you would set `initialFontSizeValue: 2`.  

This initial font size is not applied to the delta when first building the widget, it is only used to change the initial value for the drop-down widget.

### Custom Icons
You may add custom icons to the _end_ of the toolbar, via the `customIcons` option, which is a `List` of `QuillCustomIcon`.

To add an Icon, we should use a new QuillCustomIcon class
```
                                QuillCustomIcon(
                                    icon:Icons.ac_unit,
                                    onTap: (){
                                      debugPrint('snowflake');
                                    }
                                ),
```

Each `QuillCustomIcon` is used as part of the `customIcons` option as follows:
```
QuillToolbar.basic(
   (...),
    customIcons: [
                                QuillCustomIcon(
                                    icon:Icons.ac_unit,
                                    onTap: (){
                                      debugPrint('snowflake1');
                                    }
                                ),

                                QuillCustomIcon(
                                    icon:Icons.ac_unit,
                                    onTap: (){
                                      debugPrint('snowflake2');
                                    }
                                ),

                                QuillCustomIcon(
                                    icon:Icons.ac_unit,
                                    onTap: (){
                                      debugPrint('snowflake3');
                                    }
                                ),
    ]
```                             

## Web

For web development, use `flutter config --enable-web` for flutter or use [ReactQuill] for React.

It is required to provide `EmbedBuilder`, e.g. [defaultEmbedBuilderWeb](https://github.com/singerdmx/flutter-quill/blob/master/example/lib/universal_ui/universal_ui.dart#L28).
Also it is required to provide `webImagePickImpl`, e.g. [Sample Page](https://github.com/singerdmx/flutter-quill/blob/master/example/lib/pages/home_page.dart#L218).

## Desktop

It is required to provide `filePickImpl` for toolbar image button, e.g. [Sample Page](https://github.com/singerdmx/flutter-quill/blob/master/example/lib/pages/home_page.dart#L198).

## Custom Size Image for Mobile

Define `mobileWidth`, `mobileHeight`, `mobileMargin`, `mobileAlignment` as follows:
```
{
      "insert": {
         "image": "https://user-images.githubusercontent.com/122956/72955931-ccc07900-3d52-11ea-89b1-d468a6e2aa2b.png"
      },
      "attributes":{
         "style":"mobileWidth: 50; mobileHeight: 50; mobileMargin: 10; mobileAlignment: topLeft"
      }
}
```

## Translation
The package offers translations for the quill toolbar and editor, it will follow the system locale unless you set your own locale with:
```
QuillToolbar(locale: Locale('fr'), ...)
QuillEditor(locale: Locale('fr'), ...)
```
Currently, translations are available for these 19 locales:
* `Locale('en')`
* `Locale('ar')`
* `Locale('de')`
* `Locale('da')`
* `Locale('fr')`
* `Locale('zh', 'CN')`
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
* `Locale('no')`
* `Locale('fa')`
* `Locale('hi')`

### Contributing to translations
The translation file is located at [lib/src/translations/toolbar.i18n.dart](lib/src/translations/toolbar.i18n.dart). Feel free to contribute your own translations, just copy the English translations map and replace the values with your translations. Then open a pull request so everyone can benefit from your translations!

---

<p float="left">
  <img width="400" alt="1" src="https://user-images.githubusercontent.com/122956/103142422-9bb19c80-46b7-11eb-83e4-dd0538a9236e.png">
  <img width="400" alt="1" src="https://user-images.githubusercontent.com/122956/103142455-0531ab00-46b8-11eb-89f8-26a77de9227f.png">
</p>


<p float="left">
  <img width="400" alt="1" src="https://user-images.githubusercontent.com/122956/102963021-f28f5a00-449c-11eb-8f5f-6e9dd60844c4.png">
  <img width="400" alt="1" src="https://user-images.githubusercontent.com/122956/102977404-c9c88e00-44b7-11eb-9423-b68f3b30b0e0.png">
</p>

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
