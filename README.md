# Flutter Quill

<p align="center" style="background-color:#282C34">
  <img src="https://user-images.githubusercontent.com/10923085/119221946-2de89000-baf2-11eb-8285-68168a78c658.png" width="600px" alt="Flutter Quill">
</p>
<h1 align="center">A rich text editor for Flutter</h1>

[![MIT License][license-badge]][license-link]
[![PRs Welcome][prs-badge]][prs-link]
[![Watch on GitHub][github-watch-badge]][github-watch-link]
[![Star on GitHub][github-star-badge]][github-star-link]
[![Watch on GitHub][github-forks-badge]][github-forks-link]

[license-badge]: https://img.shields.io/github/license/singerdmx/flutter-quill.svg?style=for-the-badge

[license-link]: ./LICENSE

[prs-badge]: https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=for-the-badge

[prs-link]: https://github.com/singerdmx/flutter-quill/issues

[github-watch-badge]: https://img.shields.io/github/watchers/singerdmx/flutter-quill.svg?style=for-the-badge&logo=github&logoColor=ffffff

[github-watch-link]: https://github.com/singerdmx/flutter-quill/watchers

[github-star-badge]: https://img.shields.io/github/stars/singerdmx/flutter-quill.svg?style=for-the-badge&logo=github&logoColor=ffffff

[github-star-link]: https://github.com/singerdmx/flutter-quill/stargazers

[github-forks-badge]: https://img.shields.io/github/forks/singerdmx/flutter-quill.svg?style=for-the-badge&logo=github&logoColor=ffffff

[github-forks-link]: https://github.com/singerdmx/flutter-quill/network/members

---

**Flutter Quill** is a rich text editor and a [Quill] component for [Flutter].

This library is a WYSIWYG (What You See Is What You Get) editor built
for the modern Android, iOS, web and desktop platforms.

Check out our [Youtube Playlist] or [Code Introduction](./doc/code_introduction.md)
to take a detailed walkthrough of the code base.
You can join our [Slack Group] for discussion.

<p>
  <img src="https://github.com/singerdmx/flutter-quill/blob/master/example/assets/images/screenshot_1.png?raw=true"
    alt="A screenshot of the iOS example app" height="400"/>
  &nbsp;&nbsp;&nbsp;&nbsp;
  <img src="https://github.com/singerdmx/flutter-quill/blob/master/example/assets/images/screenshot_4.png?raw=true"
   alt="A screenshot of the web example app" height="420" />
</p>

## 📚 Table of contents

- [📦 Installation](#-installation)
- [🛠 Platform Setup](#-platform-setup)
- [🚀 Usage](#-usage)
- [🔤 Input / Output](#-input--output)
- [⚙️ Configurations](#️-configurations)
- [📦 Embed Blocks](#-embed-blocks)
- [🔄 Delta Conversion](#-delta-conversion)
- [📝 Rich Text Paste](#-rich-text-paste)
- [🌐 Translation](#-translation)
- [🧪 Testing](#-testing)
- [🤝 Contributing](#-contributing)
- [📜 Acknowledgments](#-acknowledgments)

## 📦 Installation

```shell
flutter pub add flutter_quill
```

<p align="center">OR</p>

```yaml
dependencies:
  flutter_quill:
    git:
      url: https://github.com/singerdmx/flutter-quill.git
      ref: v<latest-version-here>
```

> [!TIP]
> If you're using version `10.0.0`, see [the migration guide to migrate to `11.0.0`](https://github.com/singerdmx/flutter-quill/blob/master/doc/migration/10_to_11.md).

## 🛠 Platform Setup

The `flutter_quill` package uses the following plugins:

1. [`url_launcher`](https://pub.dev/packages/url_launcher): to open links.
2. [`quill_native_bridge`](https://pub.dev/packages/quill_native_bridge): to access platform-specific APIs for the
   editor.
3. [`flutter_keyboard_visibility_temp_fork`](https://pub.dev/packages/flutter_keyboard_visibility_temp_fork) to listen for keyboard
   visibility changes.

### Android Configuration for `quill_native_bridge`

To support copying images to the clipboard to be accessed by other apps, you need to configure your Android project.
If not set up, a warning will appear in the log during debug mode only.

> [!TIP]
> This is only required on **Android** for this optional feature.
> You should be able to copy images and paste them inside the editor without any additional configuration.

**1. Update `AndroidManifest.xml`**

Open `android/app/src/main/AndroidManifest.xml` and add the following inside the `<application>` tag:

```xml
<manifest>
    <application>
        ...
        <provider
            android:name="androidx.core.content.FileProvider"
            android:authorities="${applicationId}.fileprovider"
            android:exported="false"
            android:grantUriPermissions="true" >
            <meta-data
                android:name="android.support.FILE_PROVIDER_PATHS"
                android:resource="@xml/file_paths" />
        </provider>
        ...
    </application>
</manifest>
```

**2. Create `file_paths.xml`**

Create the file `android/app/src/main/res/xml/file_paths.xml` with the following content:

```xml
<paths>
    <cache-path name="cache" path="." />
</paths>
```

> [!NOTE]
> Starting with Flutter Quill `10.8.4`, [super_clipboard](https://pub.dev/packages/super_clipboard) is no longer required in `flutter_quill` or `flutter_quill_extensions`.
> The new default is an internal plugin [`quill_native_bridge`](https://pub.dev/packages/quill_native_bridge).
> If you want to continue using `super_clipboard`, you can use the [quill_super_clipboard](https://pub.dev/packages/quill_super_clipboard) package (support may be discontinued).

## 🚀 Usage

Add the localization delegate to your app widget:

```dart
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

MaterialApp(
  localizationsDelegates: const [
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    FlutterQuillLocalizations.delegate,
  ]，
);
```

Instantiate a controller:

```dart
QuillController _controller = QuillController.basic();
```

Use the `QuillEditor` and `QuillSimpleToolbar` widgets,
and attach the `QuillController` to them:

```dart
QuillSimpleToolbar(
  controller: _controller,
  config: const QuillSimpleToolbarConfig(),
),
Expanded(
  child: QuillEditor.basic(
    controller: _controller,
    config: const QuillEditorConfig(),
  ),
)
```

Dispose of the `QuillController` in the `dispose` method:

```dart
@override
void dispose() {
  _controller.dispose();
  super.dispose();
}
```

Check out [Sample Page] for more advanced usage.

## 🔤 Input / Output

This library utilizes [Quill Delta](https://quilljs.com/docs/delta/) to represent document content.
The Delta format is a compact and versatile method for describing document changes through a series of operations that denote insertions, deletions, or formatting changes.

* Use `_controller.document.toDelta()` to extract the deltas.
* Use `_controller.document.toPlainText()` to extract plain text.

**To save the document**:

```dart
final String json = jsonEncode(_controller.document.toDelta().toJson());
// Stores the JSON Quill Delta
```

**To load the document**:

```dart
final String json = ...; // Load the previously stored JSON Quill Delta

_controller.document = Document.fromJson(jsonDecode(json));
```

**To change the read-only mode**:

```dart
_controller.readOnly = true; // Or false to allow edit
```

### 🔗 Links

- [🪶 Quill Delta](https://quilljs.com/docs/delta/)
- [📜 Quill Delta Formats](https://quilljs.com/docs/formats)

## ⚙️ Configurations

The `QuillSimpleToolbar` and `QuillEditor` widgets are both customizable.
[Sample Page] provides sample code for advanced usage and configuration.

### 🔗 Links

- [🛠️ Using Custom App Widget](./doc/configurations/using_custom_app_widget.md)
- [🌍 Localizations Setup](./doc/configurations/localizations_setup.md)
- [🔠 Font Size](./doc/configurations/font_size.md)
- [🖋 Font Family](#-font-family)
- [🔘 Custom Toolbar buttons](./doc/configurations/custom_buttons.md)
- [🔍 Search](./doc/configurations/search.md)
- [✂️ Shortcut events](./doc/customizing_shortcuts.md)
- [🎨 Custom Toolbar](./doc/custom_toolbar.md)

### 🖋 Font Family

To use your own fonts, update your [Assets](./example/assets/fonts) directory and pass in `items` to `QuillToolbarFontFamilyButton`'s options.
More details
on [this commit](https://github.com/singerdmx/flutter-quill/commit/71d06f6b7be1b7b6dba2ea48e09fed0d7ff8bbaa),
[this article](https://stackoverflow.com/questions/55075834/fontfamily-property-not-working-properly-in-flutter)
and [this](https://www.flutterbeads.com/change-font-family-flutter/).

## 📦 Embed Blocks

The `flutter_quill` package provides an interface for all the users to provide their own implementations for embed
blocks.

Refer to the [Custom Embed Blocks](./doc/custom_embed_blocks.md) for more details.

### 🛠️ Using the embed blocks from `flutter_quill_extensions`

The [`flutter_quill_extensions`][FlutterQuill Extensions]
package provide implementations for image and video embed blocks.

## 🔄 Delta Conversion

> [!CAUTION]
> Storing the **Delta** as **HTML** in the database to convert it back to **Delta** when
> loading the document is not recommended due to the structural and functional differences between HTML and Delta ([see this comment](https://github.com/slab/quill/issues/1551#issuecomment-311458570)).
> We recommend storing the **Document** as **Delta JSON**
> instead of other formats (e.g., HTML, Markdown, PDF, Microsoft Word, Google Docs, Apple Pages, XML).
>
> Converting **Delta** from/to **HTML** is not a standard feature in [Quill JS](https://github.com/slab/quill)
> or [Flutter Quill][FlutterQuill].

Available Packages for Conversion

| Package | Description |
| ------- | ----------- |
| [`vsc_quill_delta_to_html`](https://pub.dev/packages/vsc_quill_delta_to_html) | Converts **Delta** to **HTML**. |
| [`flutter_quill_delta_from_html`](https://pub.dev/packages/flutter_quill_delta_from_html) | Converts **HTML** to **Delta**. |
| [`flutter_quill_to_pdf`](https://pub.dev/packages/flutter_quill_to_pdf) | Converts **Delta** to **PDF**. |
| [`markdown_quill`](https://pub.dev/packages/markdown_quill) | Converts **Markdown** to **Delta** and vice versa. |
| [`flutter_quill_delta_easy_parser`](https://pub.dev/packages/flutter_quill_delta_easy_parser) | Converts Quill **Delta** into a simplified document format, making it easier to manage and manipulate text attributes. |

> [!TIP]
> You might want to convert between **HTML** and **Delta** for some use cases:
>
> 1. **Migration**: If you're using an existing system that stores the data in HTML and want to convert the document
     data to **Delta**.
> 2. **Sharing**: For example, if you want to share the Document **Delta** somewhere or send it as an email.
> 3. **Save as**: If your app has a feature that allows converting Documents to other formats.
> 4. **Rich text pasting**: If you copy some content from websites or apps, and want to paste it into the app.
> 5. **SEO**: In case you want to use HTML for SEO support.

## 📝 Rich Text Paste

This feature allows the user to paste the content copied from other apps into the editor as rich text.
The plugin [`quill_native_bridge`](https://pub.dev/packages/quill_native_bridge) provides access to the system Clipboard.

<p>
  <img src="https://github.com/singerdmx/flutter-quill/blob/master/example/assets/images/rich_text_paste.gif?raw=true"
    alt="An animated image of the rich text paste on macOS" width="600" />
</p>

> [!IMPORTANT]
> Currently this feature is unsupported on the web.
> See [issue #1998](https://github.com/singerdmx/flutter-quill/issues/1998) and [issue #2220](https://github.com/singerdmx/flutter-quill/issues/2220)
 for more details.

## 🌐 Translation

The package offers translations for the toolbar and editor widgets, it will follow the system locale unless you set your
own locale.

See the [translation](./doc/translation.md) page for more info.

## 🧪 Testing

Take a look at [flutter_quill_test](https://pub.dev/packages/flutter_quill_test) for testing.

Currently, the support for testing is limited.

## 🤝 Contributing

> [!IMPORTANT]
> At this time, we prioritize bug fixes and code quality improvements over new features. 
> Please refrain from submitting large changes to add new features, as they might
> not be merged, and exceptions may made.
> We encourage you to create an issue or reach out beforehand, 
> explaining your proposed changes and their rationale for a higher chance of acceptance. Thank you!

We greatly appreciate your time and effort.

To keep the project consistent and maintainable, we have a few guidelines that we ask all contributors to follow.
These guidelines help ensure that everyone can understand and work with the code easier.

See [Contributing](./CONTRIBUTING.md) for more details.

## 📜 Acknowledgments

- Special thanks to everyone who has contributed to this project...
  <br><br>
  <a href="https://github.com/singerdmx/flutter-quill/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=singerdmx/flutter-quill" alt="Contributors"/>
  </a>

    <br>

  Made with [contrib.rocks](https://contrib.rocks).

- Thanks to the welcoming community, the volunteers who helped along the journey, developers, contributors
  and contributors who put time and effort into everything including making all the libraries, tools, and the
  information we rely on
- We are incredibly grateful to many individuals and organizations who have played a
  role in the project.
  This includes the welcoming community, dedicated volunteers, talented developers and
  contributors, and the creators of the open-source tools we rely on.

[Quill]: https://quilljs.com/docs/formats

[Flutter]: https://github.com/flutter/flutter

[FlutterQuill]: https://pub.dev/packages/flutter_quill

[FlutterQuill Extensions]: https://pub.dev/packages/flutter_quill_extensions

[ReactQuill]: https://github.com/zenoamaro/react-quill

[Youtube Playlist]: https://youtube.com/playlist?list=PLbhaS_83B97vONkOAWGJrSXWX58et9zZ2

[Slack Group]: https://join.slack.com/t/bulletjournal1024/shared_invite/zt-fys7t9hi-ITVU5PGDen1rNRyCjdcQ2g

[Sample Page]: https://github.com/singerdmx/flutter-quill/blob/master/example/lib/main.dart
