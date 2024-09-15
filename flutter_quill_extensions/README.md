# Flutter Quill Extensions

An extension for [flutter_quill](https://pub.dev/packages/flutter_quill)
to support embedding widgets images, formulas, videos, and tables.

> The support for tables is currently limited and underdevelopment, more changes are expected to arrive. We are actively
> working on enhancing its functionality and usability. We appreciate your feedback as it is invaluable in helping us
> refine and expand this feature.

## 📚 Table of Contents

- [📝 About](#-about)
- [📦 Installation](#-installation)
- [🛠 Platform Specific Configurations](#-platform-specific-configurations)
- [🚀 Usage](#-usage)
- [⚙️ Configurations](#-configurations)
- [🤝 Contributing](#-contributing)

## 📝 About

[`flutter_quill`](https://pub.dev/packages/flutter_quill) is a rich editor text.
It has custom embed builders that allow you to render custom widgets in the editor <br>

This is an extension to extend its functionalities by adding more features like images, videos, and more

## 📦 Installation

Follow the usage instructions of [`flutter_quill`](https://github.com/singerdmx/flutter-quill).

Add the `flutter_quill_extensions` dependency to your project:

```yaml
dependencies:
  flutter_quill_extensions: ^<latest-version-here>
```

<p align="center">OR</p>

```yaml
dependencies:
  flutter_quill_extensions:
    git:
      url: https://github.com/singerdmx/flutter-quill.git
      ref: v<latest-version-here>
      path: flutter_quill_extensions
```

## 🛠 Platform Specific Configurations

The package uses the following plugins:

1. [`gal`](https://github.com/natsuk4ze/gal) to save images.
   Ensure to follow the [Get Started](https://github.com/natsuk4ze/gal#-get-started) guide as it requires
   platform-specific setup.
2. [`image_picker`](https://pub.dev/packages/image_picker) for picking images.
   See the [Installation](https://pub.dev/packages/image_picker#installation) section.
3. [`youtube_player_flutter`](https://pub.dev/packages/youtube_player_flutter) which
   uses [`flutter_inappwebview`](https://pub.dev/packages/flutter_inappwebview) which has a requirement setup on web.
   See the [Installation - Web support](https://pub.dev/packages/flutter_inappwebview#installation---web-support).
4. [`super_clipboard`](https://pub.dev/packages/super_clipboard) which needs some setup on Android only, it's used to
   support copying images and pasting them into editor, it's also required to support rich text pasting feature on
   non-web platforms, Open the [Android Support](https://pub.dev/packages/super_clipboard#android-support) page for
   instructions.
   The `minSdkVersion` for **Android** is `23` as `super_clipboard` requires it

### Loading Images from the Internet

#### Android

1. Add the necessary permissions to your `AndroidManifest.xml`. For detailed instructions, refer to
   the [Android Guide](https://developer.android.com/training/basics/network-ops/connecting)
   or [Flutter Networking](https://docs.flutter.dev/data-and-backend/networking#android). Note that internet permission
   is included by default only for debugging; you must explicitly add it for release versions.

2. To restrict image and video loading to HTTPS only, configure your app accordingly.
   If you need to support HTTP, you must adjust your app settings for release mode. Consult
   the [Android Cleartext / Plaintext HTTP](https://developer.android.com/privacy-and-security/risks/cleartext-communications)
   guide
   for more information.

#### macOS

Include a key in your `Info.plist` file to enable internet access.
For detailed steps, follow the instructions in
the [Flutter macOS Networking documentation](https://docs.flutter.dev/data-and-backend/networking#macos).

## 🚀 Usage

Once you follow the [Installation](#-installation) section.
Set the `embedBuilders` and `embedToolbar` params in configurations of `QuillEditor` and `QuillToolbar`.

**Quill Toolbar**:

```dart
QuillToolbar.simple(
  configurations: QuillSimpleToolbarConfigurations(
    embedButtons: FlutterQuillEmbeds.toolbarButtons(),
  ),
),
```

**Quill Editor**:

```dart
Expanded(
  child: QuillEditor.basic(
    configurations: QuillEditorConfigurations(
      embedBuilders: kIsWeb ? FlutterQuillEmbeds.editorWebBuilders() : FlutterQuillEmbeds.editorBuilders(),
    ),
  ),
)
```

## ⚙️ Configurations

### 📦 Embed Blocks

[Flutter_quill](https://pub.dev/packages/flutter_quill) provides an interface for all the users to provide their
implementations for embed blocks.
Implementations for image, video, and formula embed blocks are proved in this package.

The instructions for using the embed blocks are in the [Usage](#-usage) section.

### 🔍 Element properties

Currently, the library has limited support for the image and video properties,
and it supports only `width`, `height`, `margin`

```json
{
  "insert": {
    "image": "https://user-images.githubusercontent.com/122956/72955931-ccc07900-3d52-11ea-89b1-d468a6e2aa2b.png"
  },
  "attributes": {
    "style": "width: 50px; height: 50px; margin: 10px;"
  }
}
```

### 🔧 Custom Element properties

Doesn't apply to official Quill JS

Define flutterAlignment` as follows:

```json
{
  "insert": {
    "image": "https://user-images.githubusercontent.com/122956/72955931-ccc07900-3d52-11ea-89b1-d468a6e2aa2b.png"
  },
  "attributes": {
    "style": "flutterAlignment: topLeft"
  }
}
```

This works only for non-web platforms.

### 📝 Rich Text Paste Feature

The Rich Text Pasting feature requires native code to access
the `Clipboard` data as HTML, the plugin `super_clipboard` is required on all platforms except Web.

This package already includes `super_clipboard` and will be used internally in this package, to use it
in `flutter_quill`, call this function before using any of the widgets or functionalities:

```dart
FlutterQuillExtensions.useSuperClipboardPlugin();
```

`super_clipboard` is a comprehensive plugin that provides many clipboard features for reading and writing rich text,
images and other formats.

Calling this function will allow `flutter_quill` to use modern rich text features to paste HTML and Markdown,
support for GIF files, and other formats.

> [!IMPORTANT]
> On web platforms, you can only get the HTML from `Clipboard` on the
> `paste` event, `super_clipboard`, or any plugin is not required.
> The paste feature will not work using the standard paste hotkey logic.
> As such, you will be unable to use the **Rich Text Paste Feature** on a button or in the web app itself.
> So you might want to either display a dialog when pressing the paste button that explains the limitation and shows the
> hotkey they need to press in order to paste or develop an extension for the browser that bypasses this limitation
> similarly to **Google Docs** and provide a link to install the browser extension.
> See [Issue #1998](https://github.com/singerdmx/flutter-quill/issues/1998) for more details.

> [!NOTE]
> We're still planning on how this should be implemented in
> [Issue #1998](https://github.com/singerdmx/flutter-quill/issues/1998).

### 🖼️ Image Assets

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

This info is necessary for the package to check if its asset image to use the `AssetImage` provider.

### 🎯 Drag and drop feature

Currently, the drag-and-drop feature is not officially supported, but you can achieve this very easily in the following
steps:

1. Drag and drop require native code, you can use any Flutter plugin you like, if you want a suggestion we
   recommend [desktop_drop](https://pub.dev/packages/desktop_drop), it was originally developed for desktop.
   It has support for the web as well as Android (that is not the case for iOS)
2. Add the dependency in your `pubspec.yaml` using the following command:

    ```yaml
    flutter pub add desktop_drop
    ```
   and import it with
    ```dart
    import 'package:desktop_drop/desktop_drop.dart';
    ```
3. in the configurations of `QuillEditor`, use the `builder` to wrap the editor with `DropTarget` which comes
   from `desktop_drop`

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

## 🤝 Contributing

We greatly appreciate your time and effort.

To keep the project consistent and maintainable, we have a few guidelines that we ask all contributors to follow.
These guidelines help ensure that everyone can understand and work with the code easier.

See [Contributing](../CONTRIBUTING.md) for more details.