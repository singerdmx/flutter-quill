import 'dart:math' as math;

import '../operation/operation.dart';
import 'delta.dart';

/// Specialized iterator for [Delta]s.
class DeltaIterator {
  DeltaIterator(this.delta) : _modificationCount = delta.modificationCount;

  static const int maxLength = 1073741824;

  final Delta delta;
  final int _modificationCount;
  int _index = 0;
  int _offset = 0;

  bool get isNextInsert => nextOperationKey == Operation.insertKey;

  bool get isNextDelete => nextOperationKey == Operation.deleteKey;

  bool get isNextRetain => nextOperationKey == Operation.retainKey;

  String? get nextOperationKey {
    if (_index < delta.length) {
      return delta.elementAt(_index).key;
    } else {
      return null;
    }
  }

  bool get hasNext => peekLength() < maxLength;

  /// Returns length of next operation without consuming it.
  ///
  /// Returns [maxLength] if there is no more operations left to iterate.
  int peekLength() {
    if (_index < delta.length) {
      final operation = delta.operations[_index];
      return operation.length! - _offset;
    }
    return maxLength;
  }

  /// Consumes and returns next operation.
  ///
  /// Optional [length] specifies maximum length of operation to return. Note
  /// that actual length of returned operation may be less than specified value.
  ///
  /// If this iterator reached the end of the Delta then returns a retain
  /// operation with its length set to [maxLength].
  // TODO: Note that we used double.infinity as the default value
  // for length here
  //       but this can now cause a type error since operation length is
  //       expected to be an int. Changing default length to [maxLength] is
  //       a workaround to avoid breaking changes.
  Operation next([int length = maxLength]) {
    if (_modificationCount != delta.modificationCount) {
      throw ConcurrentModificationError(delta);
    }

    if (_index < delta.length) {
      final op = delta.elementAt(_index);
      final opKey = op.key;
      final opAttributes = op.attributes;
      final currentOffset = _offset;
      final actualLength = math.min(op.length! - currentOffset, length);
      if (actualLength == op.length! - currentOffset) {
        _index++;
        _offset = 0;
      } else {
        _offset += actualLength;
      }
      final opData = op.isInsert && op.data is String
          ? (op.data as String)
              .substring(currentOffset, currentOffset + actualLength)
          : op.data;
      final opIsNotEmpty =
          opData is String ? opData.isNotEmpty : true; // embeds are never empty
      final opLength = opData is String ? opData.length : 1;
      final opActualLength = opIsNotEmpty ? opLength : actualLength;
      return Operation(opKey, opActualLength, opData, opAttributes);
    }
    return Operation.retain(length);
  }

  /// Skips [length] characters in source delta.
  ///
  /// Returns last skipped operation, or `null` if there was nothing to skip.
  Operation? skip(int length) {
    var skipped = 0;
    Operation? op;
    while (skipped < length && hasNext) {
      final opLength = peekLength();
      final skip = math.min(length - skipped, opLength);
      op = next(skip);
      skipped += op.length!;
    }
    return op;
  }
}
