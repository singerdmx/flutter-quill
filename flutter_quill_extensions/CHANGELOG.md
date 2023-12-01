# Changelog

All notable changes to this project will be documented in this file.

## 0.7.2
* Fix a bug when opening the link dialog for both video and image buttons
* Update `README.md`

## 0.7.1
* Update the minimum flutter version to `3.16.0`

## 0.7.0
* The `FlutterQuillLocalizations.delegate` is no longer a requirement.
* Requiring `flutter_quill` version `8.6.0` as minimum

## 0.6.11
* Support for the latest version of `flutter_quill`

## 0.6.10
* Update deprecated members from `flutter_quill`
* Update doc and `README.md`

## 0.6.9
* Remove duplicated class
* Drop the support for `QuillEditorFormulaEmbedBuilder` for now as it's not usable, we are working on providing fixes
* Fix a bug with the zoom button

## 0.6.8
* Feature: Allow the developer to override the `assetsPrefix` and the default value is `assets`, you should define this correctly if you planning on using asset images in the `QuillEditor`, take a look at the `QuillSharedExtensionsConfigurations` class for more info

## 0.6.7
* Support the new localization system of `flutter_quill`

## 0.6.6
* Add `onImageClicked` in the `QuillEditorImageEmbedConfigurations`
* Fix image resizing on mobile

## 0.6.5
* Support the new improved platform checking of `flutter_quill`
* Update the Image embed builder logic
* Fix the Save image button exception
* Feature: Image cropping for the image embed builder
* Add support for copying the image to the clipboard
* Add a new static method in `FlutterQuillEmbeds` which is `defaultEditorBuilders` for minimal configurations
* Fix the image size logic (it's still missing a lot of things but we will work on that soon)
* Fix the zoom image functionality to support different image providers
* Fix the typo in the function name `editorsWebBuilders`, now it's called `editorWebBuilders`
* Deprecated: The boolean property `forceUseMobileOptionMenuForImageClick` is now deprecated as we will not using it anymore and it will be removed in the next major release
* Update `README.md`

## 0.6.4
* Update `QuillImageUtilities`
* Add a new extension on `QuillController` to access `QuillImageUtilities` instance easier
* Support the new `iconButtonFactor` property

## 0.6.3
* Update `README.md`

## 0.6.2
* Add more default exports

## 0.6.1
* Fix a bug on the web that causing the project to not build

## 0.6.0
* This version is not stable yet as it doesn't have migration guide and missing some things we might introduce more breaking changes very soon but we decided to publish it because the latest stable version is not compatible with the latest stable version of `flutter_quill`

## 0.6.0-dev.6
* Better support for web
* Smal fixes and updates

## 0.6.0-dev.5
* Update the camera button

## 0.6.0-dev.4
* Add more exports
* Update `README.md``
* Fix save image bug
* Quick fixes

## 0.6.0-dev.3
* Disable the camera option by default on the desktop

## 0.6.0-dev.2
* Another breaking change, we will add a migration guide soon.

## 0.6.0-dev.1
* Breaking Changes, we have refactored most of the functions and it got renamed

## 0.5.1

* Provide a way to use a custom image provider for the image widgets
* Provide a way to handle different errors in image widgets
* Two bug fixes related to picking the image and capturing it using the camera
* Add support for image resizing on desktop platforms when forced using the mobile context menu
* Improve performance by reducing the number of widgets rebuilt by listening to media query for only the needed things, for example instead of using `MediaQuery.of(context).size`, now we are using `MediaQuery.sizeOf(context)`
* Fix warning "The platformViewRegistry getter is deprecated and will be removed in a future release. Please import it from dart:ui_web instead."
* Add QuillImageUtilities class
* Small improvements
* Allow to use the mobile context menu on the desktop by force using it
* Add the resizing option to the forced mobile context menu
* Add new custom style attribute for desktop and other platforms

## 0.5.0

* Migrated from `gallery_saver` to `gal` for saving images
* Added callbacks for greater control of editing images

## 0.4.1

* Updated dependencies to support image_picker 1.0

## 0.4.0

* Fix backspace around images [PR #1309](https://github.com/singerdmx/flutter-quill/pull/1309)
* Feat/link regexp [PR #1329](https://github.com/singerdmx/flutter-quill/pull/1329)

## 0.3.4

* Resolve the deprecated method used in the `video_player` package

## 0.3.3

* Fix a prototype bug that was brought by [PR #1230](https://github.com/singerdmx/flutter-quill/pull/1230#issuecomment*1560597099)

## 0.3.2

* Updated dependencies to support intl 0.18

## 0.3.1

* Image embedding tweaks
  * Add MediaButton which is intended to supersede the ImageButton and VideoButton. Only image selection is working.
  * Implement image insert for web (image as base64)

## 0.3.0

* Added support for adding custom tooltips to toolbar buttons

## 0.2.0

* Allow widgets to override widget span properties [b7951b0](https://github.com/singerdmx/flutter-quill/commit/b7951b02c9086ea42e7aad6d78e6c9b0297562e5)
* Remove tuples [3e9452e](https://github.com/singerdmx/flutter-quill/commit/3e9452e675e8734ff50364c5f7b5d34088d5ff05)
* Remove transparent color of ImageVideoUtils dialog [74544bd](https://github.com/singerdmx/flutter-quill/commit/74544bd945a9d212ca1e8d6b3053dbecee22b720)
* Migrate to `youtube_player_flutter` from `youtube_player_flutter_quill`
* Updates to formula button [5228f38](https://github.com/singerdmx/flutter-quill/commit/5228f389ba6f37d61d445cfe138c19fcf8766d71)

## 0.1.0

* Initial release
