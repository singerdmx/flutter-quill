# Todo

This is a todo list page that added recently and will be updated soon.

## Table of contents
- [Todo](#todo)
  - [Table of contents](#table-of-contents)
  - [Flutter Quill](#flutter-quill)
    - [Features](#features)
    - [Improvemenets](#improvemenets)
    - [Bugs](#bugs)
  - [Flutter Quill Extensions](#flutter-quill-extensions)
    - [Features](#features-1)
    - [Improvemenets](#improvemenets-1)
    - [Bugs](#bugs-1)

## Flutter Quill

### Features

  - Add support for Text magnification feature, for more [info](https://github.com/singerdmx/flutter-quill/issues/1504)
  - Provide a way to expose quills undo redo stacks, for more [info](https://github.com/singerdmx/flutter-quill/issues/1381)
  - Add callback to the `QuillToolbarColorButton` for custom color picking logic

### Improvemenets

 - Improve the Raw Quill Editor, for more [info](https://github.com/singerdmx/flutter-quill/issues/1509)
 - Provide more support to all the platforms
 - Extract the shared properties between `QuillRawEditorConfigurations` and `QuillEditorConfigurations`
 - The todo in the this [commit](https://github.com/singerdmx/flutter-quill/commit/79597ea6425357795c0663588ac079665241f23a) needs to be checked
 - use `maybeOf` and of instead `ofNotNull` in the providers to follow flutter offical convenstion, completly rework the providers and update the build context extensions
 - Add line through to the text when the check point checked is true
 - Change the color of the numbers and dots in ol/ul to match the ones in the item list
 - Fix the bugs of the font family and font size
 - Try to update Quill Html Converter
 - When pasting a HTML text from cliboard by not using the context menu builder, the new logic won't work
 - When selecting all text and paste HTML text, it will not replace the current text, instead it will add a text
 - Add strike-through in checkbox text when the checkpoint is checked
 - No more using of dynamic
 - There is a bug here, the first character is not being formatted when choosing font family or font size and type in the editor
 - Fix the toolbar and the toolbar buttons, rework some of them, for example missing tooltips

### Bugs

Empty for now.
Please go to the [issues](https://github.com/singerdmx/flutter-quill/issues)


## Flutter Quill Extensions

### Features

### Improvemenets

### Bugs