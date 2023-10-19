## 0.5.1
- Provide a way to use custom image provider for the image widgets
- Provide a way to handle different errors in image widgets
- Two bug fixes related to pick the image and capture it using the camera
- Add support for image resizing on desktop platforms when forced using the mobile context menu
- Improve performance by reducing the number of widgets rebuilt by listening to media query for only the needed things, for example instead of using `MediaQuery.of(context).size`, now we are using `MediaQuery.sizeOf(context)`
- Fix warrning "The platformViewRegistry getter is deprecated and will be removed in a future release. Please import it from dart:ui_web instead."
- Add QuillImageUtilities class
- Small improvemenets
- Allow to use the mobile context menu on desktop by force using it
- Add the resizing option to the forced mobile context menu
- Add new custom style attrbuite for desktop and other platforms

## 0.5.0
- Migrated from `gallery_saver` to `gal` for saving images
- Added callbacks for greater control of editing images

## 0.4.1
- Updated dependencies to support image_picker 1.0

## 0.4.0
- Fix backspace around images [PR #1309](https://github.com/singerdmx/flutter-quill/pull/1309)
- Feat/link regexp [PR #1329](https://github.com/singerdmx/flutter-quill/pull/1329)

## 0.3.4
* Resolve deprecated method use in the `video_player` package

## 0.3.3
* Fix a prototype bug which was bring by [PR #1230](https://github.com/singerdmx/flutter-quill/pull/1230#issuecomment-1560597099)

## 0.3.2
* Updated dependencies to support intl 0.18

## 0.3.1
* Image embedding tweaks
  * Add MediaButton which is intened to superseed the ImageButton and VideoButton. Only image selection is working.
  * Implement image insert for web (image as base64)

## 0.3.0

* Added support for adding custom tooltips to toolbar buttons

## 0.2.0

* Allow widgets to override widget span properties [b7951b0](https://github.com/singerdmx/flutter-quill/commit/b7951b02c9086ea42e7aad6d78e6c9b0297562e5)
* Remove tuples [3e9452e](https://github.com/singerdmx/flutter-quill/commit/3e9452e675e8734ff50364c5f7b5d34088d5ff05)
* Remove transparent color of ImageVideoUtils dialog [74544bd](https://github.com/singerdmx/flutter-quill/commit/74544bd945a9d212ca1e8d6b3053dbecee22b720)
* Migrate to `youtube_player_flutter` from `youtube_player_flutter_quill`
* Updates to forumla button [5228f38](https://github.com/singerdmx/flutter-quill/commit/5228f389ba6f37d61d445cfe138c19fcf8766d71)

## 0.1.0

* Initial release
