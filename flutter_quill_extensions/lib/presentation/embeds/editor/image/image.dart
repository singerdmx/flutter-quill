import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/extensions.dart' as base;
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/translations.dart';

import '../../../models/config/editor/image/image.dart';
import '../../embed_types/image.dart';
import '../../utils.dart';
import '../../widgets/image.dart';
import '../../widgets/image_resizer.dart';
import '../../widgets/simple_dialog_item.dart';

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

    Widget image = const SizedBox.shrink();
    final imageUrl = standardizeImageUrl(node.value.data);
    OptionalSize? imageSize;
    final style = node.style.attributes['style'];

    if (style != null) {
      final attrs = base.isMobile()
          ? base.parseKeyValuePairs(style.value.toString(), {
              Attribute.mobileWidth,
              Attribute.mobileHeight,
              Attribute.mobileMargin,
              Attribute.mobileAlignment,
            })
          : base.parseKeyValuePairs(style.value.toString(), {
              Attribute.width.key,
              Attribute.height.key,
              Attribute.margin,
              Attribute.alignment,
            });
      if (attrs.isNotEmpty) {
        final width = double.tryParse(
          (base.isMobile()
                  ? attrs[Attribute.mobileWidth]
                  : attrs[Attribute.width.key]) ??
              '',
        );
        final height = double.tryParse(
          (base.isMobile()
                  ? attrs[Attribute.mobileHeight]
                  : attrs[Attribute.height.key]) ??
              '',
        );
        final alignment = base.getAlignment(base.isMobile()
            ? attrs[Attribute.mobileAlignment]
            : attrs[Attribute.alignment]);
        final margin = (base.isMobile()
                ? double.tryParse(Attribute.mobileMargin)
                : double.tryParse(Attribute.margin)) ??
            0.0;

        // assert(
        //   width != null && height != null,
        //   base.isMobile()
        //       ? 'mobileWidth and mobileHeight must be specified'
        //       : 'width and height must be specified',
        // );
        imageSize = OptionalSize(width, height);
        image = Padding(
          padding: EdgeInsets.all(margin),
          child: getImageWidgetByImageSource(
            imageUrl,
            width: width,
            height: height,
            alignment: alignment,
            imageProviderBuilder: configurations.imageProviderBuilder,
            imageErrorWidgetBuilder: configurations.imageErrorWidgetBuilder,
          ),
        );
      }
    }

    if (imageSize == null) {
      image = getImageWidgetByImageSource(
        imageUrl,
        imageProviderBuilder: configurations.imageProviderBuilder,
        imageErrorWidgetBuilder: configurations.imageErrorWidgetBuilder,
      );
      imageSize = OptionalSize((image as Image).width, image.height);
    }

    if (!readOnly &&
        (base.isMobile() ||
            configurations.forceUseMobileOptionMenuForImageClick)) {
      return GestureDetector(
        onTap: () {
          showDialog(
              context: context,
              builder: (context) {
                final copyOption = SimpleDialogItem(
                  icon: Icons.copy_all_outlined,
                  color: Colors.cyanAccent,
                  text: 'Copy'.i18n,
                  onPressed: () {
                    final imageNode =
                        getEmbedNode(controller, controller.selection.start)
                            .value;
                    final imageUrl = imageNode.value.data;
                    controller.copiedImageUrl = ImageUrl(
                      imageUrl,
                      getImageStyleString(controller),
                    );
                    Navigator.pop(context);
                  },
                );
                final removeOption = SimpleDialogItem(
                  icon: Icons.delete_forever_outlined,
                  color: Colors.red.shade200,
                  text: 'Remove'.i18n,
                  onPressed: () async {
                    Navigator.of(context).pop();

                    // Call the remove check callback if set
                    if (await configurations.shouldRemoveImageCallback
                            ?.call(imageUrl) ==
                        false) {
                      return;
                    }

                    final offset = getEmbedNode(
                      controller,
                      controller.selection.start,
                    ).offset;
                    controller.replaceText(
                      offset,
                      1,
                      '',
                      TextSelection.collapsed(offset: offset),
                    );
                    // Call the post remove callback if set
                    await configurations.onImageRemovedCallback.call(imageUrl);
                  },
                );
                return Padding(
                  padding: const EdgeInsets.fromLTRB(50, 0, 50, 0),
                  child: SimpleDialog(
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(10),
                        ),
                      ),
                      children: [
                        SimpleDialogItem(
                          icon: Icons.settings_outlined,
                          color: Colors.lightBlueAccent,
                          text: 'Resize'.i18n,
                          onPressed: () {
                            Navigator.pop(context);
                            showCupertinoModalPopup<void>(
                              context: context,
                              builder: (context) {
                                final screenSize = MediaQuery.sizeOf(context);
                                return ImageResizer(
                                  onImageResize: (w, h) {
                                    final res = getEmbedNode(
                                      controller,
                                      controller.selection.start,
                                    );

                                    final attr =
                                        base.replaceStyleStringWithSize(
                                      getImageStyleString(controller),
                                      width: w,
                                      height: h,
                                      isMobile: base.isMobile(),
                                    );
                                    controller
                                      ..skipRequestKeyboard = true
                                      ..formatText(
                                        res.offset,
                                        1,
                                        StyleAttribute(attr),
                                      );
                                  },
                                  imageWidth: imageSize?.width,
                                  imageHeight: imageSize?.height,
                                  maxWidth: screenSize.width,
                                  maxHeight: screenSize.height,
                                );
                              },
                            );
                          },
                        ),
                        copyOption,
                        removeOption,
                      ]),
                );
              });
        },
        child: image,
      );
    }

    if (!readOnly || isImageBase64(imageUrl)) {
      // To enforce using it on the web, desktop and other platforms
      // and that is up to the developer
      if (!base.isMobile() &&
          configurations.forceUseMobileOptionMenuForImageClick) {
        return _menuOptionsForReadonlyImage(
          context: context,
          imageUrl: imageUrl,
          image: image,
          imageProviderBuilder: configurations.imageProviderBuilder,
          imageErrorWidgetBuilder: configurations.imageErrorWidgetBuilder,
        );
      }
      return image;
    }

    // We provide option menu for mobile platform excluding base64 image
    return _menuOptionsForReadonlyImage(
      context: context,
      imageUrl: imageUrl,
      image: image,
      imageProviderBuilder: configurations.imageProviderBuilder,
      imageErrorWidgetBuilder: configurations.imageErrorWidgetBuilder,
    );
  }
}

Widget _menuOptionsForReadonlyImage({
  required BuildContext context,
  required String imageUrl,
  required Widget image,
  required ImageEmbedBuilderProviderBuilder? imageProviderBuilder,
  required ImageEmbedBuilderErrorWidgetBuilder? imageErrorWidgetBuilder,
}) {
  return GestureDetector(
    onTap: () {
      showDialog(
        context: context,
        builder: (_) {
          final saveOption = SimpleDialogItem(
            icon: Icons.save,
            color: Colors.greenAccent,
            text: 'Save'.i18n,
            onPressed: () async {
              imageUrl = appendFileExtensionToImageUrl(imageUrl);
              final messenger = ScaffoldMessenger.of(context);
              Navigator.of(context).pop();

              final saveImageResult = await saveImage(
                imageUrl: imageUrl,
                context: context,
              );
              final imageSavedSuccessfully = saveImageResult.isSuccess;

              messenger.clearSnackBars();

              if (!imageSavedSuccessfully) {
                messenger.showSnackBar(SnackBar(
                    content: Text(
                  'Error while saving image'.i18n,
                )));
                return;
              }

              String message;
              switch (saveImageResult.method) {
                case SaveImageResultMethod.network:
                  message = 'Saved using the network'.i18n;
                  break;
                case SaveImageResultMethod.localStorage:
                  message = 'Saved using the local storage'.i18n;
                  break;
              }

              messenger.showSnackBar(
                SnackBar(
                  content: Text(message),
                ),
              );
            },
          );
          final zoomOption = SimpleDialogItem(
            icon: Icons.zoom_in,
            color: Colors.cyanAccent,
            text: 'Zoom'.i18n,
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => ImageTapWrapper(
                    imageUrl: imageUrl,
                    imageProviderBuilder: imageProviderBuilder,
                    imageErrorWidgetBuilder: imageErrorWidgetBuilder,
                  ),
                ),
              );
            },
          );
          return Padding(
            padding: const EdgeInsets.fromLTRB(50, 0, 50, 0),
            child: SimpleDialog(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(10),
                ),
              ),
              children: [saveOption, zoomOption],
            ),
          );
        },
      );
    },
    child: image,
  );
}
