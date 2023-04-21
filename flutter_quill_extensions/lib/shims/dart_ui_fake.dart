// ignore_for_file: avoid_classes_with_only_static_members, camel_case_types, lines_longer_than_80_chars

import 'package:universal_html/html.dart' as html;

// Fake interface for the logic that this package needs from (web-only) dart:ui.
// This is conditionally exported so the analyzer sees these methods as available.

typedef PlatroformViewFactory = html.Element Function(int viewId);

/// Shim for web_ui engine.PlatformViewRegistry
/// https://github.com/flutter/engine/blob/master/lib/web_ui/lib/ui.dart#L62
class platformViewRegistry {
  /// Shim for registerViewFactory
  /// https://github.com/flutter/engine/blob/master/lib/web_ui/lib/ui.dart#L72
  static dynamic registerViewFactory(
      String viewTypeId, PlatroformViewFactory viewFactory) {}
}

/// Shim for web_ui engine.AssetManager
/// https://github.com/flutter/engine/blob/master/lib/web_ui/lib/src/engine/assets.dart#L12
class webOnlyAssetManager {
  static dynamic getAssetUrl(String asset) {}
}
