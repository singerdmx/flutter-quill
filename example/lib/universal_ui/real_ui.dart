import 'dart:ui' if (dart.library.html) 'dart:ui_web' as ui;

class PlatformViewRegistry {
  static void registerViewFactory(String viewId, dynamic cb) {
    ui.platformViewRegistry.registerViewFactory(viewId, cb);
  }
}
