import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_quill/flutter_quill.dart';

import 'editor/image/config/image_config.dart';
import 'editor/image/image_embed.dart';
import 'editor/video/config/video_config.dart';
import 'editor/video/config/video_web_config.dart';
import 'editor/video/video_embed.dart';
import 'editor/video/video_web_embed.dart';
import 'toolbar/camera/camera_button.dart';
import 'toolbar/camera/config/camera_config.dart';
import 'toolbar/image/config/image_config.dart';
import 'toolbar/image/image_button.dart';
import 'toolbar/video/config/video_config.dart';
import 'toolbar/video/video_button.dart';

abstract final class FlutterQuillEmbeds {
  /// Returns a list of embed builders for [QuillEditor]
  /// to provide basic support for loading images and videos.
  ///
  static List<EmbedBuilder> editorBuilders({
    QuillEditorImageEmbedConfig? imageEmbedConfig =
        const QuillEditorImageEmbedConfig(),
    QuillEditorVideoEmbedConfig? videoEmbedConfig =
        const QuillEditorVideoEmbedConfig(),
  }) {
    return [
      if (imageEmbedConfig != null)
        QuillEditorImageEmbedBuilder(
          config: imageEmbedConfig,
        ),
      if (videoEmbedConfig != null)
        QuillEditorVideoEmbedBuilder(
          config: videoEmbedConfig,
        ),
    ];
  }

  /// Returns a list of embed builders specifically designed for web support
  /// to load images and videos.
  ///
  static List<EmbedBuilder> editorWebBuilders({
    QuillEditorImageEmbedConfig? imageEmbedConfig =
        const QuillEditorImageEmbedConfig(),
    QuillEditorWebVideoEmbedConfig? videoEmbedConfig =
        const QuillEditorWebVideoEmbedConfig(),
  }) {
    if (!kIsWeb) {
      throw UnsupportedError(
        'The ${FlutterQuillEmbeds.editorWebBuilders} is for web, use ${FlutterQuillEmbeds.editorBuilders} '
        'instead for non-web platforms',
      );
    }
    return [
      if (imageEmbedConfig != null)
        QuillEditorImageEmbedBuilder(
          config: imageEmbedConfig,
        ),
      if (videoEmbedConfig != null)
        QuillEditorWebVideoEmbedBuilder(
          config: videoEmbedConfig,
        ),
    ];
  }

  /// Returns a list of embed builders for [QuillEditor].
  ///
  /// It will use [editorWebBuilders] for web and [editorBuilders] for non-web platforms.
  static List<EmbedBuilder> defaultEditorBuilders() {
    return kIsWeb ? editorWebBuilders() : editorBuilders();
  }

  /// Returns a list of embed button builders to support images and videos.
  ///
  /// Pass `null` to options of a button to not show it.
  static List<EmbedButtonBuilder> toolbarButtons({
    QuillToolbarImageButtonOptions? imageButtonOptions =
        const QuillToolbarImageButtonOptions(),
    QuillToolbarVideoButtonOptions? videoButtonOptions =
        const QuillToolbarVideoButtonOptions(),
    QuillToolbarCameraButtonOptions? cameraButtonOptions,
  }) =>
      [
        if (imageButtonOptions != null)
          (context, embedContext) => QuillToolbarImageButton(
                controller: embedContext.controller,
                options: imageButtonOptions,
                // ignore: invalid_use_of_internal_member
                baseOptions: embedContext.baseButtonOptions,
              ),
        if (videoButtonOptions != null)
          (context, embedContext) => QuillToolbarVideoButton(
                controller: embedContext.controller,
                options: videoButtonOptions,
                // ignore: invalid_use_of_internal_member
                baseOptions: embedContext.baseButtonOptions,
              ),
        if (cameraButtonOptions != null)
          (context, embedContext) => QuillToolbarCameraButton(
                controller: embedContext.controller,
                options: cameraButtonOptions,
                // ignore: invalid_use_of_internal_member
                baseOptions: embedContext.baseButtonOptions,
              ),
      ];
}
