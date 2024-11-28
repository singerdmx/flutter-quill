import 'package:meta/meta.dart' show experimental;

import 'clipboard_service.dart';
import 'default_clipboard_service.dart';

@experimental
abstract final class ClipboardServiceProvider {
  static ClipboardService _instance = DefaultClipboardService();

  static ClipboardService get instance => _instance;

  static void setInstance(ClipboardService service) {
    _instance = service;
  }

  static void setInstanceToDefault() {
    _instance = DefaultClipboardService();
  }
}
