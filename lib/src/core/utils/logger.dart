import 'dart:async' show Zone;
import 'dart:developer' as dev show log;

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:meta/meta.dart' show immutable;

/// Simple logger for the quill libraries
///
/// it log only if [kDebugMode] is true
/// so only for development mode and not in production
///
@immutable
class QuillLogger {
  const QuillLogger._();

  static bool shouldLog() {
    return kDebugMode;
  }

  static void log<T>(
    T message, {
    DateTime? time,
    int? sequenceNumber,
    int level = 0,
    String name = '',
    Zone? zone,
    StackTrace? stackTrace,
  }) {
    if (!shouldLog()) {
      return;
    }
    dev.log(
      message.toString(),
      time: time,
      sequenceNumber: sequenceNumber,
      level: level,
      name: name,
      zone: zone,
      stackTrace: stackTrace,
    );
  }

  static void error<T>(
    T message, {
    DateTime? time,
    int? sequenceNumber,
    int level = 0,
    String name = '',
    Zone? zone,
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (!shouldLog()) {
      return;
    }

    dev.log(
      message.toString(),
      time: time,
      sequenceNumber: sequenceNumber,
      level: level,
      name: name,
      zone: zone,
      error: error,
      stackTrace: stackTrace,
    );
  }
}
