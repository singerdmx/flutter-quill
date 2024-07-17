library flutter_quill_extensions;

// ignore: implementation_imports
import 'package:flutter_quill/src/editor_toolbar_controller_shared/clipboard/clipboard_service_provider.dart';
import 'package:meta/meta.dart' show immutable;

import 'services/clipboard/super_clipboard_service.dart';

export 'embeds/embed_types.dart';
export 'embeds/formula/toolbar/formula_button.dart';
export 'embeds/image/editor/image_embed.dart';
export 'embeds/image/editor/image_embed_types.dart';
export 'embeds/image/editor/image_web_embed.dart';
export 'embeds/image/toolbar/image_button.dart';
export 'embeds/others/camera_button/camera_button.dart';
export 'embeds/others/media_button/media_button.dart';
export 'embeds/table/editor/table_cell_embed.dart';
export 'embeds/table/editor/table_embed.dart';
export 'embeds/table/editor/table_models.dart';
export 'embeds/table/toolbar/table_button.dart';
export 'embeds/unknown/editor/unknown_embed.dart';
export 'embeds/video/editor/video_embed.dart';
export 'embeds/video/editor/video_web_embed.dart';
export 'embeds/video/toolbar/video_button.dart';
export 'embeds/video/video.dart';
export 'extensions/controller_ext.dart';
export 'flutter_quill_embeds.dart';
export 'models/config/camera/camera_configurations.dart';
export 'models/config/formula/formula_configurations.dart';
export 'models/config/image/editor/image_configurations.dart';
export 'models/config/image/editor/image_web_configurations.dart';
export 'models/config/image/toolbar/image_configurations.dart';
export 'models/config/media/media_button_configurations.dart';
export 'models/config/shared_configurations.dart';
export 'models/config/table/table_configurations.dart';
export 'models/config/video/editor/video_configurations.dart';
export 'models/config/video/editor/video_web_configurations.dart';
export 'models/config/video/toolbar/video_configurations.dart';
export 'utils/utils.dart';

// TODO: Refactor flutter_quill_extensions to match the structure of flutter_quill
//  Also avoid exposing all APIs as public. Use `src` as directory name

@immutable
class FlutterQuillExtensions {
  const FlutterQuillExtensions._();

  /// Override default implementation of [ClipboardServiceProvider.instance]
  /// to allow `flutter_quill` package to use `super_clipboard` plugin
  /// to support rich text features, gif and images.
  static void useSuperClipboardPlugin() {
    ClipboardServiceProvider.setInstance(SuperClipboardService());
  }
}
