import 'dart:io' show File;

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/extensions.dart' as base;
import 'package:flutter_quill/flutter_quill.dart' hide Text;
import 'package:flutter_quill/translations.dart';
import 'package:math_keyboard/math_keyboard.dart';
import 'package:universal_html/html.dart' as html;

import '../shims/dart_ui_fake.dart'
    if (dart.library.html) '../shims/dart_ui_real.dart' as ui;
import 'embed_types.dart';
import 'utils.dart';
import 'widgets/image.dart';
import 'widgets/image_resizer.dart';
import 'widgets/video_app.dart';
import 'widgets/youtube_video_app.dart';

class ImageEmbedBuilder extends EmbedBuilder {
  ImageEmbedBuilder({
    required this.imageProviderBuilder,
    required this.imageErrorWidgetBuilder,
    required this.onImageRemovedCallback,
    required this.shouldRemoveImageCallback,
    this.forceUseMobileOptionMenu = false,
  });
  final ImageEmbedBuilderOnRemovedCallback? onImageRemovedCallback;
  final ImageEmbedBuilderWillRemoveCallback? shouldRemoveImageCallback;
  final bool forceUseMobileOptionMenu;
  final ImageEmbedBuilderProviderBuilder? imageProviderBuilder;
  final ImageEmbedBuilderErrorWidgetBuilder? imageErrorWidgetBuilder;

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

        assert(
          width != null && height != null,
          base.isMobile()
              ? 'mobileWidth and mobileHeight must be specified'
              : 'width and height must be specified',
        );
        imageSize = OptionalSize(width, height);
        image = Padding(
          padding: EdgeInsets.all(margin),
          child: getQuillImageByUrl(
            imageUrl,
            width: width,
            height: height,
            alignment: alignment,
            imageProviderBuilder: imageProviderBuilder,
            imageErrorWidgetBuilder: imageErrorWidgetBuilder,
          ),
        );
      }
    }

    if (imageSize == null) {
      image = getQuillImageByUrl(
        imageUrl,
        imageProviderBuilder: imageProviderBuilder,
        imageErrorWidgetBuilder: imageErrorWidgetBuilder,
      );
      imageSize = OptionalSize((image as Image).width, image.height);
    }

    if (!readOnly && (base.isMobile() || forceUseMobileOptionMenu)) {
      return GestureDetector(
        onTap: () {
          showDialog(
              context: context,
              builder: (context) {
                final copyOption = _SimpleDialogItem(
                  icon: Icons.copy_all_outlined,
                  color: Colors.cyanAccent,
                  text: 'Copy'.i18n,
                  onPressed: () {
                    final imageNode =
                        getEmbedNode(controller, controller.selection.start)
                            .value;
                    final imageUrl = imageNode.value.data;
                    controller.copiedImageUrl =
                        ImageUrl(imageUrl, getImageStyleString(controller));
                    Navigator.pop(context);
                  },
                );
                final removeOption = _SimpleDialogItem(
                  icon: Icons.delete_forever_outlined,
                  color: Colors.red.shade200,
                  text: 'Remove'.i18n,
                  onPressed: () async {
                    Navigator.of(context).pop();

                    final imageFile = File(imageUrl);

                    // Call the remove check callback if set
                    if (await shouldRemoveImageCallback?.call(imageFile) ==
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
                    await onImageRemovedCallback?.call(imageFile);
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
                        _SimpleDialogItem(
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
      if (!base.isMobile() && forceUseMobileOptionMenu) {
        return _menuOptionsForReadonlyImage(
          context: context,
          imageUrl: imageUrl,
          image: image,
          imageProviderBuilder: imageProviderBuilder,
          imageErrorWidgetBuilder: imageErrorWidgetBuilder,
        );
      }
      return image;
    }

    // We provide option menu for mobile platform excluding base64 image
    return _menuOptionsForReadonlyImage(
      context: context,
      imageUrl: imageUrl,
      image: image,
      imageProviderBuilder: imageProviderBuilder,
      imageErrorWidgetBuilder: imageErrorWidgetBuilder,
    );
  }
}

class ImageEmbedBuilderWeb extends EmbedBuilder {
  ImageEmbedBuilderWeb({this.constraints})
      : assert(kIsWeb, 'ImageEmbedBuilderWeb is only for web platform');

  final BoxConstraints? constraints;

  @override
  String get key => BlockEmbed.imageType;

  @override
  Widget build(
    BuildContext context,
    QuillController controller,
    Embed node,
    bool readOnly,
    bool inline,
    TextStyle textStyle,
  ) {
    final imageUrl = node.value.data;

    ui.platformViewRegistry.registerViewFactory(imageUrl, (viewId) {
      return html.ImageElement()
        ..src = imageUrl
        ..style.height = 'auto'
        ..style.width = 'auto';
    });

    return ConstrainedBox(
      constraints: constraints ?? BoxConstraints.loose(const Size(200, 200)),
      child: HtmlElementView(
        viewType: imageUrl,
      ),
    );
  }
}

class VideoEmbedBuilder extends EmbedBuilder {
  VideoEmbedBuilder({this.onVideoInit});

  final void Function(GlobalKey videoContainerKey)? onVideoInit;

  @override
  String get key => BlockEmbed.videoType;

  @override
  Widget build(
    BuildContext context,
    QuillController controller,
    base.Embed node,
    bool readOnly,
    bool inline,
    TextStyle textStyle,
  ) {
    assert(!kIsWeb, 'Please provide video EmbedBuilder for Web');

    final videoUrl = node.value.data;
    if (isYouTubeUrl(videoUrl)) {
      return YoutubeVideoApp(
          videoUrl: videoUrl, context: context, readOnly: readOnly);
    }
    return VideoApp(
      videoUrl: videoUrl,
      context: context,
      readOnly: readOnly,
      onVideoInit: onVideoInit,
    );
  }
}

class FormulaEmbedBuilder extends EmbedBuilder {
  @override
  String get key => BlockEmbed.formulaType;

  @override
  Widget build(
    BuildContext context,
    QuillController controller,
    base.Embed node,
    bool readOnly,
    bool inline,
    TextStyle textStyle,
  ) {
    assert(!kIsWeb, 'Please provide formula EmbedBuilder for Web');

    final mathController = MathFieldEditingController();
    return Focus(
      onFocusChange: (hasFocus) {
        if (hasFocus) {
          // If the MathField is tapped, hides the built in keyboard
          SystemChannels.textInput.invokeMethod('TextInput.hide');
          debugPrint(mathController.currentEditingValue());
        }
      },
      child: MathField(
        controller: mathController,
        variables: const ['x', 'y', 'z'],
        onChanged: (value) {},
        onSubmitted: (value) {},
      ),
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
          builder: (context) {
            final saveOption = _SimpleDialogItem(
              icon: Icons.save,
              color: Colors.greenAccent,
              text: 'Save'.i18n,
              onPressed: () async {
                imageUrl = appendFileExtensionToImageUrl(imageUrl);
                final messenger = ScaffoldMessenger.of(context);
                Navigator.of(context).pop();

                final saveImageResult = await saveImage(imageUrl);
                final imageSavedSuccessfully = saveImageResult.isSuccess;

                messenger.clearSnackBars();

                if (!imageSavedSuccessfully) {
                  messenger.showSnackBar(SnackBar(
                      content: Text(
                    'Error while saving image'.i18n,
                  )));
                  return;
                }

                var message;
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
            final zoomOption = _SimpleDialogItem(
              icon: Icons.zoom_in,
              color: Colors.cyanAccent,
              text: 'Zoom'.i18n,
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  // TODO: Consider add support for other theme system
                  // like Cupertino or at least add the option to by
                  // by using PageRoute as option so dev can ovveride this
                  // this change should be done in all places if you want to
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
      child: image);
}

class _SimpleDialogItem extends StatelessWidget {
  const _SimpleDialogItem(
      {required this.icon,
      required this.color,
      required this.text,
      required this.onPressed,
      Key? key})
      : super(key: key);

  final IconData icon;
  final Color color;
  final String text;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SimpleDialogOption(
      onPressed: onPressed,
      child: Row(
        children: [
          Icon(icon, size: 36, color: color),
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 16),
            child:
                Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
