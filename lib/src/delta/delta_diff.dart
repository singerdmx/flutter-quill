import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../quill_delta.dart';
import '../document/attribute.dart';
import '../document/nodes/node.dart';

// Diff between two texts - old text and new text
@immutable
class Diff {
  const Diff({
    required this.start,
    required this.deleted,
    required this.inserted,
  });

  const Diff.insert({
    required this.start,
    required this.inserted,
  }) : deleted = '';

  const Diff.noDiff({
    this.start = 0,
  })  : deleted = '',
        inserted = '';

  const Diff.delete({
    required this.start,
    required this.deleted,
  }) : inserted = '';

  /// Checks if the diff is just a delete
  bool get isDelete => inserted.isEmpty && deleted.isNotEmpty;

  /// Checks if the diff is just replace
  bool get isReplace => inserted.isNotEmpty && deleted.isNotEmpty;

  /// Checks if the diff is just an isnertion
  bool get isInsert => inserted.isNotEmpty && deleted.isEmpty;

  /// Checks if the diff has no changes
  bool get hasNoDiff => inserted.isEmpty && deleted.isEmpty;

  // Start index in old text at which changes begin.
  final int start;

  /// The deleted text
  final String deleted;

  // The inserted text
  final String inserted;

  @override
  String toString() {
    return 'Diff[$start, "$deleted", "$inserted"]';
  }
}

/// Get text changes between two strings using [oldStr] and [newStr]
/// using selection as the base with [oldSelection] and [newSelection].
///
/// Performance: O([k]) where [k] == change size (not document length)
Diff getDiff(
  String oldStr,
  String newStr,
  TextSelection oldSelection,
  TextSelection newSelection,
) {
  if (oldStr == newStr) return Diff.noDiff(start: newSelection.start);

  // 1. Calculate affected range based on selections
  final affectedRange =
      _getAffectedRange(oldStr, newStr, oldSelection, newSelection);
  var start = affectedRange.start
      .clamp(0, math.min(oldStr.length, newStr.length))
      .toInt();
  final end = affectedRange.end
      .clamp(0, math.max(oldStr.length, newStr.length))
      .toInt();

  // 2. Adjust bounds for length variations
  final oldLen = oldStr.length;
  final newLen = newStr.length;
  final lengthDiff = newLen - oldLen;

  // 3. Forward search from range start
  while (start < end &&
      start < oldLen &&
      start < newLen &&
      oldStr[start] == newStr[start]) {
    start++;
  }

  // 4. Backward search from range end
  var oldEnd = math.min(end, oldLen);
  var newEnd = math.min(end + lengthDiff, newLen);

  while (oldEnd > start &&
      newEnd > start &&
      oldStr[oldEnd - 1] == newStr[newEnd - 1]) {
    oldEnd--;
    newEnd--;
  }

  final safeOldEnd = oldEnd.clamp(start, oldStr.length);
  final safeNewEnd = newEnd.clamp(start, newStr.length);

  // 5. Extract differences
  final deleted = oldStr.substring(start, safeOldEnd);
  final inserted = newStr.substring(start, safeNewEnd);

  // 6. Validate consistency
  if (_isChangeConsistent(
      deleted, inserted, oldStr, oldSelection, newSelection)) {
    return _buildDiff(deleted, inserted, start);
  }

  // Fallback for complex cases
  return _fallbackDiff(oldStr, newStr, start, end);
}

TextRange _getAffectedRange(
  String oldStr,
  String newStr,
  TextSelection oldSel,
  TextSelection newSel,
) {
  // Calculate combined selection area
  final start = math.min(oldSel.start, newSel.start);
  final end = math.max(oldSel.end, newSel.end);

  // Expand by 20% to capture nearby changes
  //
  // We use this to avoid check all the string length
  // unnecessarily when we can use the selection as a base
  // to know where, and how was do it the change
  final expansion = ((end - start) * 0.2).round();

  return TextRange(
    start: math.max(0, start - expansion),
    end: math.min(math.max(oldStr.length, newStr.length), end + expansion),
  );
}

bool _isChangeConsistent(
  String deleted,
  String inserted,
  String oldText,
  TextSelection oldSel,
  TextSelection newSel,
) {
  final isForwardDelete = _isForwardDelete(
    deletedText: deleted,
    oldText: oldText,
    oldSelection: oldSel,
    newSelection: newSel,
  );
  if (isForwardDelete) {
    return newSel.start == oldSel.start &&
        deleted.length == (oldSel.end - oldSel.start);
  }
  final isInsert = newSel.start == newSel.end && inserted.isNotEmpty;
  final isDelete = deleted.isNotEmpty && inserted.isEmpty;

  // Insert validation
  if (isInsert) {
    return newSel.start == oldSel.start + inserted.length;
  }

  // Delete validation
  if (isDelete) {
    return oldSel.start - newSel.start == deleted.length;
  }

  return true;
}

/// Detect if the deletion was do it to forward
bool _isForwardDelete({
  required String deletedText,
  required String oldText,
  required TextSelection oldSelection,
  required TextSelection newSelection,
}) {
  // is forward delete if:
  return
      // 1. There's deleted text
      deletedText.isNotEmpty &&

          // 2. The original selection is collaped
          oldSelection.isCollapsed &&

          // 3. New and original selections has the same offset
          newSelection.isCollapsed &&
          newSelection.baseOffset == oldSelection.baseOffset &&

          // 4. The removed character if after the cursor position
          (oldSelection.baseOffset + deletedText.length <= oldText.length);
}

Diff _fallbackDiff(String oldStr, String newStr, int start, [int? end]) {
  end ??= math.min(oldStr.length, newStr.length);

  // 1. Find first divergence point
  while (start < end &&
      start < oldStr.length &&
      start < newStr.length &&
      oldStr[start] == newStr[start]) {
    start++;
  }

  // 2. Find last divergence point
  var oldEnd = oldStr.length;
  var newEnd = newStr.length;

  while (oldEnd > start &&
      newEnd > start &&
      oldStr[oldEnd - 1] == newStr[newEnd - 1]) {
    oldEnd--;
    newEnd--;
  }

  // 3. Extract differences
  final deleted = oldStr.substring(start, oldEnd);
  final inserted = newStr.substring(start, newEnd);

  return _buildDiff(deleted, inserted, start);
}

Diff _buildDiff(String deleted, String inserted, int start) {
  if (deleted.isEmpty && inserted.isEmpty) return const Diff.noDiff();

  if (deleted.isNotEmpty && inserted.isNotEmpty) {
    return Diff(
      inserted: inserted,
      start: start,
      deleted: deleted,
    );
  } else if (inserted.isNotEmpty) {
    return Diff.insert(start: start, inserted: inserted);
  } else {
    return Diff.delete(start: start, deleted: deleted);
  }
}

int getPositionDelta(Delta user, Delta actual) {
  if (actual.isEmpty) {
    return 0;
  }

  final userItr = DeltaIterator(user);
  final actualItr = DeltaIterator(actual);
  var diff = 0;
  while (userItr.hasNext || actualItr.hasNext) {
    final length = math.min(userItr.peekLength(), actualItr.peekLength());
    final userOperation = userItr.next(length);
    final actualOperation = actualItr.next(length);
    if (userOperation.length != actualOperation.length) {
      throw ArgumentError(
        'userOp ${userOperation.length} does not match actualOp '
        '${actualOperation.length}',
      );
    }
    if (userOperation.key == actualOperation.key) {
      /// Insertions must update diff allowing for type mismatch of Operation
      if (userOperation.key == Operation.insertKey) {
        if (userOperation.data is Delta && actualOperation.data is String) {
          diff += actualOperation.length!;
        }
      }
      continue;
    } else if (userOperation.isInsert && actualOperation.isRetain) {
      diff -= userOperation.length!;
    } else if (userOperation.isDelete && actualOperation.isRetain) {
      diff += userOperation.length!;
    } else if (userOperation.isRetain && actualOperation.isInsert) {
      diff += actualOperation.length!;
    }
  }
  return diff;
}

TextDirection getDirectionOfNode(Node node, [TextDirection? currentDirection]) {
  final direction = node.style.attributes[Attribute.direction.key];
  // If it is RTL, then create the opposite direction
  if (currentDirection == TextDirection.rtl && direction == Attribute.rtl) {
    return TextDirection.ltr;
  } else if (direction == Attribute.rtl) {
    return TextDirection.rtl;
  }
  return currentDirection ?? TextDirection.ltr;
}
