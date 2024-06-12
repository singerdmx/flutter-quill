import 'package:meta/meta.dart';

import 'clipboard_service.dart';
import 'default_clipboard_service.dart';

@immutable
class ClipboardServiceProvider {
  const ClipboardServiceProvider._();
  static ClipboardService _instance = DefaultClipboardService();
  static ClipboardService get instacne => _instance;

  static void setInstance(ClipboardService service) {
    _instance = service;
  }

  static void setInstanceToDefault() {
    _instance = DefaultClipboardService();
  }
}
