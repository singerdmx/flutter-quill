import 'package:flutter/foundation.dart' show immutable;

@immutable
class HistoryChanged {
  const HistoryChanged(
    this.changed,
    this.len,
  );

  final bool changed;
  final int len;
}
