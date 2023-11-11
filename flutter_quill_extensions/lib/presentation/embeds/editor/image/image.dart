import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/extensions.dart' as base;
import 'package:flutter_quill/flutter_quill.dart' hide OptionalSize;

import '../../../../logic/models/config/shared_configurations.dart';
import '../../../models/config/editor/image/image.dart';
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
    base.Embed node,
    bool readOnly,
    bool inline,
    TextStyle textStyle,
  ) {
    assert(!kIsWeb, 'Please provide image EmbedBuilder for Web');

    final imageSource = standardizeImageUrl(node.value.data);
    final ((imageSize), margin, alignment) = _getImageAttributes(node);

    final width = imageSize.width;
    final height = imageSize.height;

    final image = getImageWidgetByImageSource(
      imageSource,
      imageProviderBuilder: configurations.imageProviderBuilder,
      imageErrorWidgetBuilder: configurations.imageErrorWidgetBuilder,
      alignment: alignment,
      height: height,
      width: width,
    );

    // OptionalSize? imageSize;
    // final style = node.style.attributes['style'];

    // if (style != null) {
    //   final attrs = base.isMobile(supportWeb: false)
    //       ? base.parseKeyValuePairs(style.value.toString(), {
    //           Attribute.mobileWidth,
    //           Attribute.mobileHeight,
    //           Attribute.mobileMargin,
    //           Attribute.mobileAlignment,
    //         })
    //       : base.parseKeyValuePairs(style.value.toString(), {
    //           Attribute.width.key,
    //           Attribute.height.key,
    //           Attribute.margin,
    //           Attribute.alignment,
    //         });
    //   if (attrs.isNotEmpty) {
    //     final width = double.tryParse(
    //       (base.isMobile(supportWeb: false)
    //               ? attrs[Attribute.mobileWidth]
    //               : attrs[Attribute.width.key]) ??
    //           '',
    //     );
    //     final height = double.tryParse(
    //       (base.isMobile(supportWeb: false)
    //               ? attrs[Attribute.mobileHeight]
    //               : attrs[Attribute.height.key]) ??
    //           '',
    //     );
    //     final alignment = base.getAlignment(base.isMobile(supportWeb: false)
    //         ? attrs[Attribute.mobileAlignment]
    //         : attrs[Attribute.alignment]);
    //     final margin = (base.isMobile(supportWeb: false)
    //             ? double.tryParse(Attribute.mobileMargin)
    //             : double.tryParse(Attribute.margin)) ??
    //         0.0;

    //     imageSize = OptionalSize(width, height);
    //     image = Padding(
    //       padding: EdgeInsets.all(margin),
    //       child: getImageWidgetByImageSource(
    //         imageSource,
    //         width: width,
    //         height: height,
    //         alignment: alignment,
    //         imageProviderBuilder: configurations.imageProviderBuilder,
    //         imageErrorWidgetBuilder: configurations.imageErrorWidgetBuilder,
    //       ),
    //     );
    //   }
    // }

    // if (imageSize == null) {
    //   image = getImageWidgetByImageSource(
    //     imageSource,
    //     imageProviderBuilder: configurations.imageProviderBuilder,
    //     imageErrorWidgetBuilder: configurations.imageErrorWidgetBuilder,
    //   );
    //   imageSize = OptionalSize((image as Image).width, image.height);
    // }

    final imageSaverService =
        QuillSharedExtensionsConfigurations.get(context: context)
            .imageSaverService;
    return GestureDetector(
      onTap: configurations.onImageClicked ??
          () => showDialog(
                context: context,
                builder: (context) {
                  return ImageOptionsMenu(
                    controller: controller,
                    configurations: configurations,
                    imageSource: imageSource,
                    imageSize: imageSize,
                    isReadOnly: readOnly,
                    imageSaverService: imageSaverService,
                  );
                },
              ),
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

(
  OptionalSize imageSize,
  double? margin,
  Alignment alignment,
) _getImageAttributes(
  Node node,
) {
  var imageSize = const OptionalSize(null, null);
  var imageAlignment = Alignment.center;
  double? imageMargin;

  // Usually double value
  final heightValue = double.tryParse(
      node.style.attributes[Attribute.height.key]?.value.toString() ?? '');
  final widthValue = double.tryParse(
      node.style.attributes[Attribute.width.key]?.value.toString() ?? '');

  if (heightValue != null) {
    imageSize = imageSize.copyWith(
      height: heightValue,
    );
  }
  if (widthValue != null) {
    imageSize = imageSize.copyWith(
      width: widthValue,
    );
  }

  final cssStyle = node.style.attributes['style'];

  if (cssStyle != null) {
    final attrs = base.isMobile(supportWeb: false)
        ? base.parseKeyValuePairs(cssStyle.value.toString(), {
            Attribute.mobileWidth,
            Attribute.mobileHeight,
            Attribute.mobileMargin,
            Attribute.mobileAlignment,
          })
        : base.parseKeyValuePairs(cssStyle.value.toString(), {
            Attribute.width.key,
            Attribute.height.key,
            Attribute.margin,
            Attribute.alignment,
          });
    if (attrs.isEmpty) {
      return (imageSize, imageMargin, imageAlignment);
    }

    // It css value as string but we will try to support it anyway

    // TODO: This could be improved much better
    final cssHeightValue = double.tryParse(((base.isMobile(supportWeb: false)
                ? attrs[Attribute.mobileHeight]
                : attrs[Attribute.height.key]) ??
            '')
        .replaceFirst('px', ''));
    final cssWidthValue = double.tryParse(((!base.isMobile(supportWeb: false)
                ? attrs[Attribute.width.key]
                : attrs[Attribute.mobileWidth]) ??
            '')
        .replaceFirst('px', ''));

    if (cssHeightValue != null) {
      imageSize = imageSize.copyWith(height: cssHeightValue);
    }
    if (cssWidthValue != null) {
      imageSize = imageSize.copyWith(width: cssWidthValue);
    }

    imageAlignment = base.getAlignment(base.isMobile(supportWeb: false)
        ? attrs[Attribute.mobileAlignment]
        : attrs[Attribute.alignment]);
    final margin = (base.isMobile(supportWeb: false)
        ? double.tryParse(Attribute.mobileMargin)
        : double.tryParse(Attribute.margin));
    if (margin != null) {
      imageMargin = margin;
    }
  }

  return (imageSize, imageMargin, imageAlignment);
}

@immutable
class OptionalSize {
  const OptionalSize(
    this.width,
    this.height,
  );

  /// If non-null, requires the child to have exactly this width.
  /// If null, the child is free to choose its own width.
  final double? width;

  /// If non-null, requires the child to have exactly this height.
  /// If null, the child is free to choose its own height.
  final double? height;

  OptionalSize copyWith({
    double? width,
    double? height,
  }) {
    return OptionalSize(
      width ?? this.width,
      height ?? this.height,
    );
  }
}
