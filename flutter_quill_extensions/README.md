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

>
> 1. We are using the [`gal`](https://github.com/natsuk4ze/) plugin to save images.
> For this to work, you need to add the appropriate configurations
> See <https://github.com/natsuk4ze/gal#-get-started> to add the needed lines.
>
> 2. We also use [`image_picker`](https://pub.dev/packages/image_picker) plugin for picking images so please make sure to follow the instructions
>
> 3. We are using [youtube_player_flutter](https://pub.dev/packages/youtube_player_flutter) plugin which uses [flutter_inappwebview](https://pub.dev/packages/flutter_inappwebview) which has requirement on web, please follow this [link](https://pub.dev/packages/flutter_inappwebview#installation) in order to setup the support for web
> 4. For loading the image from the internet, we need the internet permission
>    1. For Android, you need to add some permissions in `AndroidManifest.xml`, Please follow this [link](https://developer.android.com/training/basics/network-ops/connecting) for more info, the internet permission is included by default only for debugging so you need to follow this link to add it in the release version too. you should allow loading images and videos only for the `https` protocol but if you want http too then you need to configure your Android application to accept `http` in the release mode, follow this [link](https://stackoverflow.com/questions/45940861/android-8-cleartext-http-traffic-not-permitted) for more info.
>    2. For macOS, you also need to include a key in your `Info.plist`, please follow this [link](https://stackoverflow.com/a/61201081/18519412) to add the required configurations
>
> The extension package also uses [image_picker](https://pub.dev/packages/image_picker) which also 
> requires some configurations, follow this [link](https://pub.dev/packages/image_picker#installation). It's needed for Android, iOS, and macOS, we must inform you that you can't pick photos using the camera on a desktop so make sure to handle that if you plan on adding support for the desktop, this may change in the future, and for more info follow this [link](https://pub.dev/packages/image_picker#windows-macos-and-linux) <br>
> 

## Usage

Before starting to use this package you must follow the [setup](#installation)

Set the `embedBuilders` and `embedToolbar` params in configurations of `QuillEditor` and `QuillToolbar` with the
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

## Embed Blocks

As of version [flutter_quill](https://pub.dev/packages/flutter_quill) 6.0, embed blocks are not provided by default as part of Flutter quill. Instead, it provides an interface for all the users to provide their implementations for embed blocks. Implementations for image, video, and formula embed blocks are proved in this package

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
- Has the option to use a custom image provider for the images
- Useful utilities and widgets
- Handle different errors
```

Please notice that the saving image functionality is not supported on Linux yet.

## Contributing

We welcome contributions!

Please follow these guidelines when contributing to our project. See [CONTRIBUTING.md](../CONTRIBUTING.md) for more details.

## Acknowledgments

- Thanks to the [Flutter Team](https://flutter.dev/)
- Thanks to [flutter_quill](https://pub.dev/packages/flutter_quill)
