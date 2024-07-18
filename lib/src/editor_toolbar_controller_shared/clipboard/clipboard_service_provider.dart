import 'package:flutter/foundation.dart' show immutable;
import 'clipboard_service.dart';
import 'default_clipboard_service.dart';

@immutable
class ClipboardServiceProvider {
  const ClipboardServiceProvider._();
  static ClipboardService _instance = DefaultClipboardService();

  static ClipboardService get instance => _instance;

  @Deprecated('instacne is a typo, use instance instead.')
  static ClipboardService get instacne => instance;

  static void setInstance(ClipboardService service) {
    _instance = service;
  }

  static void setInstanceToDefault() {
    _instance = DefaultClipboardService();
  }
}
