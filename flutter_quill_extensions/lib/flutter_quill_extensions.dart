library;

import 'package:flutter_quill/flutter_quill_internal.dart'
    show ClipboardServiceProvider;
import 'package:meta/meta.dart' show experimental;

import 'src/editor_toolbar_controller_shared/clipboard/super_clipboard_service.dart';

export 'src/common/extensions/controller_ext.dart';
export 'src/common/utils/utils.dart';
export 'src/editor/image/image_embed.dart';
export 'src/editor/image/image_embed_types.dart';
export 'src/editor/image/image_web_embed.dart';
export 'src/editor/image/models/image_configurations.dart';
export 'src/editor/image/models/image_web_configurations.dart';
// TODO: Remove Simple Spell Checker Service
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
export 'src/toolbar/camera/camera_types.dart';
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

@Deprecated(
  'Should not be used as will removed soon in future releases.',
)
@experimental
class FlutterQuillExtensions {
  FlutterQuillExtensions._();

  @Deprecated(
    '''
    Spell checker feature has been removed from the package to make it optional and 
    reduce bundle size. See issue https://github.com/singerdmx/flutter-quill/issues/2142
    for more details.

    Calling this function will no longer activate the feature.
    ''',
  )
  @experimental
  static void useSpellCheckerService(String language) {
    // This feature has been removed from the package.
    // See https://github.com/singerdmx/flutter-quill/issues/2142
  }

  /// Override default implementation of [ClipboardServiceProvider.instance]
  /// to allow `flutter_quill` package to use `super_clipboard` plugin
  /// to support rich text features, gif and images.
  @Deprecated(
    'The functionality of super_clipboard is now built-in in recent versions of flutter_quill.\n'
    'To migrate, remove this function call and see '
    'https://pub.dev/packages/quill_native_bridge#-platform-configuration (optional for copying images on Android) to use quill_native_bridge implementation (the new default).\n'
    'Or if you want to use super_clipboard implementation (support might discontinued in newer versions), use the package https://pub.dev/packages/quill_super_clipboard\n'
    'See https://github.com/singerdmx/flutter-quill/pull/2230 for more details.',
  )
  @experimental
  static void useSuperClipboardPlugin() {
    ClipboardServiceProvider.setInstance(SuperClipboardService());
  }
}
