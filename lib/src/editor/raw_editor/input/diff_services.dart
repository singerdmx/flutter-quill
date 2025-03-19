import 'package:flutter/services.dart';
import '../../../delta/delta_diff.dart';

/// Return a list of the change type that was do it to the content of the editor
TextEditingDelta getTextEditingDelta(
  TextEditingValue oldValue,
  TextEditingValue newValue,
) {
  // we need to check why sometimes in android, when we place the caret
  // at a position, it moves backward unexpectly. By now, i think that we need to use
  // the removed Debounce class to wait for the android soft-keyboard events
  // since on android, non-text-update is called more times that we think
  final currentText = oldValue.text;
  final diff = getDiff(
    currentText,
    newValue.text,
    newValue.selection.extentOffset,
  );
  if (diff.inserted.isEmpty && diff.deleted.isEmpty) {
    return TextEditingDeltaNonTextUpdate(
      oldText: newValue.text,
      selection: newValue.selection,
      composing: newValue.composing,
    );
  } else if (diff.inserted.isNotEmpty && diff.deleted.isEmpty) {
    return TextEditingDeltaInsertion(
      oldText: currentText,
      textInserted: diff.inserted,
      insertionOffset: diff.start,
      selection: newValue.selection,
      composing: newValue.composing,
    );
  } else if (diff.inserted.isEmpty && diff.deleted.isNotEmpty) {
    return TextEditingDeltaDeletion(
      oldText: currentText,
      selection: newValue.selection,
      composing: newValue.composing,
      deletedRange: TextRange(
        start: diff.start,
        end: diff.start + diff.deleted.length,
      ),
    );
  } else if (diff.inserted.isNotEmpty && diff.deleted.isNotEmpty) {
    return TextEditingDeltaReplacement(
      oldText: currentText,
      selection: newValue.selection,
      composing: newValue.composing,
      replacementText: diff.inserted,
      replacedRange: TextRange(
        start: diff.start,
        end: diff.start + diff.deleted.length,
      ),
    );
  }
  throw UnsupportedError('Unknown diff: $diff');
}
