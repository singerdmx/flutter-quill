import 'dart:async';
import 'dart:ui';

class Debounce {
  static final Map<String, Timer> _actions = {};

  static void debounce(
    String key,
    Duration duration,
    VoidCallback callback,
  ) {
    if (duration == Duration.zero) {
      // Call immediately
      callback();
      cancel(key);
    } else {
      cancel(key);
      _actions[key] = Timer(
        duration,
        () {
          callback();
          cancel(key);
        },
      );
    }
  }

  static void cancel(String key) {
    _actions[key]?.cancel();
    _actions.remove(key);
  }

  static void clear() {
    _actions
      ..forEach((key, timer) {
        timer.cancel();
      })
      ..clear();
  }
}
