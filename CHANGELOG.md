# Changelog

All notable changes to this project will be documented in this file.

## 8.6.4
* The default value of `keyboardAppearance` for the iOS will be the one from the App/System theme mode instead of always using the `Brightness.light`
* Fix typos in `README.md`

## 8.6.3
* Update the minimum flutter version to `3.16.0`

## 8.6.2
* Restore use of alternative QuillToolbarLinkStyleButton2 widget 

## 8.6.1
* Temporary revert style bug fix

## 8.6.0
* **Breaking Change** Support [Flutter 3.16](https://medium.com/flutter/whats-new-in-flutter-3-16-dba6cb1015d1), please upgrade to the latest stable version of flutter to use this update
* **Breaking Change**: Remove Deprecated Fields
* **Breaking Change**: Extract the shared things between `QuillToolbarConfigurations` and `QuillBaseToolbarConfigurations`
* **Breaking Change**: You no longer need to use `QuillToolbarProvider` when using custom toolbar buttons, the example has been updated
* Bug fixes

## 8.5.5
* Now when opening dialogs by `QuillToolbar` you will not get an exception when you don't use `FlutterQuillLocalizations.delegate` in your `WidgetsApp`, `MaterialApp`, or `CupertinoApp`. The fix is for the `QuillToolbarSearchButton`, `QuillToolbarLinkStyleButton`, and `QuillToolbarColorButton` buttons

## 8.5.4
* The `mobileWidth`, `mobileHeight`, `mobileMargin`, and `mobileAlignment` is now deprecated in `flutter_quill`, they are now defined in `flutter_quill_extensions`
* Deprecate `replaceStyleStringWithSize` function which is in `string.dart`
* Deprecate `alignment`, and `margin` as they don't conform to official Quill JS

## 8.5.3
* Update doc
* Update `README.md` and `CHANGELOG.md`
* Fix typos
* Use `immutable` when possible
* Update `.pubignore`

## 8.5.2
* Updated `README.md`.
* Feature: Added the ability to include a custom callback when the `QuillToolbarColorButton` is pressed.
* The `QuillToolbar` now implements `PreferredSizeWidget`, enabling usage in the AppBar, similar to `QuillBaseToolbar`.

## 8.5.1
* Updated `README.md`.

## 8.5.0
* Migrated to `flutter_localizations` for translations.
* Fixed: Translated all previously untranslated localizations.
* Fixed: Added translations for missing items.
* Fixed: Introduced default Chinese fallback translation.
* Removed: Unused parameters `items` in `QuillToolbarFontFamilyButtonOptions` and `QuillToolbarFontSizeButtonOptions`.
* Updated: Documentation.

## 8.4.4
* Updated `.pubignore` to ignore unnecessary files and folders.

## 8.4.3
* Updated `CHANGELOG.md`.

## 8.4.2
* **Breaking change**: Configuration for `QuillRawEditor` has been moved to a separate class. Additionally, `readOnly` has been renamed to `isReadOnly`. If using `QuillEditor`, no action is required.
* Introduced the ability for developers to override `TextInputAction` in both `QuillRawEditor` and `QuillEditor`.
* Enabled using `QuillRawEditor` without `QuillEditorProvider`.
* Bug fixes.
* Added image cropping implementation in the example.

## 8.4.1
* Added `copyWith` in `OptionalSize` class.

## 8.4.0
* **Breaking change**: Updated `QuillCustomButton` to use `QuillCustomButtonOptions`. Moved all properties from `QuillCustomButton` to `QuillCustomButtonOptions`, replacing `iconData` with `icon` widget for increased customization.
* **Breaking change**: `customButtons` in `QuillToolbarConfigurations` is now of type `List<QuillToolbarCustomButtonOptions>`.
* Bug fixes following the `8.0.0` update.
* Updated `README.md`.
* Improved platform checking.

## 8.3.0
* Added `iconButtonFactor` property to `QuillToolbarBaseButtonOptions` for customizing button size relative to its icon size (defaults to `kIconButtonFactor`, consistent with previous releases).

## 8.2.6
* Organized `QuillRawEditor` code.

## 8.2.5
* Added `builder` property in `QuillEditorConfigurations`.

## 8.2.4
* Adhered to Flutter best practices.
* Fixed auto-focus bug.

## 8.2.3
* Updated `README.md`.

## 8.2.2
* Moved `flutter_quill_test` to a separate package: [flutter_quill_test](https://pub.dev/packages/flutter_quill_test).

## 8.2.1
* Updated `README.md`.

## 8.2.0
* Added the option to add configurations for `flutter_quill_extensions` using `extraConfigurations`.

## 8.1.11
* Followed Dart best practices by using `lints` and removed `pedantic` and `platform` since they are not used.
* Fixed text direction bug.
* Updated `README.md`.

## 8.1.10
* Secret for automated publishing to pub.dev.

## 8.1.9
* Fixed automated publishing to pub.dev.

## 8.1.8
* Fixed automated publishing to pub.dev.

## 8.1.7
* Automated publishing to pub.dev.

## 8.1.6
* Fixed compatibility with `integration_test` by downgrading the minimum version of the platform package to 3.1.0.

## 8.1.5
* Reversed background/font color toolbar button icons.

## 8.1.4
* Reversed background/font color toolbar button tooltips.

## 8.1.3
* Moved images to screenshots instead of `README.md`.

## 8.1.2
* Fixed a bug related to the regexp of the insert link dialog.
* Required Dart 3 as the minimum version.
* Code cleanup.
* Added a spacer widget between each button in the `QuillToolbar`.

## 8.1.1
* Fixed null error in line.dart #1487(https://github.com/singerdmx/flutter*quill/issues/1487).

## 8.1.0
* Fixed a word typo of `mirgration` to `migration` in the readme & migration document.
* Updated migration guide.
* Removed property `enableUnfocusOnTapOutside` in `QuillEditor` configurations and added `isOnTapOutsideEnabled` instead.
* Added a new callback called `onTapOutside` in the `QuillEditorConfigurations` to perform actions when tapping outside the editor.
* Fixed a bug that caused the web platform to not unfocus the editor when tapping outside of it. To override this, please pass a value to the `onTapOutside` callback.
* Removed the old property of `iconTheme`. Instead, pass `iconTheme` in the button options; you will find the `base` property inside it with `iconTheme`.

## 8.0.0
* If you have migrated recently, don't be alarmed by this update; it adds documentation, a migration guide, and marks the version as a more stable release. Although there are breaking changes (as reported by some developers), the major version was not changed due to time constraints during development. A single property was also renamed from `code` to `codeBlock` in the `elements` of the new `QuillEditorConfigurations` class.
* Updated the README for better readability.

## 7.10.2
* Removed line numbers from code blocks by default. You can still enable this feature thanks to the new configurations in the `QuillEditor`. Find the `elementOptions` property and enable `enableLineNumbers`.

## 7.10.1
* Fixed issues and utilized the new parameters.
* No longer need to use `MaterialApp` for most toolbar button child builders.
* Compatibility with [fresh_quill_extensions](https://pub.dev/packages/fresh_quill_extensions), a temporary alternative to [flutter_quill_extensions](https://pub.dev/packages/flutter_quill_extensions).
* Updated most of the documentation in `README.md`.

## 7.10.0
* **Breaking change**: `QuillToolbar.basic()` can be accessed directly from `QuillToolbar()`, and the old `QuillToolbar` can be accessed from `QuillBaseToolbar`.
* Refactored Quill editor and toolbar configurations into a single class each.
* After changing checkbox list values, the controller will not request keyboard focus by default.
* Moved toolbar and editor configurations directly into the widget but still use inherited widgets internally.
* Fixes to some code after the refactoring.

## 7.9.0
* Buttons Improvemenets
* Refactor all the button configurations that used in `QuillToolbar.basic()` but there are still few lefts
* **Breaking change**: Remove some configurations from the QuillToolbar and move them to the new `QuillProvider`, please notice this is a development version and this might be changed in the next few days, the stable release will be ready in less than 3 weeks
* Update `flutter_quill_extensions` and it will be published into pub.dev soon.
* Allow you to customize the search dialog by custom callback with child builder

## 7.8.0
* **Important note**: this is not test release yet, it works but need more test and changes and breaking changes, we don't have development version and it will help us if you try the latest version and report the issues in Github but if you want a stable version please use `7.4.16`. this refactoring process will not take long and should be done less than three weeks with the testing.
* We managed to refactor most of the buttons configurations and customizations in the `QuillProvider`, only three lefts then will start on refactoring the toolbar configurations
* Code improvemenets

## 7.7.0
* **Breaking change**: We have mirgrated more buttons in the toolbar configurations, you can do change them in the `QuillProvider`
* Important bug fixes

## 7.6.1
* Bug fixes

## 7.6.0
* **Breaking change**: To customize the buttons in the toolbar, you can do that in the `QuillProvider`

## 7.5.0
* **Breaking change**: The widgets `QuillEditor` and `QuillToolbar` are no longer have controller parameter, instead you need to make sure in the widget tree you have wrapped them with `QuillProvider` widget and provide the controller and the require configurations

## 7.4.16
* Update documentation and README.md

## 7.4.15
* Custom style attrbuites for platforms other than mobile (alignment, margin, width, height)
* Bug fixes and other improvemenets

## 7.4.14
* Improve performance by reducing the number of widgets rebuilt by listening to media query for only the needed things, for example instead of using `MediaQuery.of(context).size`, now we are using `MediaQuery.sizeOf(context)`
* Add MediaButton for picking the images only since the video one is not ready
* A  new feature which allows customizing the text selection in quill editor which is useful for custom theme design system for custom app widget

## 7.4.13
* Fixed tab editing when in readOnly mode.

## 7.4.12
* Update the minimum version of device_info_plus to 9.1.0.

## 7.4.11
* Add sw locale.

## 7.4.10
* Update translations.

## 7.4.9
* Style recognition fixes.

## 7.4.8
* Upgrade dependencies.

## 7.4.7
* Add Vietnamese and German translations.

## 7.4.6
* Fix more null errors in Leaf.retain [##1394](https://github.com/singerdmx/flutter-quill/issues/1394) and Line.delete [##1395](https://github.com/singerdmx/flutter-quill/issues/1395).

## 7.4.5
* Fix null error in Container.insert [##1392](https://github.com/singerdmx/flutter-quill/issues/1392).

## 7.4.4
* Fix extra padding on checklists [##1131](https://github.com/singerdmx/flutter-quill/issues/1131).

## 7.4.3
* Fixed a space input error on iPad.

## 7.4.2
* Fix bug with keepStyleOnNewLine for link.

## 7.4.1
* Fix toolbar dividers condition.

## 7.4.0
* Support Flutter version 3.13.0.

## 7.3.3
* Updated Dependencies conflicting.

## 7.3.2
* Added builder for custom button in _LinkDialog.

## 7.3.1
* Added case sensitive and whole word search parameters.
* Added wrap around.
* Moved search dialog to the bottom in order not to override the editor and the text found.
* Other minor search dialog enhancements.

## 7.3.0
* Add default attributes to basic factory.

## 7.2.19
* Feat/link regexp.

## 7.2.18
* Fix paste block text in words apply same style.

## 7.2.17
* Fix paste text mess up style.
* Add support copy/cut block text.

## 7.2.16
* Allow for custom context menu.

## 7.2.15
* Add flutter_quill.delta library which only exposes Delta datatype.

## 7.2.14
* Fix errors when the editor is used in the `screenshot` package.

## 7.2.13
* Fix around image can't delete line break.

## 7.2.12
* Add support for copy/cut select image and text together.

## 7.2.11
* Add affinity for localPosition.

## 7.2.10
* LINE._getPlainText queryChild inclusive=false.

## 7.2.9
* Add toPlainText method to `EmbedBuilder`.

## 7.2.8
* Add custom button widget in toolbar.

## 7.2.7
* Fix language code of Japan.

## 7.2.6
* Style custom toolbar buttons like builtins.

## 7.2.5
* Always use text cursor for editor on desktop.

## 7.2.4
* Fixed keepStyleOnNewLine.

## 7.2.3
* Get pixel ratio from view.

## 7.2.2
* Prevent operations on stale editor state.

## 7.2.1
* Add support for android keyboard content insertion.
* Enhance color picker, enter hex color and color palette option.

## 7.2.0
* Checkboxes, bullet points, and number points are now scaled based on the default paragraph font size.

## 7.1.20
* Pass linestyle to embedded block.

## 7.1.19
* Fix Rtl leading alignment problem.

## 7.1.18
* Support flutter latest version.

## 7.1.17+1
* Updates `device_info_plus` to version 9.0.0 to benefit from AGP 8 (see [changelog##900](https://pub.dev/packages/device_info_plus/changelog##900)).

## 7.1.16
* Fixed subscript key from 'sup' to 'sub'.

## 7.1.15
* Fixed a bug introduced in 7.1.7 where each section in `QuillToolbar` was displayed on its own line.

## 7.1.14
* Add indents change for multiline selection.

## 7.1.13

* Add custom recognizer.

## 7.1.12

* Add superscript and subscript styles.

## 7.1.11

* Add inserting indents for lines of list if text is selected.

## 7.1.10

* Image embedding tweaks
  * Add MediaButton which is intened to superseed the ImageButton and VideoButton. Only image selection is working.
  * Implement image insert for web (image as base64)

## 7.1.9

* Editor tweaks PR from bambinoua(https://github.com/bambinoua).
  * Shortcuts now working in Mac OS
  * QuillDialogTheme is extended with new properties buttonStyle, linkDialogConstraints, imageDialogConstraints, isWrappable, runSpacing,
  * Added LinkStyleButton2 with new LinkStyleDialog (similar to Quill implementation
  * Conditinally use Row or Wrap for dialog's children.
  * Update minimum Dart SDK version to 2.17.0 to use enum extensions.
  * Use merging shortcuts and actions correclty (if the key combination is the same)

## 7.1.8

* Dropdown tweaks
  * Add itemHeight, itemPadding, defaultItemColor for customization of dropdown items.
  * Remove alignment property as useless.
  * Fix bugs with max width when width property is null.

## 7.1.7

* Toolbar tweaks.
  * Implement tooltips for embed CameraButton, VideoButton, FormulaButton, ImageButton.
  * Extends customization for SelectAlignmentButton, QuillFontFamilyButton, QuillFontSizeButton adding padding, text style, alignment, width.
  * Add renderFontFamilies to QuillFontFamilyButton to show font faces in dropdown.
  * Add AxisDivider and its named constructors for for use in parent project.
  * Export ToolbarButtons enum to allow specify tooltips for SelectAlignmentButton.
  * Export QuillFontFamilyButton, SearchButton as they were not exported before.
  * Deprecate items property in QuillFontFamilyButton, QuillFontSizeButton as the it can be built usinr rawItemsMap.
  * Make onSelection QuillFontFamilyButton, QuillFontSizeButton omittable as no need to execute callback outside if controller is passed to widget.

Now the package is more friendly for web projects.

## 7.1.6

* Add enableUnfocusOnTapOutside field to RawEditor and Editor widgets.

## 7.1.5

* Add tooltips for toolbar buttons.

## 7.1.4

* Fix inserting tab character in lists.

## 7.1.3

* Fix ios cursor bug when word.length==1.

## 7.1.2

* Fix non scrollable editor exception, when tapped under content.

## 7.1.1

* customLinkPrefixes parameter * makes possible to open links with custom protoco.

## 7.1.0

* Fix ordered list numeration with several lists in document.

## 7.0.9

* Use const constructor for EmbedBuilder.

## 7.0.8

* Fix IME position bug with scroller.

## 7.0.7

* Add TextFieldTapRegion for contextMenu.

## 7.0.6

* Fix line style loss on new line from non string.

## 7.0.5

* Fix IME position bug for Mac and Windows.
* Unfocus when tap outside editor. fix the bug that cant refocus in afterButtonPressed after click ToggleStyleButton on Mac.

## 7.0.4

* Have text selection span full line height for uneven sized text.

## 7.0.3

* Fix ordered list numeration for lists with more than one level of list.

## 7.0.2

* Allow widgets to override widget span properties.

## 7.0.1

* Update i18n_extension dependency to version 8.0.0.

## 7.0.0

* Breaking change: Tuples are no longer used. They have been replaced with a number of data classes.

## 6.4.4

* Increased compatibility with Flutter widget tests.

## 6.4.3

* Update dependencies (collection: 1.17.0, flutter_keyboard_visibility: 5.4.0, quiver: 3.2.1, tuple: 2.0.1, url_launcher: 6.1.9, characters: 1.2.1, i18n_extension: 7.0.0, device_info_plus: 8.1.0)

## 6.4.2

* Replace `buildToolbar` with `contextMenuBuilder`.

## 6.4.1

* Control the detect word boundary behaviour.

## 6.4.0

* Use `axis` to make the toolbar vertical.
* Use `toolbarIconCrossAlignment` to align the toolbar icons on the cross axis.
* Breaking change: `QuillToolbar`'s parameter `toolbarHeight` was renamed to `toolbarSize`.

## 6.3.5

* Ability to add custom shortcuts.

## 6.3.4

* Update clipboard status prior to showing selected text overlay.

## 6.3.3

* Fixed handling of mac intents.

## 6.3.2

* Added `unknownEmbedBuilder` to QuillEditor.
* Fix error style when input chinese japanese or korean.

## 6.3.1

* Add color property to the basic factory function.

## 6.3.0

* Support Flutter 3.7.

## 6.2.2

* Fix: nextLine getter null where no assertion.

## 6.2.1

* Revert "Align numerical and bullet lists along with text content".

## 6.2.0

* Align numerical and bullet lists along with text content.

## 6.1.12

* Apply i18n for default font dropdown option labels corresponding to 'Clear'.

## 6.1.11

* Remove iOS hack for delaying focus calculation.

## 6.1.10

* Delay focus calculation for iOS.

## 6.1.9

* Bump keyboard show up wait to 1 sec.

## 6.1.8

* Recalculate focus when showing keyboard.

## 6.1.7

* Add czech localizations.

## 6.1.6

* Upgrade i18n_extension to 6.0.0.

## 6.1.5

* Fix formatting exception.

## 6.1.4

* Add double quotes validation.

## 6.1.3

* Revert "fix order list numbering (##988)".

## 6.1.2

* Add typing shortcuts.

## 6.1.1

* Fix order list numbering.

## 6.1.0

* Add keyboard shortcuts for editor actions.

## 6.0.10

* Upgrade device info plus to ^7.0.0.

## 6.0.9

* Don't throw showAutocorrectionPromptRect not implemented. The function is called with every keystroke as a user is typing.

## 6.0.8+1

* Fixes null pointer when setting documents.

## 6.0.8

* Make QuillController.document mutable.

## 6.0.7

* Allow disabling of selection toolbar.

## 6.0.6+1

* Revert 6.0.6.

## 6.0.6

* Fix wrong custom embed key.

## 6.0.5

* Fixes toolbar buttons stealing focus from editor.

## 6.0.4

* Bug fix for Type 'Uint8List' not found.

## 6.0.3

* Add ability to paste images.

## 6.0.2

* Address Dart Analysis issues.

## 6.0.1

* Changed translation country code (zh_HK -> zh_hk) to lower case, which is required for i18n_extension used in flutter_quill.
* Add localization in example's main to demonstrate translation.
* Issue Windows selection's copy / paste tool bar not shown ##861: add selection's copy / paste toolbar, escape to hide toolbar, mouse right click to show toolbar, ctrl-Y / ctrl-Z to undo / redo.
* Image and video displayed in Windows platform caused screen flickering while selecting text, a sample_data_nomedia.json asset is added for Desktop to demonstrate the added features.
* Known issue: keyboard action sometimes causes exception mentioned in Flutter's issue ##106475 (Windows Keyboard shortcuts stop working after modifier key repeat flutter/flutter##106475).
* Know issue: user needs to click the editor to get focus before toolbar is able to display.

## 6.0.0 BREAKING CHANGE

* Removed embed (image, video & formula) blocks from the package to reduce app size.

These blocks have been moved to the package `flutter_quill_extensions`, migrate by filling the `embedBuilders` and `embedButtons` parameters as follows:

```
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';

QuillEditor.basic(
  controller: controller,
  embedBuilders: FlutterQuillEmbeds.builders(),
);

QuillToolbar.basic(
  controller: controller,
  embedButtons: FlutterQuillEmbeds.buttons(),
);
```

## 5.4.2

* Upgrade i18n_extension.

## 5.4.1

* Update German Translation.

## 5.4.0

* Added Formula Button (for maths support).

## 5.3.2

* Add more font family.

## 5.3.1

* Enable search when text is not empty.

## 5.3.0

* Added search function.

## 5.2.11

* Remove default small color.

## 5.2.10

* Don't wrap the QuillEditor's child in the EditorTextSelectionGestureDetector if selection is disabled.

## 5.2.9

* Added option to modify SelectHeaderStyleButton options.
* Added option to click again on h1, h2, h3 button to go back to normal.

## 5.2.8

* Remove tooltip for LinkStyleButton.
* Make link match regex case insensitive.

## 5.2.7

* Add locale to QuillEditor.basic.

## 5.2.6

* Fix keyboard pops up when resizing the image.

## 5.2.5

* Upgrade youtube_player_flutter_quill to 8.2.2.

## 5.2.4

* Upgrade youtube_player_flutter_quill to 8.2.1.

## 5.2.3

* Flutter Quill Doesn't Work On iOS 16 or Xcode 14 Betas (Stored properties cannot be marked potentially unavailable with '@available').

## 5.2.2

* Fix Web Unsupported operation: Platform.\_operatingSystem error.

## 5.2.1

* Rename QuillCustomIcon to QuillCustomButton.

## 5.2.0

* Support font family selection.

## 5.1.1

* Update README.

## 5.1.0

* Added CustomBlockEmbed and customElementsEmbedBuilder.

## 5.0.5

* Upgrade device_info_plus to 4.0.0.

## 5.0.4

* Added onVideoInit callback for video documents.

## 5.0.3

* Update dependencies.

## 5.0.2

* Keep cursor position on checkbox tap.

## 5.0.1

* Fix static analysis errors.

## 5.0.0

* Flutter 3.0.0 support.

## 4.2.3

* Ignore color:inherit and convert double to int for level.

## 4.2.2

* Add clear option to font size dropdown.

## 4.2.1

* Refactor font size dropdown.

## 4.2.0

* Ensure selectionOverlay is available for showToolbar.

## 4.1.9

* Using properly iconTheme colors.

## 4.1.8

* Update font size dropdown.

## 4.1.7

* Convert FontSize to a Map to allow for named Font Size.

## 4.1.6

* Update quill_dropdown_button.dart.

## 4.1.5

* Add Font Size dropdown to the toolbar.

## 4.1.4

* New borderRadius for iconTheme.

## 4.1.3

* Fix selection handles show/hide after paste, backspace, copy.

## 4.1.2

* Add full support for hardware keyboards (Chromebook, Android tablets, etc) that don't alter screen UI.

## 4.1.1

* Added textSelectionControls field in QuillEditor.

## 4.1.0

* Added Node to linkActionPickerDelegate.

## 4.0.12

* Add Persian(fa) language.

## 4.0.11

* Fix cut selection error in multi-node line.

## 4.0.10

* Fix vertical caret position bug.

## 4.0.9

* Request keyboard focus when no child is found.

## 4.0.8

* Fix blank lines do not display when **web*renderer=html.

## 4.0.7

* Refactor getPlainText (better handling of blank lines and lines with multiple markups.

## 4.0.6

* Bug fix for copying text with new lines.

## 4.0.5

* Fixed casting null to Tuple2 when link dialog is dismissed without any input (e.g. barrier dismissed).

## 4.0.4

* Bug fix for text direction rtl.

## 4.0.3

* Support text direction rtl.

## 4.0.2

* Clear toggled style on selection change.

## 4.0.1

* Fix copy/cut/paste/selectAll not working.

## 4.0.0

* Upgrade for Flutter 2.10.

## 3.9.11

* Added Indonesian translation.

## 3.9.10

* Fix for undoing a modification ending with an indented line.

## 3.9.9

* iOS: Save image whose filename does not end with image file extension.

## 3.9.8

* Added Urdu translation.

## 3.9.7

* Fix for clicking on the Link button without any text on a new line crashes.

## 3.9.6

* Apply locale to QuillEditor(contents).

## 3.9.5

* Fix image pasting.

## 3.9.4

* Hiding dialog after selecting action for image.

## 3.9.3

* Update ImageResizer for Android.

## 3.9.2

* Copy image with its style.

## 3.9.1

* Support resizing image.

## 3.9.0

* Image menu options for copy/remove.

## 3.8.8

* Update set textEditingValue.

## 3.8.7

* Fix checkbox not toggled correctly in toolbar button.

## 3.8.6

* Fix cursor position changes when checking/unchecking the checkbox.

## 3.8.5

* Fix \_handleDragUpdate in \_TextSelectionHandleOverlayState.

## 3.8.4

* Fix link dialog layout.

## 3.8.3

* Fix for errors on a non scrollable editor.

## 3.8.2

* Fix certain keys not working on web when editor is a child of a scroll view.

## 3.8.1

* Refactor \_QuillEditorState to QuillEditorState.

## 3.8.0

* Support pasting with format.

## 3.7.3

* Fix selection overlay for collapsed selection.

## 3.7.2

* Reverted Embed toPlainText change.

## 3.7.1

* Change Embed toPlainText to be empty string.

## 3.7.0

* Replace Toolbar showHistory group with individual showRedo and showUndo.

## 3.6.5

* Update Link dialogue for image/video.

## 3.6.4

* Link dialogue TextInputType.multiline.

## 3.6.3

* Bug fix for link button text selection.

## 3.6.2

* Improve link button.

## 3.6.1

* Remove SnackBar 'What is entered is not a link'.

## 3.6.0

* Allow link button to enter text.

## 3.5.3

* Change link button behavior.

## 3.5.2

* Bug fix for embed.

## 3.5.1

* Bug fix for platform util.

## 3.5.0

* Removed redundant classes.

## 3.4.4

* Add more translations.

## 3.4.3

* Preset link from attributes.

## 3.4.2

* Fix launch link edit mode.

## 3.4.1

* Placeholder effective in scrollable.

## 3.4.0

* Option to save image in read-only mode.

## 3.3.1

* Pass any specified key in QuillEditor constructor to super.

## 3.3.0

* Fixed Style toggle issue.

## 3.2.1

* Added new translations.

## 3.2.0

* Support multiple links insertion on the go.

## 3.1.1

* Add selection completed callback.

## 3.1.0

* Fixed image ontap functionality.

## 3.0.4

* Add maxContentWidth constraint to editor.

## 3.0.3

* Do not show caret on screen when the editor is not focused.

## 3.0.2

* Fix launch link for read-only mode.

## 3.0.1

* Handle null value of Attribute.link.

## 3.0.0

* Launch link improvements.
* Removed QuillSimpleViewer.

## 2.5.2

* Skip image when pasting.

## 2.5.1

* Bug fix for Desktop `Shift` + `Click` support.

## 2.5.0

* Update checkbox list.

## 2.4.1

* Desktop selection improvements.

## 2.4.0

* Improve inline code style.

## 2.3.3

* Improves selection rects to have consistent height regardless of individual segment text styles.

## 2.3.2

* Allow disabling floating cursor.

## 2.3.1

* Preserve last newline character on delete.

## 2.3.0

* Massive changes to support flutter 2.8.

## 2.2.2

* iOS - floating cursor.

## 2.2.1

* Bug fix for imports supporting flutter 2.8.

## 2.2.0

* Support flutter 2.8.

## 2.1.1

* Add methods of clearing editor and moving cursor.

## 2.1.0

* Add delete handler.

## 2.0.23

* Support custom replaceText handler.

## 2.0.22

* Fix attribute compare and fix font size parsing.

## 2.0.21

* Handle click on embed object.

## 2.0.20

* Improved UX/UI of Image widget.

## 2.0.19

* When uploading a video, applying indicator.

## 2.0.18

* Make toolbar dividers optional.

## 2.0.17

* Allow alignment of the toolbar icons to match WrapAlignment.

## 2.0.16

* Add hide / show alignment buttons.

## 2.0.15

* Implement change cursor to SystemMouseCursors.click when hovering a link styled text.

## 2.0.14

* Enable customize the checkbox widget using DefaultListBlockStyle style.

## 2.0.13

* Improve the scrolling performance by reducing the repaint areas.

## 2.0.12

* Fix the selection effect can't be seen as the textLine with background color.

## 2.0.11

* Fix visibility of text selection handlers on scroll.

## 2.0.10

* cursorConnt.color notify the text_line to repaint if it was disposed.

## 2.0.9

* Improve UX when trying to add a link.

## 2.0.8

* Adding translations to the toolbar.

## 2.0.7

* Added theming options for toolbar icons and LinkDialog.

## 2.0.6

* Avoid runtime error when placed inside TabBarView.

## 2.0.5

* Support inline code formatting.

## 2.0.4

* Enable history shortcuts for desktop.

## 2.0.3

* Fix cursor when line contains image.

## 2.0.2

* Address KeyboardListener class name conflict.

## 2.0.1

* Upgrade flutter_colorpicker to 0.5.0.

## 2.0.0

* Text Alignment functions + Block Format standards.

## 1.9.6

* Support putting QuillEditor inside a Scrollable view.

## 1.9.5

* Skip image when pasting.

## 1.9.4

* Bug fix for cursor position when tapping at the end of line with image(s).

## 1.9.3

* Bug fix when line only contains one image.

## 1.9.2

* Support for building custom inline styles.

## 1.9.1

* Cursor jumps to the most appropriate offset to display selection.

## 1.9.0

* Support inline image.

## 1.8.3

* Updated quill_delta.

## 1.8.2

* Support mobile image alignment.

## 1.8.1

* Support mobile custom size image.

## 1.8.0

* Support entering link for image/video.

## 1.7.3

* Bumps photo_view version.

## 1.7.2

* Fix static analysis error.

## 1.7.1

* Support Youtube video.

## 1.7.0

* Support video.

## 1.6.4

* Bug fix for clear format button.

## 1.6.3

* Fixed dragging right handle scrolling issue.

## 1.6.2

* Fixed the position of the selection status drag handle.

## 1.6.1

* Upgrade image_picker and flutter_colorpicker.

## 1.6.0

* Support Multi Row Toolbar.

## 1.5.0

* Remove file_picker dependency.

## 1.4.1

* Remove filesystem_picker dependency.

## 1.4.0

* Remove path_provider dependency.

## 1.3.4

* Add option to paintCursorAboveText.

## 1.3.3

* Upgrade file_picker version.

## 1.3.2

* Fix copy/paste bug.

## 1.3.1

* New logo.

## 1.3.0

* Support flutter 2.2.0.

## 1.2.2

* Checkbox supports tapping.

## 1.2.1

* Indented position not holding while editing.

## 1.2.0

* Fix image button cancel causes crash.

## 1.1.8

* Fix height of empty line bug.

## 1.1.7

* Fix text selection in read-only mode.

## 1.1.6

* Remove universal_html dependency.

## 1.1.5

* Enable "Select", "Select All" and "Copy" in read-only mode.

## 1.1.4

* Fix text selection issue.

## 1.1.3

* Update example folder.

## 1.1.2

* Add pedantic.

## 1.1.1

* Base64 image support.

## 1.1.0

* Support null safety.

## 1.0.9

* Web support for raw editor and keyboard listener.

## 1.0.8

* Support token attribute.

## 1.0.7

* Fix crash on web (dart:io).

## 1.0.6

* Add desktop support WINDOWS, MACOS and LINUX.

## 1.0.5

* Bug fix: Can not insert newline when Bold is toggled ON.

## 1.0.4

* Upgrade photo_view to ^0.11.0.

## 1.0.3

* Fix issue that text is not displayed while typing WEB.

## 1.0.2

* Update toolbar in sample home page.

## 1.0.1

* Fix static analysis errors.

## 1.0.0

* Support flutter 2.0.

## 1.0.0-dev.2

* Improve link handling for tel, mailto and etc.

## 1.0.0-dev.1

* Upgrade prerelease SDK & Bump for master.

## 0.3.5

* Fix for cursor focus issues when keyboard is on.

## 0.3.4

* Improve link handling for tel, mailto and etc.

## 0.3.3

* More fix on cursor focus issue when keyboard is on.

## 0.3.2

* Fix cursor focus issue when keyboard is on.

## 0.3.1

* cursor focus when keyboard is on.

## 0.3.0

* Line Height calculated based on font size.

## 0.2.12

* Support placeholder.

## 0.2.11

* Fix static analysis error.

## 0.2.10

* Update TextInputConfiguration autocorrect to true in stable branch.

## 0.2.9

* Update TextInputConfiguration autocorrect to true.

## 0.2.8

* Support display local image besides network image in stable branch.

## 0.2.7

* Support display local image besides network image.

## 0.2.6

* Fix cursor after pasting.

## 0.2.5

* Toggle text/background color button in toolbar.

## 0.2.4

* Support the use of custom icon size in toolbar.

## 0.2.3

* Support custom styles and image on local device storage without uploading.

## 0.2.2

* Update git repo.

## 0.2.1

* Fix static analysis error.

## 0.2.0

* Add checked/unchecked list button in toolbar.

## 0.1.8

* Support font and size attributes.

## 0.1.7

* Support checked/unchecked list.

## 0.1.6

* Fix getExtentEndpointForSelection.

## 0.1.5

* Support text alignment.

## 0.1.4

* Handle url with trailing spaces.

## 0.1.3

* Handle cursor position change when undo/redo.

## 0.1.2

* Handle more text colors.

## 0.1.1

* Fix cursor issue when undo.

## 0.1.0

* Fix insert image.

## 0.0.9

* Handle rgba color.

## 0.0.8

* Fix launching url.

## 0.0.7

* Handle multiple image inserts.

## 0.0.6

* More toolbar functionality.

## 0.0.5

* Update example.

## 0.0.4

* Update example.

## 0.0.3

* Update home page meta data.

## 0.0.2

* Support image upload and launch url in read-only mode.

## 0.0.1

* Rich text editor based on Quill Delta.
