import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_quill/flutter_quill.dart' as fq;
import 'package:meta/meta.dart' show immutable;

import 'embeds/image/editor/image_embed.dart';
import 'embeds/image/editor/image_web_embed.dart';
import 'embeds/image/toolbar/image_button.dart';
import 'embeds/others/camera_button/camera_button.dart';
import 'embeds/table/editor/table_embed.dart';
import 'embeds/table/toolbar/table_button.dart';
import 'embeds/video/editor/video_embed.dart';
import 'embeds/video/editor/video_web_embed.dart';
import 'embeds/video/toolbar/video_button.dart';
import 'models/config/camera/camera_configurations.dart';
import 'models/config/image/editor/image_configurations.dart';
import 'models/config/image/toolbar/image_configurations.dart';
import 'models/config/media/media_button_configurations.dart';
import 'models/config/table/table_configurations.dart';
import 'models/config/video/editor/video_configurations.dart';
import 'models/config/video/editor/video_web_configurations.dart';
import 'models/config/video/toolbar/video_configurations.dart';

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
      QuillEditorTableEmbedBuilder(),
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
    QuillToolbarTableButtonOptions? tableButtonOptions,
    @Deprecated(
      'Media button has been removed, the value of this parameter will be ignored',
    )
    QuillToolbarMediaButtonOptions? mediaButtonOptions,
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
        if (tableButtonOptions != null)
          (controller, toolbarIconSize, iconTheme, dialogTheme) =>
              QuillToolbarTableButton(
                controller: controller,
                options: tableButtonOptions,
              ),
      ];
}
