# What is an `Attribute`

An `attribute` is a property or characteristic that can be applied to text or a section of text within the editor to
change its appearance or behavior.
Attributes allow the user to style the text in various ways.

# How do attributes work?

An Attribute is applied to selected segments of text in the editor. Each attribute has an identifier and a value that
determines how it should be applied to the text. For example, to apply bold to a text, an attribute with the
identifier "bold" is used. When a text is selected and an attribute is applied, the editor updates the visual
representation of the text in real time.

# Scope of an `Attribute`

The attributes have a Scope that limit where start and end the `Attribute`.
The Scope is called as `AttributeScope`.
It has these options to be selected:

```dart
enum AttributeScope {
  inline, // just the selected text will apply the attribute (like: bold, italic or strike)
  block, // all the paragraph will apply the attribute (like: Header, Alignment or CodeBlock)
  embeds, // the attr will be taked as a different part of any paragraph or line, working as a block (By now not works as an inline)
  ignore, // the attribute can be applied, but on Retain operations will be ignored
}
```

# How looks a `Attribute`

The original `Attribute` class that you need to extend from if you want to create any custom attribute looks like:

```dart
class Attribute<T> {
  const Attribute(
    this.key,
    this.scope,
    this.value,
  );

  /// Unique key of this attribute.
  final String key;
  final AttributeScope scope;
  final T value;
}
```

The key of any `Attribute` must be **unique** to avoid any conflict with the default implementations.

#### Why `Attribute` class contains a **Generic** as a value

This is the same reason why we can create `Block` styles, `Inline` styles and `Custom` styles. Having a **Generic** type
value let us define any value as we want to recognize them later and apply it.

### Example of an default attribute

##### Inline Scope:

```dart
class BoldAttribute extends Attribute<bool> {
  const BoldAttribute() : super('bold', AttributeScope.inline, true);
}
```

##### Block Scope:

```dart
class HeaderAttribute extends Attribute<int?> {
  const HeaderAttribute({int? level})
      : super('header', AttributeScope.block, level);
}
```

If you want to see an example of an embed implementation you can see
it [here](https://github.com/singerdmx/flutter-quill/blob/master/doc/custom_embed_blocks.md)

### Example of a Custom Inline `Attribute`

##### The Attribute

```dart
import 'package:flutter_quill/flutter_quill.dart';

const String highlightKey = 'highlight';
const AttributeScope highlightScope = AttributeScope.inline;

class HighlightAttr extends Attribute<bool?> {
  HighlightAttr(bool? value) : super(highlightKey, highlightScope, value);
}
```

##### Where should we add this `HighlightAttr`?

On `QuillEditor` or `QuillEditorConfigurations` **doesn't exist** a param that let us pass our `Attribute`
implementations. To make this more easy, we can use just `customStyleBuilder` param from `QuillEditorConfigurations`,
that let us define a function to return a `TextStyle`. With this, we can define now our `HighlightAttr`

##### The editor

```dart
QuillEditor.basic(
      controller: controller,
      configurations: QuillEditorConfigurations(
        customStyleBuilder: (Attribute<dynamic> attribute) {
          if (attribute.key.equals(highlightKey)) {
            return TextStyle(color: Colors.black, backgroundColor: Colors.yellow);
          }
          //default paragraph style
          return TextStyle();
        },
      ),
);
```

Then, it should look as:

![HighlightAttr applied on the Quill Editor](https://github.com/user-attachments/assets/89c7bda5-f0de-4832-bcaa-8e0ccbe9be18)
