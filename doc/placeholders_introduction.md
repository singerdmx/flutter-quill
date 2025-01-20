# ✏️ Placeholders

> A **placeholder** is visible text that serves as a guide or instruction for the user when a text field or editable area is empty.

In **Flutter Quill**, there are three scenarios where **placeholders** can appear:

- When the document is empty, a placeholder will appear at the beginning.
- When a dynamic placeholder is configured, it can display custom guide text anywhere in the document.
- When a cursor placeholder is set up, it appears whenever a line is completely empty.

### 💡 How to Display a Placeholder When the Document is Empty

To configure this, you need to use the `QuillEditorConfig` class:

```dart
final config = QuillEditorConfig(
    placeholder: 'Start writing your notes...',
);
```

### 🔎 What Are Dynamic Placeholders?

**Dynamic placeholders** are not static or predetermined; they are **generated or adjusted automatically** based on the context of the content or the attributes applied to the text in the editor.

These **placeholders** appear only when specific conditions are met, such as:

- The block is empty.
- No additional text attributes (e.g., styles or links) are applied.

#### 🛠️ How to Create a Dynamic Placeholder

Here's a simple example:

If you want to display guide text only when a header is applied and the line with this attribute is empty, you can use the following code:

```dart
final config = QuillEditorConfig(
    placeholderConfig: PlaceholderConfig(
      builders: {
        Attribute.header.key: (Attribute attr, TextStyle style) {
          // In this case, we will only support header levels h1 to h3
          final values = [30, 27, 22];
          final level = attr.value as int?;
          if (level == null) return null;
          final fontSize = values[(level - 1 < 0 || level - 1 > 3 ? 0 : level - 1)];
          return PlaceholderTextBuilder(
              text: 'Header $level',
              style: TextStyle(
                  fontSize: fontSize.toDouble())
              .merge(style.copyWith(
                  color: Colors.grey)),
         ); 
      },
   ),      
);
```

### 🔎 What Are Cursor Placeholders?

**Cursor placeholders** appear when a line is completely empty and has no attributes applied. These placeholders automatically appear at the same level as the cursor, though their position can be adjusted using the `offset` parameter in the `CursorPlaceholderConfig` class.

Here's a simple implementation example:

```dart
final config = QuillEditorConfig(
    cursorPlaceholderConfig: CursorPlaceholderConfig(
        text: 'Write something...',
        textStyle: TextStyle(
            color: Colors.grey, 
            fontStyle: FontStyle.italic,
        ),
        show: true,
        offset: Offset(3.5, 2),
    ),
);
```

