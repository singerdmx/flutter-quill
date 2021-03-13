import 'dart:math' as math;

import 'package:flutter_quill/models/quill_delta.dart';

const Set<int> WHITE_SPACE = {
  0x9,
  0xA,
  0xB,
  0xC,
  0xD,
  0x1C,
  0x1D,
  0x1E,
  0x1F,
  0x20,
  0xA0,
  0x1680,
  0x2000,
  0x2001,
  0x2002,
  0x2003,
  0x2004,
  0x2005,
  0x2006,
  0x2007,
  0x2008,
  0x2009,
  0x200A,
  0x202F,
  0x205F,
  0x3000
};

// Diff between two texts - old text and new text
class Diff {
  // Start index in old text at which changes begin.
  final int start;

  /// The deleted text
  final String deleted;

  // The inserted text
  final String inserted;

  Diff(this.start, this.deleted, this.inserted);

  @override
  String toString() {
    return 'Diff[$start, "$deleted", "$inserted"]';
  }
}

/* Get diff operation between old text and new text */
Diff getDiff(String oldText, String newText, int cursorPosition) {
  int end = oldText.length;
  int delta = newText.length - end;
  for (int limit = math.max(0, cursorPosition - delta);
      end > limit && oldText[end - 1] == newText[end + delta - 1];
      end--) {}
  int start = 0;
  for (int startLimit = cursorPosition - math.max(0, delta);
      start < startLimit && oldText[start] == newText[start];
      start++) {}
  String deleted = (start >= end) ? '' : oldText.substring(start, end);
  String inserted = newText.substring(start, end + delta);
  return Diff(start, deleted, inserted);
}

int getPositionDelta(Delta user, Delta actual) {
  if (actual.isEmpty) {
    return 0;
  }

  DeltaIterator userItr = DeltaIterator(user);
  DeltaIterator actualItr = DeltaIterator(actual);
  int diff = 0;
  while (userItr.hasNext || actualItr.hasNext) {
    final length = math.min(userItr.peekLength(), actualItr.peekLength());
    Operation userOperation = userItr.next(length as int);
    Operation actualOperation = actualItr.next(length);
    if (userOperation.length != actualOperation.length) {
      throw ('userOp ' +
          userOperation.length.toString() +
          ' does not match ' +
          ' actualOp ' +
          actualOperation.length.toString());
    }
    if (userOperation.key == actualOperation.key) {
      continue;
    } else if (userOperation.isInsert && actualOperation.isRetain) {
      diff -= userOperation.length!;
    } else if (userOperation.isDelete && actualOperation.isRetain) {
      diff += userOperation.length!;
    } else if (userOperation.isRetain && actualOperation.isInsert) {
      String? operationTxt = '';
      if (actualOperation.data is String) {
        operationTxt = actualOperation.data as String?;
      }
      if (operationTxt!.startsWith('\n')) {
        continue;
      }
      diff += actualOperation.length!;
    }
  }
  return diff;
}
