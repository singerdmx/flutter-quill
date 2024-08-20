library flutter_quill_extensions;

// ignore: implementation_imports
import 'package:flutter_quill/src/editor/spellchecker/spellchecker_service_provider.dart';
// ignore: implementation_imports
import 'package:flutter_quill/src/editor_toolbar_controller_shared/clipboard/clipboard_service_provider.dart';
import 'package:meta/meta.dart' show immutable;

import 'src/editor/spell_checker/simple_spell_checker_service.dart';
import 'src/editor_toolbar_controller_shared/clipboard/super_clipboard_service.dart';

export 'src/common/extensions/controller_ext.dart';
export 'src/common/utils/utils.dart';
export 'src/editor/image/image_embed.dart';
export 'src/editor/image/image_embed_types.dart';
export 'src/editor/image/image_web_embed.dart';
export 'src/editor/image/models/image_configurations.dart';
export 'src/editor/image/models/image_web_configurations.dart';
export 'src/editor/spell_checker/simple_spell_checker_service.dart';
export 'src/editor/table/table_cell_embed.dart';
export 'src/editor/table/table_embed.dart';
export 'src/editor/table/table_models.dart';
export 'src/editor/video/models/video_configurations.dart';
export 'src/editor/video/models/video_web_configurations.dart';
export 'src/editor/video/models/youtube_video_support_mode.dart';
export 'src/editor/video/video_embed.dart';
export 'src/editor/video/video_web_embed.dart';
export 'src/editor_toolbar_shared/shared_configurations.dart';
export 'src/flutter_quill_embeds.dart';
export 'src/toolbar/camera/camera_button.dart';
export 'src/toolbar/camera/models/camera_configurations.dart';
export 'src/toolbar/formula/formula_button.dart';
export 'src/toolbar/formula/models/formula_configurations.dart';
export 'src/toolbar/image/image_button.dart';
export 'src/toolbar/image/models/image_configurations.dart';
export 'src/toolbar/table/models/table_configurations.dart';
export 'src/toolbar/table/table_button.dart';
export 'src/toolbar/video/models/video.dart';
export 'src/toolbar/video/models/video_configurations.dart';
export 'src/toolbar/video/video_button.dart';

@immutable
class FlutterQuillExtensions {
  const FlutterQuillExtensions._();

  /// override the default implementation of [SpellCheckerServiceProvider]
  /// to allow a `flutter quill` support a better check spelling
  ///
  /// # !WARNING
  /// To avoid memory leaks, ensure to use [dispose()] method to
  /// close stream controllers that used by this custom implementation
  /// when them no longer needed
  ///
  /// Example:
  ///
  ///```dart
  ///// set partial true if you only need to close the controllers
  ///SpellCheckerServiceProvider.dispose(onlyPartial: false);
  ///```
  static void useSpellCheckerService(String language) {
    SpellCheckerServiceProvider.setNewCheckerService(
        SimpleSpellCheckerService(language: language));
  }

  /// Override default implementation of [ClipboardServiceProvider.instance]
  /// to allow `flutter_quill` package to use `super_clipboard` plugin
  /// to support rich text features, gif and images.
  static void useSuperClipboardPlugin() {
    ClipboardServiceProvider.setInstance(SuperClipboardService());
  }
}
