import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_quill/flutter_quill.dart' as fq;
import 'package:meta/meta.dart' show experimental, immutable;

import 'editor/image/image_embed.dart';
import 'editor/image/models/image_configurations.dart';
import 'editor/video/models/video_configurations.dart';
import 'editor/video/models/video_web_configurations.dart';
import 'editor/video/video_embed.dart';
import 'editor/video/video_web_embed.dart';
import 'toolbar/camera/camera_button.dart';
import 'toolbar/camera/models/camera_configurations.dart';
import 'toolbar/image/image_button.dart';
import 'toolbar/image/models/image_configurations.dart';
import 'toolbar/table/models/table_configurations.dart';
import 'toolbar/video/models/video_configurations.dart';
import 'toolbar/video/video_button.dart';

@immutable
class FlutterQuillEmbeds {
  const FlutterQuillEmbeds._();

  /// Returns a list of embed builders for [fq.QuillEditor].
  ///
  /// This method provides a collection of embed builders to enhance the
  /// functionality
  /// of a [fq.QuillEditor]. It offers customization options for
  /// handling various types of
  /// embedded content, such as images, videos, and formulas.
  ///
  /// The method returns a list of [fq.EmbedBuilder] objects that can be used with
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
  static List<fq.EmbedBuilder> editorBuilders({
    QuillEditorImageEmbedConfigurations? imageEmbedConfigurations =
        const QuillEditorImageEmbedConfigurations(),
    QuillEditorVideoEmbedConfigurations? videoEmbedConfigurations =
        const QuillEditorVideoEmbedConfigurations(),
  }) {
    if (kIsWeb) {
      throw UnsupportedError(
        'The editorBuilders() is not for web, please use editorWebBuilders() '
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
      // We disable the table feature is in experimental phase
      // and it does not work as we expect
      // https://github.com/singerdmx/flutter-quill/pull/2238#pullrequestreview-2312706901
      // QuillEditorTableEmbedBuilder(),
    ];
  }

  /// Returns a list of embed builders specifically designed for web support.
  ///
  /// [QuillEditorWebImageEmbedBuilder] is the embed builder for handling
  ///  images on the web. this will use <img> tag of HTML
  ///
  /// [QuillEditorWebVideoEmbedBuilder] is the embed builder for handling
  ///  videos iframe on the web. this will use <iframe> tag of HTML
  ///
  static List<fq.EmbedBuilder> editorWebBuilders({
    QuillEditorImageEmbedConfigurations? imageEmbedConfigurations =
        const QuillEditorImageEmbedConfigurations(),
    QuillEditorWebVideoEmbedConfigurations? videoEmbedConfigurations =
        const QuillEditorWebVideoEmbedConfigurations(),
  }) {
    if (!kIsWeb) {
      throw UnsupportedError(
        'The editorsWebBuilders() is only for web, please use editorBuilders() '
        'instead for other platforms',
      );
    }
    return [
      if (imageEmbedConfigurations != null)
        QuillEditorImageEmbedBuilder(
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
  static List<fq.EmbedBuilder> defaultEditorBuilders() {
    return kIsWeb ? editorWebBuilders() : editorBuilders();
  }

  /// Returns a list of embed button builders to customize the toolbar buttons.
  ///
  /// If you don't want to show one of the buttons for soem reason,
  /// pass null to the options of it
  ///
  /// The returned list contains embed button builders for the Quill toolbar.
  static List<fq.EmbedButtonBuilder> toolbarButtons({
    QuillToolbarImageButtonOptions? imageButtonOptions =
        const QuillToolbarImageButtonOptions(),
    QuillToolbarVideoButtonOptions? videoButtonOptions =
        const QuillToolbarVideoButtonOptions(),
    QuillToolbarCameraButtonOptions? cameraButtonOptions,
    @experimental
    @Deprecated(
        'tableButtonOptions will no longer used by now, and probably will be removed in future releases.')
    QuillToolbarTableButtonOptions? tableButtonOptions,
  }) =>
      [
        if (imageButtonOptions != null)
          (controller, toolbarIconSize, iconTheme, dialogTheme) =>
              QuillToolbarImageButton(
                controller: controller,
                options: imageButtonOptions,
              ),
        if (videoButtonOptions != null)
          (controller, toolbarIconSize, iconTheme, dialogTheme) =>
              QuillToolbarVideoButton(
                controller: controller,
                options: videoButtonOptions,
              ),
        if (cameraButtonOptions != null)
          (controller, toolbarIconSize, iconTheme, dialogTheme) =>
              QuillToolbarCameraButton(
                controller: controller,
                options: cameraButtonOptions,
              ),
      ];
}
