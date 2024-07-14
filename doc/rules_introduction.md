## Rule

`Rule` in `flutter_quill` is a handler for specific operations within the editor. They define how to apply, modify, or delete content based on user actions. Each Rule corresponds to a type of operation that the editor can perform.

### RuleType

There are three main `RuleTypes` supported in `flutter_quill`, each serving a distinct purpose:

- **insert**: Handles operations related to inserting new content into the editor. This includes inserting text, images, or any other supported media.

- **delete**: Manages operations that involve deleting content from the editor. This can include deleting characters, lines, or entire blocks of content.

- **format**: Deals with operations that apply formatting changes to the content in the editor. This could involve applying styles such as bold, italic, underline, or changing text alignment, among others.

### How Rules Work

When a user interacts with the editor in `flutter_quill`, their actions are translated into one of the predefined `RuleType`. For instance:

- When the user types a new character, an **insert** Rule is triggered to handle the insertion of that character into the editor's content.
- When the user selects and deletes a block of text, a **delete** Rule is used to remove that selection from the editor.
- Applying formatting, such as making text bold or italic, triggers a **format** Rule to update the style of the selected text.

`Rule` is designed to be modular and configurable, allowing developers to extend or customize editor behavior as needed. By defining how each RuleType operates, `flutter_quill` ensures consistent and predictable behavior across different editing operations.


### Example of a custom `Rule`

In this case, we will use a simple example. We will create a `Rule` that is responsible for detecting any word that is surrounded by "*" just as any `Markdown` editor would do for italics.

In order for it to be detected while the user writes character by character, what we will do is extend the `InsertRule` class that is responsible for being called while the user writes a word character by character.

```dart
/// Applies italic format to text segment (which is surrounded by *)
/// when user inserts space character after it.
class AutoFormatItalicRule extends InsertRule {
  const AutoFormatItalicRule();

  static const _italicPattern = r'\*(.+)\*';

  RegExp get italicRegExp => RegExp(
        _italicPattern,
        caseSensitive: false,
      );

  @override
  Delta? applyRule(
    Document document,
    int index, {
    int? len,
    Object? data,
    Attribute? attribute,
    Object? extraData,
  }) {
    // Only format when inserting text.
    if (data is! String) return null;

    // Get current text.
    final entireText = document.toPlainText();

    // Get word before insertion.
    final leftWordPart = entireText
        // Keep all text before insertion.
        .substring(0, index)
        // Keep last paragraph.
        .split('\n')
        .last
        // Keep last word.
        .split(' ')
        .last
        .trimLeft();

    // Get word after insertion.
    final rightWordPart = entireText
        // Keep all text after insertion.
        .substring(index)
        // Keep first paragraph.
        .split('\n')
        .first
        // Keep first word.
        .split(' ')
        .first
        .trimRight();

    // Build the segment of affected words.
    final affectedWords = '$leftWordPart$data$rightWordPart';

    // Check for italic patterns.
    final italicMatches = italicRegExp.allMatches(affectedWords);

    // If there are no matches, do not apply any format.
    if (italicMatches.isEmpty) return null;

    // Build base delta.
    // The base delta is a simple insertion delta.
    final baseDelta = Delta()
      ..retain(index)
      ..insert(data);

    // Get unchanged text length.
    final unmodifiedLength = index - leftWordPart.length;

    // Create formatter delta.
    // The formatter delta will include italic formatting when needed.
    final formatterDelta = Delta()..retain(unmodifiedLength);

    var previousEndRelativeIndex = 0;

    void retainWithAttributes(int start, int end, Map<String, dynamic> attributes) {
      final separationLength = start - previousEndRelativeIndex;
      final segment = affectedWords.substring(start, end);
      formatterDelta
        ..retain(separationLength)
        ..retain(segment.length, attributes);
      previousEndRelativeIndex = end;
    }

    for (final match in italicMatches) {
      final matchStart = match.start;
      final matchEnd = match.end;

      retainWithAttributes(matchStart + 1, matchEnd - 1, const ItalicAttribute().toJson());
    }

    // Get remaining text length.
    final remainingLength = affectedWords.length - previousEndRelativeIndex;

    // Remove italic from remaining non-italic text.
    formatterDelta.retain(remainingLength);

    // Build resulting change delta.
    return baseDelta.compose(formatterDelta);
  }
}
```

To apply any custom `Rule` you can use `setCustomRules` that is exposed on `Document`

```dart
quillController.document.setCustomRules([const AutoFormatItalicRule()]);
```

You can see a example video [here](https://e.pcloud.link/publink/show?code=XZ2NzgZrb888sWjuxFjzWoBpe7HlLymKp3V)
