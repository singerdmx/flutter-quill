import 'package:flutter_quill/models/quill_delta.dart';
import 'package:tuple/tuple.dart';

import 'document.dart';

class History {
  final HistoryStack stack = HistoryStack.empty();

  get hasUndo => stack.undo.isNotEmpty;

  get hasRedo => stack.redo.isNotEmpty;

  /// used for disable redo or undo function
  bool ignoreChange;

  int lastRecorded;

  /// Collaborative editing's conditions should be true
  final bool userOnly;

  ///max operation count for undo
  final int maxStack;

  ///record delay
  final int interval;

  History(
      {this.ignoreChange = false,
      this.interval = 400,
      this.maxStack = 100,
      this.userOnly = false,
      this.lastRecorded = 0});

  void handleDocChange(Tuple3<Delta, Delta, ChangeSource> change) {
    if (ignoreChange) return;
    if (!userOnly || change.item3 == ChangeSource.LOCAL) {
      record(change.item2, change.item1);
    } else {
      transform(change.item2);
    }
  }

  void clear() {
    stack.clear();
  }

  void record(Delta change, Delta before) {
    if (change.isEmpty) return;
    stack.redo.clear();
    Delta undoDelta = change.invert(before);
    final timeStamp = DateTime.now().millisecondsSinceEpoch;

    if (lastRecorded + interval > timeStamp && stack.undo.isNotEmpty) {
      final lastDelta = stack.undo.removeLast();
      undoDelta = undoDelta.compose(lastDelta);
    } else {
      lastRecorded = timeStamp;
    }

    if (undoDelta.isEmpty) return;
    stack.undo.add(undoDelta);

    if (stack.undo.length > maxStack) {
      stack.undo.removeAt(0);
    }
  }

  ///
  ///It will override pre local undo delta,replaced by remote change
  ///
  void transform(Delta delta) {
    transformStack(this.stack.undo, delta);
    transformStack(this.stack.redo, delta);
  }

  void transformStack(List<Delta> stack, Delta delta) {
    for (int i = stack.length - 1; i >= 0; i -= 1) {
      final oldDelta = stack[i];
      stack[i] = delta.transform(oldDelta, true);
      delta = oldDelta.transform(delta, false);
      if (stack[i].length == 0) {
        stack.removeAt(i);
      }
    }
  }

  Tuple2 _change(Document doc, List<Delta> source, List<Delta> dest) {
    if (source.length == 0) {
      return new Tuple2(false, 0);
    }
    Delta delta = source.removeLast();
    // look for insert or delete
    int? len = 0;
    List<Operation> ops = delta.toList();
    for (var i = 0; i < ops.length; i++) {
      if (ops[i].key == Operation.insertKey) {
        len = ops[i].length;
      } else if (ops[i].key == Operation.deleteKey) {
        len = ops[i].length! * -1;
      }
    }
    Delta base = Delta.from(doc.toDelta());
    Delta inverseDelta = delta.invert(base);
    dest.add(inverseDelta);
    this.lastRecorded = 0;
    this.ignoreChange = true;
    doc.compose(delta, ChangeSource.LOCAL);
    this.ignoreChange = false;
    return new Tuple2(true, len);
  }

  Tuple2 undo(Document doc) {
    return _change(doc, stack.undo, stack.redo);
  }

  Tuple2 redo(Document doc) {
    return _change(doc, stack.redo, stack.undo);
  }
}

class HistoryStack {
  final List<Delta> undo;
  final List<Delta> redo;

  HistoryStack.empty()
      : undo = [],
        redo = [];

  void clear() {
    undo.clear();
    redo.clear();
  }
}
