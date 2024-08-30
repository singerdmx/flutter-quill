import 'dart:math' as math;
import 'dart:ui' show TextDirection;

import 'package:flutter/foundation.dart' show immutable;

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

/* Get diff operation between old text and new text */
Diff getDiff(String oldText, String newText, int cursorPosition) {
  var end = oldText.length;
  final delta = newText.length - end;
  for (final limit = math.max(0, cursorPosition - delta);
      end > limit && oldText[end - 1] == newText[end + delta - 1];
      end--) {}
  var start = 0;
  for (final startLimit = cursorPosition - math.max(0, delta);
      start < startLimit && oldText[start] == newText[start];
      start++) {}
  final deleted = (start >= end) ? '' : oldText.substring(start, end);
  final inserted = newText.substring(start, end + delta);
  return Diff(
    start: start,
    deleted: deleted,
    inserted: inserted,
  );
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
