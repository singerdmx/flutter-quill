import 'package:meta/meta.dart' show experimental;

import 'clipboard_service.dart';
import 'default_clipboard_service.dart';

@experimental
class ClipboardServiceProvider {
  ClipboardServiceProvider._();
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
