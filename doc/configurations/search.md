# Search

You can search the text of your document using the search toolbar button.
Enter the text and use the up/down buttons to move to the previous/next selection.
Use the 3 vertical dots icon to turn on case-sensitivity or whole word constraints.

## Search configuration options

By default, the content of Embed objects are not searched.
You can enable search by setting the [searchEmbedMode] in searchConfigurations:

```dart
    MyQuillEditor(
      controller: _controller,
      configurations: QuillEditorConfigurations(
        searchConfigurations: const QuillSearchConfigurations(
          searchEmbedMode: SearchEmbedMode.plainText,
        ),
      ),
      ...
    ),
```

### SearchEmbedMode.none (default option)

Embed objects will not be included in searches.

### SearchEmbedMode.rawData

This is the simplest search option when your Embed objects use simple text that is also displayed to the user.
This option allows searching within custom Embed objects using the node's raw data [Embeddable.data].

### SearchEmbedMode.plainText

This option is best for complex Embeds where the raw data contains text that is not visible to the user and/or contains textual data that is not suitable for searching.
For example, searching for '2024' would not be meaningful if the raw data is the full path of an image object (such as /user/temp/20240125/myimage.png).
In this case the image would be shown as a search hit but the user would not know why.

This option allows searching within custom Embed objects using an override to the [toPlainText] method.

```dart
  class MyEmbedBuilder extends EmbedBuilder {

    @override
    String toPlainText(Embed node) {
      /// Convert [node] to the text that can be searched.
      /// For example: convert to MyEmbeddable and use the
      ///   properties to return the searchable text.
      final m = MyEmbeddable(node.value.data);
      return  '${m.property1}\t${m.property2}';
    }
    ...
```
If [toPlainText] is not overridden, the base class implementation returns [Embed.kObjectReplacementCharacter] which is not searchable.

### Strategy for mixed complex and simple Embed objects

Select option [SearchEmbedMode.plainText] and override [toPlainText] to provide the searchable text. For your simple Embed objects provide the following override:

```dart
  class MySimpleEmbedBuilder extends EmbedBuilder {

    @override
    String toPlainText(Embed node) {
      return node.value.data;
    }
    ...
```
