import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' hide OptionalSize;
import 'package:flutter_quill/translations.dart';

import '../../../models/config/image/editor/image_configurations.dart';
import '../../../models/config/shared_configurations.dart';
import '../../../utils/element_utils/element_utils.dart';
import '../../widgets/image.dart';
import 'image_menu.dart';

class QuillEditorImageEmbedBuilder extends EmbedBuilder {
  QuillEditorImageEmbedBuilder({
    required this.configurations,
  });
  final QuillEditorImageEmbedConfigurations configurations;

  @override
  String get key => BlockEmbed.imageType;

  @override
  bool get expanded => false;

  @override
  Widget build(
    BuildContext context,
    QuillController controller,
    Embed node,
    bool readOnly,
    bool inline,
    TextStyle textStyle,
  ) {
    // assert(!kIsWeb, 'Please provide image EmbedBuilder for Web');

    final imageSource = standardizeImageUrl(node.value.data);
    final ((imageSize), margin, alignment) = getElementAttributes(
      node,
      context,
    );

    final width = imageSize.width;
    final height = imageSize.height;

    final image = getImageWidgetByImageSource(
      context: context,
      imageSource,
      imageProviderBuilder: configurations.imageProviderBuilder,
      imageErrorWidgetBuilder: configurations.imageErrorWidgetBuilder,
      alignment: alignment,
      height: height,
      width: width,
      assetsPrefix: QuillSharedExtensionsConfigurations.get(context: context)
          .assetsPrefix,
    );

    final imageSaverService =
        QuillSharedExtensionsConfigurations.get(context: context)
            .imageSaverService;
    return GestureDetector(
      onTap: () {
        final onImageClicked = configurations.onImageClicked;
        if (onImageClicked != null) {
          onImageClicked(imageSource);
          return;
        }
        showDialog(
          context: context,
          builder: (_) => FlutterQuillLocalizationsWidget(
            child: ImageOptionsMenu(
              controller: controller,
              configurations: configurations,
              imageSource: imageSource,
              imageSize: imageSize,
              isReadOnly: readOnly,
              imageSaverService: imageSaverService,
            ),
          ),
        );
      },
      child: Builder(
        builder: (context) {
          if (margin != null) {
            return Padding(
              padding: EdgeInsets.all(margin),
              child: image,
            );
          }
          return image;
        },
      ),
    );
  }
}
