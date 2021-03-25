library universal_ui;

import 'package:flutter/foundation.dart';
import 'fake_ui.dart' if (dart.library.html) 'real_ui.dart' as ui_instance;

class PlatformViewRegistryFix {
  registerViewFactory(dynamic x, dynamic y) {
    if (kIsWeb) {
      ui_instance.PlatformViewRegistry.registerViewFactory(
        x,
        y,
      );
    }
  }
}

class UniversalUI {
  PlatformViewRegistryFix platformViewRegistry = PlatformViewRegistryFix();
}

var ui = UniversalUI();
