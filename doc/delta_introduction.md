# What is Delta?

`Delta` is a structured format used to represent text editing operations consistently and efficiently.
It is especially useful in collaborative editors where multiple users may be editing the same document simultaneously.

## How does Delta work?

`Delta` consists of a list of operations.
Each operation describes a change in the document's content.
The operations can be of three types: insertion (`insert`), deletion (`delete`), and retention (`retain`).
These operations are combined to describe any change in the document's state.

You can import `Delta` and `Operation` class using:

```dart
import 'package:flutter_quill/dart_quill_delta.dart';
```

# What is a `Operation`?

Operations are the actions performed on the document to modify its content.
Each operation can be an insertion,
deletion, or retention, and is executed sequentially to transform the document's state.

## How Do `Operations` Work?

`Operations` are applied in the order they are defined in the `Delta`.
Starting with the initial state of the
`Document`, the operations are applied one by one, updating the document's state at each step.

Example of a `Operation` Code:

```dart
[
    // Adds the text "Hello" to the editor's content
    { "insert": "Hello" },
    // Retains the first 5 characters of the existing content,
    // and applies the "bold" attribute to those characters.
    { "retain": 5, "attributes": { "bold": true } },
    // Deletes 2 characters starting from the current position in the editor's content.
    { "delete": 2 }
]
```

# Types of Operations in Delta

## 1. Insertion (`Insert`)

An insertion adds new content to the document. The `Insert` operation contains the text or data being added.

Example of `Insert` operation:

```dart
import 'package:flutter_quill/dart_quill_delta.dart';

void main() {
  // Create a Delta with a text insertion
  final delta = Delta()
    ..insert('Hello, world!\n')
    ..insert('This is an example.\n', {'bold': true})
    ..delete(10); // Remove the first 10 characters

  print(delta); // Output: [{insert: "Hello, world!\n"}, {insert: "This is an example.\n", attributes: {bold: true}}, {delete: 10}]
}
```

## 2. Deletion (`Delete`)

In Quill, operations are a way to represent changes to the editor's content. Each operation has a type and a set of
properties that indicate what has changed and how.`Delete` operations are a specific type of operation that is used to
remove content from the editor.

## Delete Operations

A Delete operation is used to remove a portion of the editor's content. The Delete operation has the following format:

```dart
Delta()
 ..retain(<number>)
 ..delete(<number>);
```

Where:

- **retain**: (Optional) The number of characters to retain before deletion is performed.
- **delete**: The number of characters to delete.

Basic example

Let's say you have the following content in the editor:

```Arduino
"Hello, world!"
```

And you want to remove the word "world". The corresponding to Delete operation could be:

```dart
Delta()
 ..retain(6)
 ..delete(7);
```

Here the first **7** characters are being retained ("Hello, ") and then 6 characters are being removed ("world!").

### Behavior of Delete Operations

**Text Deletion**: The `Delete` operation removes text in the editor document. The characters removed are those that are
in the range specified by the operation.

**Combination with retain**: The `Delete` operation is often combined with the retain operation to specify which part of
the content should remain intact and which part should be removed. For example, if you want to delete a specific section
of a text, you can use retaining to keep the text before and after the section to be deleted.

**Range Calculation**: When a `Delete` operation is applied, the range of text to be deleted is calculated based on the
value of retaining and delete. It is important to understand how retain and delete are combined to perform correct
deletion.

Example of `Delete` operation using `QuillController`

```dart
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/dart_quill_delta.dart';

QuillController _quillController = QuillController(
    document: Document.fromJson([{'insert': 'Hello, world!'}]),
    selection: TextSelection.collapsed(offset: 0),
);

// Create a delta with the retain and delete operations
final delta = Delta()
  ..retain(6) // Retain "Hello, "
  ..delete(7); // Delete "world!"

// Apply the delta to update the content of the editor
_quillController.compose(delta, ChangeSource.local);
```

In this example, the current content of the editor is updated to reflect the removal of the word "world."

## 3. Retention (`Retain`)

`Retain` operations are particularly important because they allow you to apply attributes to specific parts of the
content without modifying the content itself. A Retain operation consists of two parts:

- **Index**: The length of the content to retain unchanged.
- **Attributes**: An optional object containing the attributes to apply.

Example of a `Retain` Operation

Suppose we have the following content in an editor:

```arduino
"Hello world"
```

And we want to apply bold formatting to the word "world."
The `Retain` operation would be represented in a `Delta` as
follows:

```dart
[
    { "insert": "Hello, " },
    { "retain": 7 },
    { "retain": 5, "attributes": { "bold": true } }
]
```

This Delta is interpreted as follows:

- `{ "retain": 7 }`: Retains the first **7** characters ("Hello, ").
- `{ "retain": 5, "attributes": { "bold": true } }`: Retains the next **5** characters ("world") and applies the bold
  attribute.

### Applications of Retain

Retain operations are useful for various tasks in document editing, such as:

- **Text Formatting**: Applying styles (bold, italic, underline, etc.) to specific segments without altering the
  content.
- **Annotations**: Adding metadata or annotations to specific sections of text.
- **Content Preservation**: Ensuring that certain parts of the document remain unchanged during complex editing
  operations.

Using Directly `Delta` class:

```dart
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/dart_quill_delta.dart';

void main() {
  // Create a Delta that retains 10 characters
 QuillController _quillController = QuillController(
    document: Document.fromJson([{'insert': 'Hello, world!'}]),
    selection: TextSelection.collapsed(offset: 0),
 );

 // Create a delta with the retain and delete operations
 final delta = Delta()
    ..retain(6) // Retain "Hello, "

 // Apply the delta to update the content of the editor
 _quillController.compose(delta, ChangeSource.local);
}
```

# Transformations

Transformations are used to combine two Deltas and produce a third Delta that represents the combination of both
operations.

Example 1: Transformation with Deletions

Deltas to combine:

- **Delta A**: `[{insert: "Flutter"}, {retain: 3}, {insert: "Quill"}]`
- **Delta B**: `[{retain: 6}, {delete: 4}, {insert: "Editor"}]`

```dart

import 'package:flutter_quill/dart_quill_delta.dart' as quill;

void main() {
 // Defining Delta A
 final deltaA = quill.Delta()
 ..insert('Flutter')
 ..retain(3)
 ..insert('Quill');

 // Defining Delta B
 final deltaB = quill.Delta()
 ..retain(7) // retain: Flutter
 ..delete(5) // delete: Quill
 ..insert('Editor');

 // applying transformation
 final result = deltaA.transform(deltaB);

 print(result.toJson()); // output: [{insert: "FlutterEditor"}]
}
```

Example 2: Complex Transformation

Deltas to combine:

- **Delta A**: `[{insert: "Hello World"}]`
- **Delta B**: `[{retain: 6}, {delete: 5}, {insert: "Flutter"}]`

```dart
import 'package:flutter_quill/dart_quill_delta.dart' as quill;

void main() {

 // Defining Delta A
 final deltaA = quill.Delta()
 ..insert('Hello World');

 // Defining Delta B
 final deltaB = quill.Delta()
 ..retain(6) // retain: 'Hello '
 ..delete(5) // delete: 'World'
 ..insert('Flutter');

 // Applying transformations
 final result = deltaA.transform(deltaB);

 print(result.toJson()); // output: [{insert: "Hello Flutter"}]
}
```

# Why Use Delta Instead of Another Format?

Delta offers a structured and efficient way to represent changes in text documents, especially in collaborative
environments.
Its operation-based design allows for easy synchronization, transformation, and conflict handling, which
is essential for real-time text editing applications.
Other formats may not provide the same level of granularity and
control over edits and transformations.
