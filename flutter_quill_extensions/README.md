# Flutter Quill Extensions

A extensions for [flutter_quill](https://pub.dev/packages/flutter_quill)
to support embed widgets like image, formula, video and more.

Currently the support for **Web** is limitied.

 Check [Flutter Quill](https://github.com/singerdmx/flutter-quill) for details of use.

 ## Table of Contents

- [Flutter Quill Extensions](#flutter-quill-extensions)
  - [Table of Contents](#table-of-contents)
  - [About](#about)
  - [Installation](#installation)
  - [Platform Spesefic Configurations](#platform-spesefic-configurations)
  - [Usage](#usage)
  - [Embed Blocks](#embed-blocks)
    - [Custom Size Image for Mobile](#custom-size-image-for-mobile)
    - [Custom Size Image for other platforms (excluding web)](#custom-size-image-for-other-platforms-excluding-web)
  - [Features](#features)
  - [Contributing](#contributing)
  - [License](#license)
  - [Acknowledgments](#acknowledgments)


## About
Flutter quill is a rich editor text and it's allow you to customize a lot of things, it has custom embed builders which allow you to render custom widgets in the editor <br>
this is a extensions to extends it functionallities by adding more features like images, videos, and more

## Installation

Before start using this package, please make sure to install
[flutter_quill](https://github.com/singerdmx/flutter-quill) package first and follow it's usage instructions.

```yaml
dependencies:
  flutter_quill_extensions: ^<latest-version-here>
```

## Platform Spesefic Configurations

>
> 1. We are using [`gal`](https://github.com/natsuk4ze/) plugin to save images.
> For this to work, you need to add the appropriate permissions
> to your `Info.plist` and `AndroidManifest.xml` files.
> See <https://github.com/natsuk4ze/gal#-get-started> to add the needed lines.
>
> 2. We also use [`image_picker`](https://pub.dev/packages/image_picker) plugin for picking images so please make sure follow the instructions
>
> 3. For loading the image from the internet we need internet permission
>    1. For Android, you need to add some permissions in `AndroidManifest.xml`, Please follow this [link](https://developer.android.com/training/basics/network-ops/connecting) for more info, the internet permission included by default only for debugging so you need to follow this link to add it in the release version too. you should allow loading images and videos only for the `https` protocol but if you want http too then you need to configure your android application to accept `http` in the release mode, follow this [link](https://stackoverflow.com/questions/45940861/android-8-cleartext-http-traffic-not-permitted) for more info.
>    2. for macOS you also need to include a key in your `Info.plist`, please follow this [link](https://stackoverflow.com/a/61201081/18519412) to add the required configurations
>
> The extensions package also use [image_picker](https://pub.dev/packages/image_picker) which also require some configurations, follow this [link](https://pub.dev/packages/image_picker#installation). It's needed for Android, iOS, macOS, we must inform you that you can't pick photo using camera in desktop so make sure to handle that if you plan on add support for desktop, this may change in the future and for more info follow this [link](https://pub.dev/packages/image_picker#windows-macos-and-linux) <br>
> 

## Usage

Before starting using this package you must follow the [setup](#installation)

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
      embedBuilders: kIsWeb ? FlutterQuillEmbeds.editorsWebBuilders() : FlutterQuillEmbeds.editorBuilders(),
    ),
  ),
)
```

They both should be have a parent `QuillProvider` in the widget tree and setup properly <br>
Example:

```dart
QuillProvider(
  configurations: QuillConfigurations(
    controller: _controller,
    sharedConfigurations: const QuillSharedConfigurations(),
  ),
  child: Column(
    children: [
      QuillToolbar(
        configurations: QuillToolbarConfigurations(
          embedButtons: FlutterQuillEmbeds.toolbarButtons(
            imageButtonOptions: QuillToolbarImageButtonOptions(),
          ),
        ),
      ),
      Expanded(
        child: QuillEditor.basic(
          configurations: QuillEditorConfigurations(
            padding: const EdgeInsets.all(16),
            embedBuilders: kIsWeb ? FlutterQuillEmbeds.editorsWebBuilders() : FlutterQuillEmbeds.editorBuilders(),
          ),
        ),
      )
    ],
  ),
)
```

## Embed Blocks

As of version [flutter_quill](https://pub.dev/packages/flutter_quill) 6.0, embed blocks are not provided by default as part of Flutter quill. Instead, it provides an interface to all the user to provide there own implementations for embed blocks. Implementations for image, video and formula embed blocks is proved in this package

The instructions for using the embed blocks is in the [Usage](#usage) section

### Custom Size Image for Mobile

Define `mobileWidth`, `mobileHeight`, `mobileMargin`, `mobileAlignment` as follows:

```json
{
      "insert": {
         "image": "https://user-images.githubusercontent.com/122956/72955931-ccc07900-3d52-11ea-89b1-d468a6e2aa2b.png"
      },
      "attributes":{
         "style":"mobileWidth: 50; mobileHeight: 50; mobileMargin: 10; mobileAlignment: topLeft"
      }
}
```

### Custom Size Image for other platforms (excluding web)

Define `width`, `height`, `margin`, `alignment` as follows:

```json
{
      "insert": {
         "image": "https://user-images.githubusercontent.com/122956/72955931-ccc07900-3d52-11ea-89b1-d468a6e2aa2b.png"
      },
      "attributes": {
         "style":"width: 50; height: 50; margin: 10; alignment: topLeft"
      }
}
```

On mobile we will use `mobileWidth`, `mobileHeight`, on desktop will use `width`, `heigth`
on Web we will use the `width` and the `height` but the ones in the `attributes`
This may not clear but don't worry we will update it soon.

## Features

```markdown
## Features

- Easy to use and customizable
- Has the option to use custom image provider for the images
- Usefull utilities and widgets
- Handle different errors
```

## Contributing

We welcome contributions!

Please follow these guidelines when contributing to our project. See [CONTRIBUTING.md](./../CONTRIBUTING.md) for more details.

## License

This project is licensed under the [MIT License](LICENSE) - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Thanks to the [Flutter Team](https://flutter.dev/)
- Thanks to [flutter_quill](https://pub.dev/packages/flutter_quill)
