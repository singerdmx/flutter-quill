import 'package:flutter/services.dart';
import '../../delta/delta_diff.dart';

/// Return a list of the change type that was do it to the content of the editor
List<TextEditingDelta> getTextEditingDeltas(
  TextEditingValue? oldValue,
  TextEditingValue newValue,
) {
  if (oldValue == null || oldValue.text == newValue.text) {
    return [
      TextEditingDeltaNonTextUpdate(
        oldText: newValue.text,
        selection: newValue.selection,
        composing: newValue.composing,
      ),
    ];
  }
  final currentText = oldValue.text;
  final diff = getDiff(
    currentText,
    newValue.text,
    newValue.selection.extentOffset,
  );
  if (diff.inserted.isNotEmpty && diff.deleted.isEmpty) {
    return [
      TextEditingDeltaInsertion(
        oldText: currentText,
        textInserted: diff.inserted,
        insertionOffset: diff.start,
        selection: newValue.selection,
        composing: newValue.composing,
      ),
    ];
  } else if (diff.inserted.isEmpty && diff.deleted.isNotEmpty) {
    return [
      TextEditingDeltaDeletion(
        oldText: currentText,
        selection: newValue.selection,
        composing: newValue.composing,
        deletedRange: TextRange(
          start: diff.start,
          end: diff.start + diff.deleted.length,
        ),
      ),
    ];
  } else if (diff.inserted.isNotEmpty && diff.deleted.isNotEmpty) {
    return [
      TextEditingDeltaReplacement(
        oldText: currentText,
        selection: newValue.selection,
        composing: newValue.composing,
        replacementText: diff.inserted,
        replacedRange: TextRange(
          start: diff.start,
          end: diff.start + diff.deleted.length,
        ),
      ),
    ];
  } else if (diff.inserted.isEmpty && diff.deleted.isEmpty) {
    return [
      TextEditingDeltaNonTextUpdate(
        oldText: newValue.text,
        selection: newValue.selection,
        composing: newValue.composing,
      ),
    ];
  }
  throw UnsupportedError('Unknown diff: $diff');
}
