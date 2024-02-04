import 'package:flutter/widgets.dart' show BuildContext;
import 'package:flutter_quill/flutter_quill.dart';
import 'package:meta/meta.dart' show immutable;

import '../../services/image_picker/s_image_picker.dart';
import '../../services/image_saver/s_image_saver.dart';

/// Configurations for Flutter Editor Extensions
/// shared between toolbar and editor
@immutable
class QuillSharedExtensionsConfigurations {
  const QuillSharedExtensionsConfigurations({
    ImagePickerService? imagePickerService,
    ImageSaverService? imageSaverService,
    this.assetsPrefix = 'assets',
  })  : _imagePickerService = imagePickerService,
        _imageSaverService = imageSaverService;

  /// Get the instance from the widget tree in [QuillSharedConfigurations]
  /// if it doesn't exists, we will create new one with default options
  factory QuillSharedExtensionsConfigurations.get({
    required BuildContext context,
  }) {
    final value = context.quillSharedConfigurations?.extraConfigurations[key];
    if (value != null) {
      if (value is! QuillSharedExtensionsConfigurations) {
        throw ArgumentError(
          'The value of key `$key` should be of type '
          '$key',
        );
      }
      return value;
    }
    return const QuillSharedExtensionsConfigurations();
  }

  /// The key to be used in the `extraConfigurations` property
  /// which can be found in the [QuillSharedConfigurations]
  ///
  /// which exists in the [QuillEditorConfigurations]
  static const String key = 'QuillSharedExtensionsConfigurations';

  /// Defaults to [ImagePickerService.defaultImpl]
  final ImagePickerService? _imagePickerService;

  /// A getter method which returns the [ImagePickerService] that is provided
  /// by the developer, if it can't be found then we will use default impl
  ImagePickerService get imagePickerService {
    return _imagePickerService ?? ImagePickerService.defaultImpl();
  }

  /// Default to [ImageSaverService.defaultImpl]
  final ImageSaverService? _imageSaverService;

  /// A getter method which returns the [ImageSaverService] that is provided
  /// by the developer, if it can't be found then we will use default impl
  ImageSaverService get imageSaverService {
    return _imageSaverService ?? ImageSaverService.defaultImpl();
  }

  /// The property [assetsPrefix] should be the start of your assets folder
  /// by default it to `assets` and the reason why we need to know it
  ///
  /// Because in case when you don't define a value for [ImageProviderBuilder]
  /// in the [QuillEditorImageEmbedConfigurations] which exists in
  /// [FlutterQuillEmbeds.editorBuilders]
  ///
  /// then the only way of how to know if this is asset image that you added
  /// in the `pubspec.yaml` is by asking you the assetsPrefix, how should the
  /// start of your asset images usualy looks like?? in most projects it's
  /// assets so we will go with that as a default
  ///
  /// but if you are using different name and you want to use assets images
  /// in the [QuillEditor] then it's important to override this
  ///
  /// if you want a custom solution then please use [imageProviderBuilder]
  final String assetsPrefix;
}
