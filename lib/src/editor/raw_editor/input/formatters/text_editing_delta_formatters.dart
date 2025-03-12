import 'dart:math';
import 'package:flutter/services.dart';
import 'package:meta/meta.dart';

const String _whitespace = ' ';
const int _whitespaceLen = _whitespace.length;

// Extension on TextEditingDelta to provide a generic formatting method.
// This method checks the type of the TextEditingDelta and calls the appropriate
// formatting method for the specific delta type (insertion, deletion, replacement, or non-text update).
// If the delta type is not recognized, it throws an UnimplementedError.
@internal
@experimental
extension GeneralTextEditingFormatter on TextEditingDelta {
  TextEditingDelta format() {
    if (this is TextEditingDeltaInsertion) {
      return (this as TextEditingDeltaInsertion).format();
    } else if (this is TextEditingDeltaDeletion) {
      return (this as TextEditingDeltaDeletion).format();
    } else if (this is TextEditingDeltaReplacement) {
      return (this as TextEditingDeltaReplacement).format();
    } else if (this is TextEditingDeltaNonTextUpdate) {
      return (this as TextEditingDeltaNonTextUpdate).format();
    }
    throw UnimplementedError();
  }
}

// Extension on TextEditingDeltaInsertion to format insertion deltas.
// Adjusts the oldText, insertionOffset, selection, and composing properties
// by shifting them based on a predefined whitespace length.
@internal
@experimental
extension TextInsertionFormatter on TextEditingDeltaInsertion {
  TextEditingDeltaInsertion format() => TextEditingDeltaInsertion(
        oldText: oldText << _whitespaceLen,
        textInserted: textInserted,
        insertionOffset: insertionOffset - _whitespaceLen,
        selection: selection << _whitespaceLen,
        composing: composing << _whitespaceLen,
      );
}

// Extension on TextEditingDeltaDeletion to format deletion deltas.
// Adjusts the oldText, deletedRange, selection, and composing properties
// by shifting them based on a predefined whitespace length.
@internal
@experimental
extension TextDeletionFormatter on TextEditingDeltaDeletion {
  TextEditingDeltaDeletion format() => TextEditingDeltaDeletion(
        oldText: oldText << _whitespaceLen,
        deletedRange: deletedRange << _whitespaceLen,
        selection: selection << _whitespaceLen,
        composing: composing << _whitespaceLen,
      );
}

// Extension on TextEditingDeltaReplacement to format replacement deltas.
// Adjusts the oldText, replacedRange, selection, and composing properties
// by shifting them based on a predefined whitespace length.
@internal
@experimental
extension TextReplacementFormatter on TextEditingDeltaReplacement {
  TextEditingDeltaReplacement format() => TextEditingDeltaReplacement(
        oldText: oldText << _whitespaceLen,
        replacementText: replacementText,
        replacedRange: replacedRange << _whitespaceLen,
        selection: selection << _whitespaceLen,
        composing: composing << _whitespaceLen,
      );
}

// Extension on TextEditingDeltaNonTextUpdate to format non-text update deltas.
// Adjusts the oldText, selection, and composing properties
// by shifting them based on a predefined whitespace length.
@internal
@experimental
extension NonTextUpdateFormatter on TextEditingDeltaNonTextUpdate {
  TextEditingDeltaNonTextUpdate format() => TextEditingDeltaNonTextUpdate(
        oldText: oldText << _whitespaceLen,
        selection: selection << _whitespaceLen,
        composing: composing << _whitespaceLen,
      );
}

// Extension on TextRange to provide shifting functionality.
// Allows shifting the start and end positions of a TextRange by a specified amount.
// If the range is invalid, it returns the original range.
@internal
@experimental
extension ShiftTextRange on TextRange {
  TextRange operator <<(int shiftAmount) => shift(-shiftAmount);

  TextRange shift(int shiftAmount) => !isValid
      ? this
      : TextRange(
          start: max(0, start + shiftAmount),
          end: max(0, end + shiftAmount),
        );
}

// Extension on String to provide shifting functionality.
// Allows shifting the string by removing a specified number of characters from the beginning.
// If the shift amount is greater than the string length, it returns an empty string.
@internal
@experimental
extension ShiftString on String {
  String operator <<(int shiftAmount) => shift(shiftAmount);

  String shift(int shiftAmount) {
    if (shiftAmount > length) {
      return '';
    }
    return substring(shiftAmount);
  }
}

// Extension on TextSelection to provide shifting functionality.
// Allows shifting the baseOffset and extentOffset of a TextSelection by a specified amount.
// Ensures the offsets do not go below zero.
@internal
@experimental
extension ShiftTextSelection on TextSelection {
  TextSelection operator <<(int shiftAmount) => shift(-shiftAmount);

  TextSelection shift(int shiftAmount) => TextSelection(
        baseOffset: max(0, baseOffset + shiftAmount),
        extentOffset: max(0, extentOffset + shiftAmount),
      );
}
