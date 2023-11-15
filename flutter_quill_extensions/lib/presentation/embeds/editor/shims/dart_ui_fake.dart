// import 'package:universal_html/html.dart' as html;

// Fake interface for the logic that this package needs from (web-only) dart:ui.
// This is conditionally exported so the analyzer sees these methods as
// available.

// typedef PlatroformViewFactory = html.Element Function(int viewId);

// /// Shim for web_ui engine.PlatformViewRegistry
// /// https://github.com/flutter/engine/blob/master/lib/web_ui/lib/ui.dart#L62
// class PlatformViewRegistry {
//   /// Shim for registerViewFactory
//   /// https://github.com/flutter/engine/blob/master/lib/web_ui/lib/ui.dart#L72
//   static dynamic registerViewFactory(
//       String viewTypeId, PlatroformViewFactory viewFactory) {}
// }

// /// Shim for web_ui engine.AssetManager
// /// https://github.com/flutter/engine/blob/master/lib/web_ui/lib/src/engine/assets.dart#L12
// class WebOnlyAssetManager {
//   static dynamic getAssetUrl(String asset) {}
// }

class PlatformViewRegistry {
  /// Register [viewType] as being created by the given [viewFactory].
  ///
  /// [viewFactory] can be any function that takes an integer and optional
  /// `params` and returns an `HTMLElement` DOM object.
  bool registerViewFactory(
    String viewType,
    Function viewFactory, {
    bool isVisible = true,
  }) {
    return false;
  }

  /// Returns the view previously created for [viewId].
  ///
  /// Throws if no view has been created for [viewId].
  Object getViewById(int viewId) {
    return '';
  }
}
