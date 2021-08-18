import 'dart:ui' as ui;

class PlatformViewRegistry {
  static void registerViewFactory(String viewId, dynamic cb) {
    ui.platformViewRegistry.registerViewFactory(viewId, cb);
  }
}
