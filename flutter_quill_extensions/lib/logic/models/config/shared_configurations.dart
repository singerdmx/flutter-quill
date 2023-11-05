import 'package:flutter/widgets.dart' show BuildContext;
import 'package:flutter_quill/flutter_quill.dart';
import 'package:meta/meta.dart' show immutable;

import '../../services/image_picker/s_image_picker.dart';
import '../../services/image_saver/s_image_saver.dart';

@immutable
class QuillSharedExtensionsConfigurations {
  const QuillSharedExtensionsConfigurations({
    ImagePickerService? imagePickerService,
    ImageSaverService? imageSaverService,
  })  : _imagePickerService = imagePickerService,
        _imageSaverService = imageSaverService;

  /// Get the instance from the widget tree in [QuillSharedConfigurations]
  /// if it doesn't exists, we will create new one with default options
  factory QuillSharedExtensionsConfigurations.get({
    required BuildContext context,
  }) {
    final quillSharedExtensionsConfigurations =
        context.requireQuillSharedConfigurations.extraConfigurations[key];
    if (quillSharedExtensionsConfigurations != null) {
      if (quillSharedExtensionsConfigurations
          is! QuillSharedExtensionsConfigurations) {
        throw ArgumentError(
          'The value of key `$key` should be of type '
          'QuillSharedExtensionsConfigurations',
        );
      }
      return quillSharedExtensionsConfigurations;
    }
    return const QuillSharedExtensionsConfigurations();
  }

  static const String key = 'quillSharedExtensionsConfigurations';

  /// Default to [ImagePickerService.defaultImpl]
  final ImagePickerService? _imagePickerService;

  ImagePickerService get imagePickerService {
    return _imagePickerService ?? ImagePickerService.defaultImpl();
  }

  /// Default to [ImageSaverService.defaultImpl]
  final ImageSaverService? _imageSaverService;

  ImageSaverService get imageSaverService {
    return _imageSaverService ?? ImageSaverService.defaultImpl();
  }
}
