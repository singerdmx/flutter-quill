# Shortcut events

We will use a simple example to illustrate how to quickly add a `CharacterShortcutEvent` event.

In this example, text that starts and ends with an asterisk ( * ) character will be rendered in italics for emphasis. So typing `*xxx*` will automatically be converted into _`xxx`_.

Let's start with a empty document:

```dart
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter/material.dart';

class AsteriskToItalicStyle extends StatelessWidget {
  const AsteriskToItalicStyle({super.key});

  @override
  Widget build(BuildContext context) {
    return QuillEditor(
      scrollController: <your_scrollController>,
      focusNode: <your_focusNode>,
      controller: <your_controller>,
      configurations: QuillEditorConfigurations(
        characterShortcutEvents: [],
      ),
    );
  }
}
```

At this point, nothing magic will happen after typing `*xxx*`.

<p align="center">
   <img src="https://github.com/user-attachments/assets/c9ab15ec-2ada-4a84-96e8-55e6145e7925" width="800px" alt="Editor without shortcuts gif">
</p>

To implement our shortcut event we will create a `CharacterShortcutEvent` instance to handle an asterisk input.

We need to define key and character in a `CharacterShortcutEvent` object to customize hotkeys. We recommend using the description of your event as a key. For example, if the asterisk `*` is defined to make text italic, the key can be 'Asterisk to italic'.

```dart
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter/material.dart';

// [handleFormatByWrappingWithSingleCharacter] is a example function that contains 
// the necessary logic to replace asterisk characters and apply correctly the 
// style to the text around them 

enum SingleCharacterFormatStyle {
  code,
  italic,
  strikethrough,
}

CharacterShortcutEvent asteriskToItalicStyleEvent = CharacterShortcutEvent(
  key: 'Asterisk to italic',
  character: '*',
  handler: (QuillController controller) => handleFormatByWrappingWithSingleCharacter(
    controller: controller,
    character: '*',
    formatStyle: SingleCharacterFormatStyle.italic,
  ),
);
```

Now our 'asterisk handler' function is done and the only task left is to inject it into the `QuillEditorConfigurations`.

```dart
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter/material.dart';

class AsteriskToItalicStyle extends StatelessWidget {
  const AsteriskToItalicStyle({super.key});

  @override
  Widget build(BuildContext context) {
    return QuillEditor(
      scrollController: <your_scrollController>,
      focusNode: <your_focusNode>,
      controller: <your_controller>,
      configurations: QuillEditorConfigurations(
        characterShortcutEvents: [
           asteriskToItalicStyleEvent,
        ],
      ),
    );
  }
}

CharacterShortcutEvent asteriskToItalicStyleEvent = CharacterShortcutEvent(
  key: 'Asterisk to italic',
  character: '*',
  handler: (QuillController controller) => handleFormatByWrappingWithSingleCharacter(
    controller: controller,
    character: '*',
    formatStyle: SingleCharacterFormatStyle.italic,
  ),
);
```
<p align="center">
   <img src="https://github.com/user-attachments/assets/35e74cbf-1bd8-462d-bb90-50d712012c90" width="800px" alt="Editor with shortcuts gif">
</p>
