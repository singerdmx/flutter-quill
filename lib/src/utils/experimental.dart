import 'package:flutter/foundation.dart' show immutable;

@immutable
class Experimental {
  const Experimental([this.reason = 'Experimental feature']);
  final String reason;
}
