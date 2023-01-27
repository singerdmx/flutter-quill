# [6.3.1]
* Add color property to the basic factory function.

# [6.3.0]
* Support Flutter 3.7.

# [6.2.2]
* Fix: nextLine getter null where no assertion.

# [6.2.1]
* Revert "Align numerical and bullet lists along with text content".

# [6.2.0]
* Align numerical and bullet lists along with text content.

# [6.1.12]
* Apply i18n for default font dropdown option labels corresponding to 'Clear'.

# [6.1.11]
* Remove iOS hack for delaying focus calculation.

# [6.1.10]
* Delay focus calculation for iOS.

# [6.1.9]
* Bump keyboard show up wait to 1 sec.

# [6.1.8]
* Recalculate focus when showing keyboard.

# [6.1.7]
* Add czech localizations.

# [6.1.6]
* Upgrade i18n_extension to 6.0.0.

# [6.1.5]
* Fix formatting exception.

# [6.1.4]
* Add double quotes validation.

# [6.1.3]
* Revert "fix order list numbering (#988)".

# [6.1.2]
* Add typing shortcuts.

# [6.1.1]
* Fix order list numbering.

# [6.1.0]
* Add keyboard shortcuts for editor actions.

# [6.0.10]
* Upgrade device info plus to ^7.0.0.

# [6.0.9]
* Don't throw showAutocorrectionPromptRect not implemented. The function is called with every keystroke as a user is typing.

# [6.0.8+1]
* Fixes null pointer when setting documents.

# [6.0.8]
* Make QuillController.document mutable.

# [6.0.7]
* Allow disabling of selection toolbar.

# [6.0.6+1]
* Revert 6.0.6.

# [6.0.6]
* Fix wrong custom embed key.

# [6.0.5]
* Fixes toolbar buttons stealing focus from editor.

# [6.0.4]
* Bug fix for Type 'Uint8List' not found.

# [6.0.3]
* Add ability to paste images.

# [6.0.2]
* Address Dart Analysis issues.

# [6.0.1]
* Changed translation country code (zh_HK -> zh_hk) to lower case, which is required for i18n_extension used in flutter_quill.
* Add localization in example's main to demonstrate translation.
* Issue [Windows] selection's copy / paste tool bar not shown #861: add selection's copy / paste toolbar, escape to hide toolbar, mouse right click to show toolbar, ctrl-Y / ctrl-Z to undo / redo.
* Image and video displayed in Windows platform caused screen flickering while selecting text, a sample_data_nomedia.json asset is added for Desktop to demonstrate the added features.
* Known issue: keyboard action sometimes causes exception mentioned in Flutter's issue #106475 ([Windows] Keyboard shortcuts stop working after modifier key repeat flutter/flutter#106475).
* Know issue: user needs to click the editor to get focus before toolbar is able to display.

# [6.0.0] BREAKING CHANGE
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


# [5.4.2]
* Upgrade i18n_extension.

# [5.4.1]
* Update German Translation. 

# [5.4.0]
* Added Formula Button (for maths support).

# [5.3.2]
* Add more font family.

# [5.3.1]
* Enable search when text is not empty.

# [5.3.0]
* Added search function.

# [5.2.11]
* Remove default small color.

# [5.2.10]
* Don't wrap the QuillEditor's child in the EditorTextSelectionGestureDetector if selection is disabled.

# [5.2.9]
* Added option to modify SelectHeaderStyleButton options.
* Added option to click again on h1, h2, h3 button to go back to normal.

# [5.2.8]
* Remove tooltip for LinkStyleButton.
* Make link match regex case insensitive.

# [5.2.7]
* Add locale to QuillEditor.basic.

# [5.2.6]
* Fix keyboard pops up when resizing the image.

# [5.2.5]
* Upgrade youtube_player_flutter_quill to 8.2.2.

# [5.2.4]
* Upgrade youtube_player_flutter_quill to 8.2.1.

# [5.2.3]
* Flutter Quill Doesn't Work On iOS 16 or Xcode 14 Betas (Stored properties cannot be marked potentially unavailable with '@available').

# [5.2.2]
* Fix Web Unsupported operation: Platform._operatingSystem error.

# [5.2.1]
* Rename QuillCustomIcon to QuillCustomButton.

# [5.2.0]
* Support font family selection.

# [5.1.1]
* Update README.

# [5.1.0]
* Added CustomBlockEmbed and customElementsEmbedBuilder.

# [5.0.5]
* Upgrade device_info_plus to 4.0.0.

# [5.0.4]
* Added onVideoInit callback for video documents.

# [5.0.3]
* Update dependencies.

# [5.0.2]
* Keep cursor position on checkbox tap.

# [5.0.1]
* Fix static analysis errors.

# [5.0.0]
* Flutter 3.0.0 support.

# [4.2.3]
* Ignore color:inherit and convert double to int for level.

# [4.2.2]
* Add clear option to font size dropdown.

# [4.2.1]
* Refactor font size dropdown.

# [4.2.0]
* Ensure selectionOverlay is available for showToolbar.

# [4.1.9]
* Using properly iconTheme colors.

# [4.1.8]
* Update font size dropdown.

# [4.1.7]
* Convert FontSize to a Map to allow for named Font Size.

# [4.1.6]
* Update quill_dropdown_button.dart.

# [4.1.5]
* Add Font Size dropdown to the toolbar.

# [4.1.4]
* New borderRadius for iconTheme.

# [4.1.3]
* Fix selection handles show/hide after paste, backspace, copy.

# [4.1.2]
* Add full support for hardware keyboards (Chromebook, Android tablets, etc) that don't alter screen UI.

# [4.1.1]
* Added textSelectionControls field in QuillEditor.

# [4.1.0]
* Added Node to linkActionPickerDelegate.

# [4.0.12]
* Add Persian(fa) language.

# [4.0.11]
* Fix cut selection error in multi-node line.

# [4.0.10]
* Fix vertical caret position bug.

# [4.0.9]
* Request keyboard focus when no child is found.

# [4.0.8]
* Fix blank lines do not display when --web-renderer=html.

# [4.0.7]
* Refactor getPlainText (better handling of blank lines and lines with multiple markups.

# [4.0.6]
* Bug fix for copying text with new lines.

# [4.0.5]
* Fixed casting null to Tuple2 when link dialog is dismissed without any input (e.g. barrier dismissed).

# [4.0.4]
* Bug fix for text direction rtl.

# [4.0.3]
* Support text direction rtl.

# [4.0.2]
* Clear toggled style on selection change.

# [4.0.1]
* Fix copy/cut/paste/selectAll not working.

# [4.0.0]
* Upgrade for Flutter 2.10.

# [3.9.11]
* Added Indonesian translation.

# [3.9.10]
* Fix for undoing a modification ending with an indented line.

# [3.9.9]
* iOS: Save image whose filename does not end with image file extension.

# [3.9.8]
* Added Urdu translation.

# [3.9.7]
* Fix for clicking on the Link button without any text on a new line crashes.

# [3.9.6]
* Apply locale to QuillEditor(contents).

# [3.9.5]
* Fix image pasting.

# [3.9.4]
* Hiding dialog after selecting action for image.

# [3.9.3]
* Update ImageResizer for Android.

# [3.9.2]
* Copy image with its style.

# [3.9.1]
* Support resizing image.

# [3.9.0]
* Image menu options for copy/remove.

# [3.8.8]
* Update set textEditingValue.

# [3.8.7]
* Fix checkbox not toggled correctly in toolbar button.

# [3.8.6]
* Fix cursor position changes when checking/unchecking the checkbox.

# [3.8.5]
* Fix _handleDragUpdate in _TextSelectionHandleOverlayState.

# [3.8.4]
* Fix link dialog layout.

# [3.8.3]
* Fix for errors on a non scrollable editor.

# [3.8.2]
* Fix certain keys not working on web when editor is a child of a scroll view.

# [3.8.1]
* Refactor _QuillEditorState to QuillEditorState.

# [3.8.0]
* Support pasting with format.

# [3.7.3]
* Fix selection overlay for collapsed selection.

# [3.7.2]
* Reverted Embed toPlainText change.

# [3.7.1]
* Change Embed toPlainText to be empty string.

# [3.7.0]
* Replace Toolbar showHistory group with individual showRedo and showUndo.

# [3.6.5]
* Update Link dialogue for image/video.

# [3.6.4]
* Link dialogue TextInputType.multiline.

# [3.6.3]
* Bug fix for link button text selection.

# [3.6.2]
* Improve link button.

# [3.6.1]
* Remove SnackBar 'What is entered is not a link'.

# [3.6.0]
* Allow link button to enter text.

# [3.5.3]
* Change link button behavior.

# [3.5.2]
* Bug fix for embed.

# [3.5.1]
* Bug fix for platform util.

# [3.5.0]
* Removed redundant classes.

# [3.4.4]
* Add more translations.

# [3.4.3]
* Preset link from attributes.

# [3.4.2]
* Fix launch link edit mode.

# [3.4.1]
* Placeholder effective in scrollable.

# [3.4.0]
* Option to save image in read-only mode.

# [3.3.1]
* Pass any specified key in QuillEditor constructor to super.

# [3.3.0]
* Fixed Style toggle issue.

# [3.2.1]
* Added new translations.

# [3.2.0]
* Support multiple links insertion on the go.

# [3.1.1]
* Add selection completed callback.

# [3.1.0]
* Fixed image ontap functionality.

# [3.0.4]
* Add maxContentWidth constraint to editor.

# [3.0.3]
* Do not show caret on screen when the editor is not focused.

# [3.0.2]
* Fix launch link for read-only mode.

# [3.0.1]
* Handle null value of Attribute.link.

# [3.0.0]
* Launch link improvements.
* Removed QuillSimpleViewer.

# [2.5.2]
* Skip image when pasting.

# [2.5.1]
* Bug fix for Desktop `Shift` + `Click` support.

# [2.5.0]
* Update checkbox list.

# [2.4.1]
* Desktop selection improvements.

# [2.4.0]
* Improve inline code style.

# [2.3.3]
* Improves selection rects to have consistent height regardless of individual segment text styles.

# [2.3.2]
* Allow disabling floating cursor.

# [2.3.1]
* Preserve last newline character on delete.

# [2.3.0]
* Massive changes to support flutter 2.8.

# [2.2.2]
* iOS - floating cursor.

# [2.2.1]
* Bug fix for imports supporting flutter 2.8.

# [2.2.0]
* Support flutter 2.8.

# [2.1.1]
* Add methods of clearing editor and moving cursor.

# [2.1.0]
* Add delete handler.

# [2.0.23]
* Support custom replaceText handler.

# [2.0.22]
* Fix attribute compare and fix font size parsing.

# [2.0.21]
* Handle click on embed object.

# [2.0.20]
* Improved UX/UI of Image widget.

# [2.0.19]
* When uploading a video, applying indicator.

# [2.0.18]
* Make toolbar dividers optional.

# [2.0.17]
* Allow alignment of the toolbar icons to match WrapAlignment.

# [2.0.16]
* Add hide / show alignment buttons.

# [2.0.15]
* Implement change cursor to SystemMouseCursors.click when hovering a link styled text.

# [2.0.14]
* Enable customize the checkbox widget using DefaultListBlockStyle style.

# [2.0.13]
* Improve the scrolling performance by reducing the repaint areas.

# [2.0.12]
* Fix the selection effect can't be seen as the textLine with background color.

# [2.0.11]
* Fix visibility of text selection handlers on scroll.

# [2.0.10]
* cursorConnt.color notify the text_line to repaint if it was disposed.

# [2.0.9]
* Improve UX when trying to add a link.

# [2.0.8]
* Adding translations to the toolbar.

# [2.0.7]
* Added theming options for toolbar icons and LinkDialog.

# [2.0.6]
* Avoid runtime error when placed inside TabBarView.

# [2.0.5]
* Support inline code formatting.

# [2.0.4]
* Enable history shortcuts for desktop.

# [2.0.3]
* Fix cursor when line contains image.

# [2.0.2]
* Address KeyboardListener class name conflict.

# [2.0.1]
* Upgrade flutter_colorpicker to 0.5.0.

# [2.0.0]
* Text Alignment functions + Block Format standards.

# [1.9.6]
* Support putting QuillEditor inside a Scrollable view.

# [1.9.5]
* Skip image when pasting.

# [1.9.4]
* Bug fix for cursor position when tapping at the end of line with image(s).

# [1.9.3]
* Bug fix when line only contains one image.

# [1.9.2]
* Support for building custom inline styles.

# [1.9.1]
* Cursor jumps to the most appropriate offset to display selection.

# [1.9.0]
* Support inline image.

# [1.8.3]
* Updated quill_delta.

# [1.8.2]
* Support mobile image alignment.

# [1.8.1]
* Support mobile custom size image.

# [1.8.0]
* Support entering link for image/video.

# [1.7.3]
* Bumps photo_view version.

# [1.7.2]
* Fix static analysis error.

# [1.7.1]
* Support Youtube video.

# [1.7.0]
* Support video.

# [1.6.4]
* Bug fix for clear format button.

# [1.6.3]
* Fixed dragging right handle scrolling issue.

# [1.6.2]
* Fixed the position of the selection status drag handle.

# [1.6.1]
* Upgrade image_picker and flutter_colorpicker.

# [1.6.0]
* Support Multi Row Toolbar.

# [1.5.0]
* Remove file_picker dependency.

# [1.4.1]
* Remove filesystem_picker dependency.

# [1.4.0]
* Remove path_provider dependency.

# [1.3.4]
* Add option to paintCursorAboveText.

# [1.3.3]
* Upgrade file_picker version.

# [1.3.2]
* Fix copy/paste bug.

# [1.3.1]
* New logo.

# [1.3.0]
* Support flutter 2.2.0.

# [1.2.2]
* Checkbox supports tapping.

# [1.2.1]
* Indented position not holding while editing.

# [1.2.0]
* Fix image button cancel causes crash.

# [1.1.8]
* Fix height of empty line bug.

# [1.1.7]
* Fix text selection in read-only mode.

# [1.1.6]
* Remove universal_html dependency.

# [1.1.5]
* Enable "Select", "Select All" and "Copy" in read-only mode.

# [1.1.4]
* Fix text selection issue.

# [1.1.3]
* Update example folder.

# [1.1.2]
* Add pedantic.

# [1.1.1]
* Base64 image support.

# [1.1.0]
* Support null safety.

# [1.0.9]
* Web support for raw editor and keyboard listener.

# [1.0.8]
* Support token attribute.

# [1.0.7]
* Fix crash on web (dart:io).

# [1.0.6]
* Add desktop support - WINDOWS, MACOS and LINUX.

# [1.0.5]
* Bug fix: Can not insert newline when Bold is toggled ON.

# [1.0.4]
* Upgrade photo_view to ^0.11.0.

# [1.0.3]
* Fix issue that text is not displayed while typing [WEB].

# [1.0.2]
* Update toolbar in sample home page.

# [1.0.1]
* Fix static analysis errors.

# [1.0.0]
* Support flutter 2.0.

# [1.0.0-dev.2]
* Improve link handling for tel, mailto and etc.

# [1.0.0-dev.1]
* Upgrade prerelease SDK & Bump for master.

# [0.3.5]
* Fix for cursor focus issues when keyboard is on.

# [0.3.4]
* Improve link handling for tel, mailto and etc.

# [0.3.3]
* More fix on cursor focus issue when keyboard is on.

# [0.3.2]
* Fix cursor focus issue when keyboard is on.

# [0.3.1]
* cursor focus when keyboard is on.

# [0.3.0]
* Line Height calculated based on font size.

# [0.2.12]
* Support placeholder.

# [0.2.11]
* Fix static analysis error.

# [0.2.10]
* Update TextInputConfiguration autocorrect to true in stable branch.

# [0.2.9]
* Update TextInputConfiguration autocorrect to true.

# [0.2.8]
* Support display local image besides network image in stable branch.

# [0.2.7]
* Support display local image besides network image.

# [0.2.6]
* Fix cursor after pasting.

# [0.2.5]
* Toggle text/background color button in toolbar.

# [0.2.4]
* Support the use of custom icon size in toolbar.

# [0.2.3]
* Support custom styles and image on local device storage without uploading.

# [0.2.2]
* Update git repo.

# [0.2.1]
* Fix static analysis error.

# [0.2.0]
* Add checked/unchecked list button in toolbar.

# [0.1.8]
* Support font and size attributes.

# [0.1.7]
* Support checked/unchecked list.

# [0.1.6]
* Fix getExtentEndpointForSelection.

# [0.1.5]
* Support text alignment.

# [0.1.4]
* Handle url with trailing spaces.

# [0.1.3]
* Handle cursor position change when undo/redo.

# [0.1.2]
* Handle more text colors.

# [0.1.1]
* Fix cursor issue when undo.

# [0.1.0]
* Fix insert image.

# [0.0.9]
* Handle rgba color.

# [0.0.8]
* Fix launching url.

# [0.0.7]
* Handle multiple image inserts.

# [0.0.6]
* More toolbar functionality.

# [0.0.5]
* Update example.

# [0.0.4]
* Update example.

# [0.0.3]
* Update home page meta data.

# [0.0.2]
* Support image upload and launch url in read-only mode.

# [0.0.1]
* Rich text editor based on Quill Delta.
