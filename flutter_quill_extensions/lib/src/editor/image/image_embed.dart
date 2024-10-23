import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' hide OptionalSize;

import '../../common/utils/element_utils/element_utils.dart';
import 'image_menu.dart';
import 'models/image_config.dart';
import 'widgets/image.dart';

class QuillEditorImageEmbedBuilder extends EmbedBuilder {
  QuillEditorImageEmbedBuilder({
    required this.config,
  });
  final QuillEditorImageEmbedConfig config;

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
    final imageSource = standardizeImageUrl(node.value.data);
    final ((imageSize), margin, alignment) = getElementAttributes(
      node,
      context,
    );

    final width = imageSize.width;
    final height = imageSize.height;

    final imageWidget = getImageWidgetByImageSource(
      context: context,
      imageSource,
      imageProviderBuilder: config.imageProviderBuilder,
      imageErrorWidgetBuilder: config.imageErrorWidgetBuilder,
      alignment: alignment,
      height: height,
      width: width,
    );

    return GestureDetector(
      onTap: () {
        final onImageClicked = config.onImageClicked;
        if (onImageClicked != null) {
          onImageClicked(imageSource);
          return;
        }
        showDialog(
          context: context,
          builder: (_) => ImageOptionsMenu(
            controller: controller,
            config: config,
            imageSource: imageSource,
            imageSize: imageSize,
            readOnly: readOnly,
            imageProvider: imageWidget.image,
          ),
        );
      },
      child: Builder(
        builder: (context) {
          if (margin != null) {
            return Padding(
              padding: EdgeInsets.all(margin),
              child: imageWidget,
            );
          }
          return imageWidget;
        },
      ),
    );
  }
}
