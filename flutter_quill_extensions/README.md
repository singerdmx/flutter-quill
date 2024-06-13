# Flutter Quill Extensions

An extensions for [flutter_quill](https://pub.dev/packages/flutter_quill)
to support embedding widgets like images, formulas, videos, and more.

 Check [Flutter Quill](https://github.com/singerdmx/flutter-quill) for details of use.

 ## Table of Contents

- [Flutter Quill Extensions](#flutter-quill-extensions)
  - [Table of Contents](#table-of-contents)
  - [About](#about)
  - [Installation](#installation)
  - [Platform Specific Configurations](#platform-specific-configurations)
  - [Usage](#usage)
  - [Configurations](#configurations)
    - [Embed Blocks](#embed-blocks)
    - [Element properties](#element-properties)
    - [Custom Element properties](#custom-element-properties)
    - [Image Assets](#image-assets)
    - [Drag and drop feature](#drag-and-drop-feature)
  - [Features](#features)
  - [Contributing](#contributing)
  - [Acknowledgments](#acknowledgments)


## About

Flutter Quill is a rich editor text. It'd allow you to customize a lot of things, 
it has custom embed builders that allow you to render custom widgets in the editor <br>
this is an extension to extend its functionalities by adding more features like images, videos, and more

## Installation

Before starting using this package, please make sure to install
[flutter_quill](https://github.com/singerdmx/flutter-quill) package first and follow 
its usage instructions.

```yaml
dependencies:
  flutter_quill_extensions: ^<latest-version-here>
```

<p align="center">OR</p>

```yaml
dependencies:
  flutter_quill_extensions:
    git: https://github.com/singerdmx/flutter-quill.git
    path: flutter_quill_extensions
```

## Platform Specific Configurations

The package use the following plugins:

1. [`gal`](https://github.com/natsuk4ze/) plugin to save images.
For this to work, you need to add the appropriate configurations
See <https://github.com/natsuk4ze/gal#-get-started> to add the needed lines.
1. [`image_picker`](https://pub.dev/packages/image_picker) plugin for picking images so please make sure to follow the instructions
2. [youtube_player_flutter](https://pub.dev/packages/youtube_player_flutter) plugin which uses [flutter_inappwebview](https://pub.dev/packages/flutter_inappwebview) which has requirement on web, please follow this [link](https://pub.dev/packages/flutter_inappwebview#installation) in order to setup the support for web
3. [image_picker](https://pub.dev/packages/image_picker) which also 
requires some configurations, follow this [link](https://pub.dev/packages/image_picker#installation). It's needed for Android, iOS, and macOS, we must inform you that you can't pick photos using the camera on a desktop so make sure to handle that if you plan on adding support for the desktop, this may change in the future, and for more info follow this [link](https://pub.dev/packages/image_picker#windows-macos-and-linux)
4. [super_clipboard](https://pub.dev/packages/super_clipboard) which needs some setup on Android only, it's used to support copying images and pasting them into editor then you must setup it, open the page in pub.dev and read the `README.md` or click on this [link](https://pub.dev/packages/super_clipboard#android-support) to get the instructions.

The minSdkVersion is `23` as `super_clipboard` requires it


> For loading the image from the internet <br> <br>
> **Android**: you need to add permissions in `AndroidManifest.xml`, Follow this [Android Guide](https://developer.android.com/training/basics/network-ops/connecting) or [Flutter Networking](https://docs.flutter.dev/data-and-backend/networking#android) for more info, the internet permission is included by default only for debugging so you need to follow this link to add it in the release version too. you should allow loading images and videos only for the `https` protocol but if you want http too then you need to configure your Android application to accept `http` in the release mode, follow this [Android Cleartext / Plaintext HTTP](https://developer.android.com/privacy-and-security/risks/cleartext) page for more info. <br> <br>
> **macOS**: you need to include a key in your `Info.plist`, follow this [link](https://docs.flutter.dev/data-and-backend/networking#macos) to add the required configurations
>

## Usage

Start using the package in 3 steps:

1. Besure to to follow the [Installation](#installation) section.
2. This package already include `super_clipboard` and will be used internally in this package, to use it in `flutter_quill`, call this function before using any of the widgets or functionalities

    ```dart
    FlutterQuillExtensions.useSuperClipboardPlugin();
    ```

    `super_clipboard` is comprehensive plugin that provide many clipboard features for reading and writing of rich text, images and other formats.

    Executing this function will allow `flutter_quill` to use modern rich text features to paste HTML and Markdown, support for Gif files, and other formats.

3. Set the `embedBuilders` and `embedToolbar` params in configurations of `QuillEditor` and `QuillToolbar` with the
    values provided by this repository.

    **Quill Toolbar**:
    ```dart
    QuillToolbar(
      configurations: QuillToolbarConfigurations(
        embedButtons: FlutterQuillEmbeds.toolbarButtons(),
      ),
    ),
    ```

    **Quill Editor**
    ```dart
    Expanded(
      child: QuillEditor.basic(
        configurations: QuillEditorConfigurations(
          embedBuilders: kIsWeb ? FlutterQuillEmbeds.editorWebBuilders() : FlutterQuillEmbeds.editorBuilders(),
        ),
      ),
    )
    ```

## Configurations

### Embed Blocks

As of version [flutter_quill](https://pub.dev/packages/flutter_quill) `6.0.x`, embed blocks are not provided by default as part of Flutter quill. Instead, it provides an interface for all the users to provide their implementations for embed blocks. Implementations for image, video, and formula embed blocks are proved in this package

The instructions for using the embed blocks are in the [Usage](#usage) section

### Element properties

Currently the library has limitied support for the image and video properties
and it supports only `width`, `height`, `margin`

```json
{
      "insert": {
         "image": "https://user-images.githubusercontent.com/122956/72955931-ccc07900-3d52-11ea-89b1-d468a6e2aa2b.png"
      },
      "attributes": {
         "style":"width: 50px; height: 50px; margin: 10px;"
      }
}
```

### Custom Element properties

Doesn't apply to official Quill JS

Define flutterAlignment` as follows:

```json
{
      "insert": {
         "image": "https://user-images.githubusercontent.com/122956/72955931-ccc07900-3d52-11ea-89b1-d468a6e2aa2b.png"
      },
      "attributes":{
         "style":"flutterAlignment: topLeft"
      }
}
```

This works for all platforms except Web

### Image Assets

If you want to use image assets in the Quill Editor, you need to make sure your assets folder is `assets` otherwise:

```dart
QuillEditor.basic(
  configurations: const QuillEditorConfigurations(
    // ...
    sharedConfigurations: QuillSharedConfigurations(
      extraConfigurations: {
        QuillSharedExtensionsConfigurations.key:
            QuillSharedExtensionsConfigurations(
          assetsPrefix: 'your-assets-folder-name', // Defaults to `assets`
        ),
      },
    ),
  ),
);
```

This info is needed by the package to check if it asset image to use the `AssetImage` provider

### Drag and drop feature
Currently, the drag-and-drop feature is not officially supported, but you can achieve this very easily in the following steps:

1. Drag and drop require native code, you can use any Flutter plugin you like, if you want a suggestion we recommend [desktop_drop](https://pub.dev/packages/desktop_drop), it was originally developed for desktop but it has support for the web as well as Android (that is not the case for iOS)
2. Add the dependency in your `pubspec.yaml` using the following command:

    ```yaml
    flutter pub add desktop_drop
    ```
    and import it with
    ```dart
    import 'package:desktop_drop/desktop_drop.dart';
    ```
3. in the configurations of `QuillEditor`, use the `builder` to wrap the editor with `DropTarget` which comes from `desktop_drop`

    ```dart
    import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
    
    QuillEditor.basic(
          configurations: QuillEditorConfigurations(
            padding: const EdgeInsets.all(16),
             builder: (context, rawEditor) {
                return DropTarget(
                  onDragDone: _onDragDone,
                  child: rawEditor,
                );
              },
            embedBuilders: kIsWeb
                ? FlutterQuillEmbeds.editorWebBuilders()
                : FlutterQuillEmbeds.editorBuilders(),
          ),
    )
    ```
4. Implement the `_onDragDone`, it depends on your use case but this is just a simple example
```dart
const List<String> imageFileExtensions = [
  '.jpeg',
  '.png',
  '.jpg',
  '.gif',
  '.webp',
  '.tif',
  '.heic'
];
OnDragDoneCallback get _onDragDone {
    return (details) {
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      final file = details.files.first;
      final isSupported =
          imageFileExtensions.any((ext) => file.name.endsWith(ext));
      if (!isSupported) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(
              'Only images are supported right now: ${file.mimeType}, ${file.name}, ${file.path}, $imageFileExtensions',
            ),
          ),
        );
        return;
      }
      // To get this extension function please import flutter_quill_extensions
      _controller.insertImageBlock(
        imageSource: file.path,
      );
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Image is inserted.'),
        ),
      );
    };
  }
```

## Features

```markdown
## Features

— Easy to use and customizable
- Rich text, images and other formats
- Useful utilities and widgets
```

## Contributing

We welcome contributions!

Please follow these guidelines when contributing to our project. See [CONTRIBUTING.md](../CONTRIBUTING.md) for more details.

## Acknowledgments

- Thanks to the [Flutter Team](https://flutter.dev/)
- Thanks to the welcoming community, the volunteers who helped along the journey, developers, contributors
  and contributors who put time and effort into everything including making all the libraries, tools, and the
  information we rely on

We are incredibly grateful to many individuals and organizations who have played a
role in the project. This includes the welcoming community, dedicated volunteers, talented developers and
contributors, and the creators of the open-source tools we rely on.
