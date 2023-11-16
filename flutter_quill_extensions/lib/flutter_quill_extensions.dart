// ignore_for_file: unused_import

library flutter_quill_extensions;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_quill/flutter_quill.dart';
import 'package:meta/meta.dart' show immutable;

import 'presentation/embeds/editor/image/image.dart';
import 'presentation/embeds/editor/image/image_web.dart';
import 'presentation/embeds/editor/video/video.dart';
import 'presentation/embeds/editor/video/video_web.dart';
import 'presentation/embeds/editor/webview.dart';
import 'presentation/embeds/toolbar/camera_button/camera_button.dart';
import 'presentation/embeds/toolbar/image_button/image_button.dart';
import 'presentation/embeds/toolbar/video_button/video_button.dart';
import 'presentation/models/config/editor/image/image.dart';
import 'presentation/models/config/editor/image/image_web.dart';
import 'presentation/models/config/editor/video/video.dart';
import 'presentation/models/config/editor/video/video_web.dart';
import 'presentation/models/config/editor/webview.dart';
import 'presentation/models/config/toolbar/buttons/camera.dart';
import 'presentation/models/config/toolbar/buttons/image.dart';
import 'presentation/models/config/toolbar/buttons/media_button.dart';
import 'presentation/models/config/toolbar/buttons/video.dart';

export '/logic/extensions/controller.dart';
export '/presentation/models/config/editor/webview.dart';
export 'logic/models/config/shared_configurations.dart';
export 'presentation/embeds/editor/image/image.dart';
export 'presentation/embeds/editor/image/image_web.dart';
export 'presentation/embeds/editor/unknown.dart';
export 'presentation/embeds/editor/video/video.dart';
export 'presentation/embeds/editor/video/video_web.dart';
export 'presentation/embeds/editor/webview.dart';
export 'presentation/embeds/embed_types.dart';
export 'presentation/embeds/embed_types/image.dart';
export 'presentation/embeds/embed_types/video.dart';
export 'presentation/embeds/toolbar/camera_button/camera_button.dart';
export 'presentation/embeds/toolbar/formula_button.dart';
export 'presentation/embeds/toolbar/image_button/image_button.dart';
export 'presentation/embeds/toolbar/media_button/media_button.dart';
export 'presentation/embeds/toolbar/utils/image_video_utils.dart';
export 'presentation/embeds/toolbar/video_button/video_button.dart';
export 'presentation/models/config/editor/image/image.dart';
export 'presentation/models/config/editor/image/image_web.dart';
export 'presentation/models/config/editor/video/video.dart';
export 'presentation/models/config/editor/video/video_web.dart';
export 'presentation/models/config/toolbar/buttons/camera.dart';
export 'presentation/models/config/toolbar/buttons/formula.dart';
export 'presentation/models/config/toolbar/buttons/image.dart';
export 'presentation/models/config/toolbar/buttons/media_button.dart';
export 'presentation/models/config/toolbar/buttons/video.dart';
export 'presentation/utils/utils.dart';

@immutable
class FlutterQuillEmbeds {
  const FlutterQuillEmbeds._();

  /// Returns a list of embed builders for QuillEditor.
  ///
  /// This method provides a collection of embed builders to enhance the
  /// functionality
  /// of a QuillEditor. It offers customization options for
  /// handling various types of
  /// embedded content, such as images, videos, and formulas.
  ///
  /// **Note:** This method is not intended for web usage.
  /// For web-specific embeds,
  /// use [editorWebBuilders].
  ///
  ///
  /// The method returns a list of [EmbedBuilder] objects that can be used with
  ///  QuillEditor
  /// to enable embedded content features like images, videos, and formulas.
  ///
  ///
  /// final quillEditor = QuillEditor(
  ///   // Other editor configurations
  ///   embedBuilders: embedBuilders,
  /// );
  /// ```
  ///
  /// if you don't want image embed in your quill editor then please pass null
  /// to [imageEmbedConfigurations]. same apply to [videoEmbedConfigurations]
  static List<EmbedBuilder> editorBuilders({
    QuillEditorImageEmbedConfigurations? imageEmbedConfigurations =
        const QuillEditorImageEmbedConfigurations(),
    QuillEditorVideoEmbedConfigurations? videoEmbedConfigurations =
        const QuillEditorVideoEmbedConfigurations(),
  }) {
    if (kIsWeb) {
      throw UnsupportedError(
        'The editorBuilders() is not for web, please use editorBuilders() '
        'instead',
      );
    }
    return [
      if (imageEmbedConfigurations != null)
        QuillEditorImageEmbedBuilder(
          configurations: imageEmbedConfigurations,
        ),
      if (videoEmbedConfigurations != null)
        QuillEditorVideoEmbedBuilder(
          configurations: videoEmbedConfigurations,
        ),
    ];
  }

  /// Returns a list of embed builders specifically designed for web support.
  ///
  /// [QuillEditorWebImageEmbedBuilder] is the embed builder for handling
  ///  images on the web.
  ///
  /// [QuillEditorWebVideoEmbedBuilder] is the embed builder for handling
  ///  videos iframe on the web.
  ///
  static List<EmbedBuilder> editorWebBuilders(
      {QuillEditorWebImageEmbedConfigurations? imageEmbedConfigurations =
          const QuillEditorWebImageEmbedConfigurations(),
      QuillEditorWebVideoEmbedConfigurations? videoEmbedConfigurations =
          const QuillEditorWebVideoEmbedConfigurations()}) {
    if (!kIsWeb) {
      throw UnsupportedError(
        'The editorsWebBuilders() is only for web, please use editorBuilders() '
        'instead for other platforms',
      );
    }
    return [
      if (imageEmbedConfigurations != null)
        QuillEditorWebImageEmbedBuilder(
          configurations: imageEmbedConfigurations,
        ),
      if (videoEmbedConfigurations != null)
        QuillEditorWebVideoEmbedBuilder(
          configurations: videoEmbedConfigurations,
        ),
    ];
  }

  /// Returns a list of default embed builders for QuillEditor.
  ///
  /// It will use [editorWebBuilders] for web and [editorBuilders] for others
  ///
  /// It's not customizable with minimal configurations
  static List<EmbedBuilder> defaultEditorBuilders() {
    return kIsWeb ? editorWebBuilders() : editorBuilders();
  }

  /// Returns a list of embed button builders to customize the toolbar buttons.
  ///
  /// If you don't want to show one of the buttons for soem reason,
  /// pass null to the options of it
  ///
  /// Example of customizing media pick settings for the image button:
  /// ```dart
  /// mediaPickSettingSelector: (context) async {
  ///   final mediaPickSetting = await showModalBottomSheet<MediaPickSetting>(
  ///     showDragHandle: true,
  ///     context: context,
  ///     constraints: const BoxConstraints(maxWidth: 640),
  ///     builder: (context) => const SelectImageSourceDialog(),
  ///   );
  ///   if (mediaPickSetting == null) {
  ///     return null;
  ///   }
  ///   return mediaPickSetting;
  /// }
  /// ```
  ///
  ///
  /// The returned list contains embed button builders for the Quill toolbar.
  /// the [formulaButtonOptions] will be disabled by default on web
  static List<EmbedButtonBuilder> toolbarButtons({
    QuillToolbarImageButtonOptions? imageButtonOptions =
        const QuillToolbarImageButtonOptions(),
    QuillToolbarVideoButtonOptions? videoButtonOptions =
        const QuillToolbarVideoButtonOptions(),
    QuillToolbarCameraButtonOptions? cameraButtonOptions,
    QuillToolbarMediaButtonOptions? mediaButtonOptions,
  }) =>
      [
        if (imageButtonOptions != null)
          (controller, toolbarIconSize, iconTheme, dialogTheme) =>
              QuillToolbarImageButton(
                controller: imageButtonOptions.controller ?? controller,
                options: imageButtonOptions,
              ),
        if (videoButtonOptions != null)
          (controller, toolbarIconSize, iconTheme, dialogTheme) =>
              QuillToolbarVideoButton(
                controller: videoButtonOptions.controller ?? controller,
                options: videoButtonOptions,
              ),
        if (cameraButtonOptions != null)
          (controller, toolbarIconSize, iconTheme, dialogTheme) =>
              QuillToolbarCameraButton(
                controller: cameraButtonOptions.controller ?? controller,
                options: cameraButtonOptions,
              ),
        // TODO: We will return the support for this later
        // if (mediaButtonOptions != null)
        //   (controller, toolbarIconSize, iconTheme, dialogTheme) =>
        //       QuillToolbarMediaButton(
        //         controller: mediaButtonOptions.controller ?? controller,
        //         options: mediaButtonOptions,
        //       ),
        // Drop the support for formula button for now
        // if (formulaButtonOptions != null)
        //   (controller, toolbarIconSize, iconTheme, dialogTheme) =>
        //       QuillToolbarFormulaButton(
        //         controller: formulaButtonOptions.controller ?? controller,
        //         options: formulaButtonOptions,
        //       ),
      ];
}
