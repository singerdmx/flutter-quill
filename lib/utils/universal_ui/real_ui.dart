import 'dart:ui' as ui;

class PlatformViewRegistry {
  static registerViewFactory(String viewId, dynamic cb) {
    ui.platformViewRegistry.registerViewFactory(viewId, cb);
  }
}
