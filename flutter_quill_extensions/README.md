# Flutter Quill Extensions

An extension for [flutter_quill](https://pub.dev/packages/flutter_quill)
to support embedding widgets images, and videos.

## 📚 Table of Contents

- [📝 About](#-about)
- [📦 Installation](#-installation)
- [🛠 Platform Setup](#-platform-setup)
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

```shell
flutter pub add flutter_quill_extensions
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

## 🛠 Platform Setup

The package uses the following plugins:

1. [`quill_native_bridge`](https://pub.dev/packages/quill_native_bridge) to save images: [Setup](https://pub.dev/packages/quill_native_bridge#-setup)
2. [`image_picker`](https://pub.dev/packages/image_picker) for picking images: [Setup](https://pub.dev/packages/image_picker#installation)
3. [`video_player`](https://pub.dev/packages/video_player) for video playback: [Setup](https://pub.dev/packages/video_player#setup)

### Loading Images from the Internet

#### Android

1. Add the necessary permissions to your `AndroidManifest.xml`. For detailed instructions, refer to
   the [Android Guide](https://developer.android.com/training/basics/network-ops/connecting)
   or [Flutter Networking](https://docs.flutter.dev/data-and-backend/networking#android). Note that internet permission
   is included by default only for debugging; you must explicitly add it for release versions.

2. To restrict image and video loading to HTTPS only, configure your app accordingly.
   If you need to support HTTP, you must adjust your app settings for release mode. Consult
   the [Android Cleartext / Plaintext HTTP](https://developer.android.com/privacy-and-security/risks/cleartext-communications)
   guide for more information.

#### macOS

Include a key in your `Info.plist` file to enable internet access.
For detailed steps, follow the instructions in
the [Flutter macOS Networking documentation](https://docs.flutter.dev/data-and-backend/networking#macos).

## 🚀 Usage

Once you follow the [Installation](#-installation) section.
Set the `embedBuilders` and `embedToolbar` params in configurations of `QuillEditor` and `QuillSimpleToolbar`.

**Quill Toolbar**:

```dart
QuillSimpleToolbar(
  config: QuillSimpleToolbarConfig(
    embedButtons: FlutterQuillEmbeds.toolbarButtons(),
  ),
),
```

**Quill Editor**:

```dart
Expanded(
  child: QuillEditor.basic(
    config: QuillEditorConfig(
      embedBuilders: kIsWeb ? FlutterQuillEmbeds.editorWebBuilders() : FlutterQuillEmbeds.editorBuilders(),
    ),
  ),
)
```

## ⚙️ Configurations

### 📦 Embed Blocks

The [flutter_quill](https://pub.dev/packages/flutter_quill) provides an interface for all the users to provide their
implementations for embed blocks.

Implementations for image, video embed blocks are provided in this package.

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

### 🖼️ Image Assets

To support loading image assets in the editor:

```dart
FlutterQuillEmbeds.editorBuilders(
    imageEmbedConfig:
        QuillEditorImageEmbedConfig(
      imageProviderBuilder: (context, imageUrl) {
        if (imageUrl.startsWith('assets/')) {
          return AssetImage(imageUrl);
        }
        return null;
      },
    ),  
)
```

Ensures to replace `assets` with your assets directory name or change the logic to fit your needs.

## 🤝 Contributing

We greatly appreciate your time and effort.

To keep the project consistent and maintainable, we have a few guidelines that we ask all contributors to follow.
These guidelines help ensure that everyone can understand and work with the code easier.

See [Contributing](../CONTRIBUTING.md) for more details.
