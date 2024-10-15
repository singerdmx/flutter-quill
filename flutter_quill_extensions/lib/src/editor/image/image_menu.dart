import 'dart:async' show Completer;
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart' show showCupertinoModalPopup;
import 'package:flutter/foundation.dart' show kIsWeb, Uint8List;
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart'
    show ImageUrl, QuillController, StyleAttribute, getEmbedNode;
import 'package:flutter_quill/flutter_quill_internal.dart';
import 'package:flutter_quill/translations.dart';

import '../../common/utils/element_utils/element_utils.dart';
import '../../common/utils/string.dart';
import '../../common/utils/utils.dart';
import '../../editor_toolbar_shared/image_saver/s_image_saver.dart';
import '../../editor_toolbar_shared/shared_configurations.dart';
import 'models/image_configurations.dart';
import 'widgets/image.dart' show ImageTapWrapper, getImageStyleString;
import 'widgets/image_resizer.dart' show ImageResizer;

class ImageOptionsMenu extends StatelessWidget {
  const ImageOptionsMenu({
    required this.controller,
    required this.configurations,
    required this.imageSource,
    required this.imageSize,
    required this.isReadOnly,
    required this.imageSaverService,
    required this.imageProvider,
    super.key,
  });

  final QuillController controller;
  final QuillEditorImageEmbedConfigurations configurations;
  final String imageSource;
  final ElementSize imageSize;
  final bool isReadOnly;
  final ImageSaverService imageSaverService;
  final ImageProvider imageProvider;

  @override
  Widget build(BuildContext context) {
    final materialTheme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(50, 0, 50, 0),
      child: SimpleDialog(
        title: Text(context.loc.image),
        children: [
          if (!isReadOnly)
            ListTile(
              title: Text(context.loc.resize),
              leading: const Icon(Icons.settings_outlined),
              onTap: () {
                Navigator.pop(context);
                showCupertinoModalPopup<void>(
                  context: context,
                  builder: (modalContext) {
                    final screenSize = MediaQuery.sizeOf(modalContext);
                    return FlutterQuillLocalizationsWidget(
                      child: ImageResizer(
                        onImageResize: (width, height) {
                          final res = getEmbedNode(
                            controller,
                            controller.selection.start,
                          );

                          final attr = replaceStyleStringWithSize(
                            getImageStyleString(controller),
                            width: width,
                            height: height,
                          );
                          controller
                            ..skipRequestKeyboard = true
                            ..formatText(
                              res.offset,
                              1,
                              StyleAttribute(attr),
                            );
                        },
                        imageWidth: imageSize.width,
                        imageHeight: imageSize.height,
                        maxWidth: screenSize.width,
                        maxHeight: screenSize.height,
                      ),
                    );
                  },
                );
              },
            ),
          ListTile(
            leading: const Icon(Icons.copy_all_outlined),
            title: Text(context.loc.copy),
            onTap: () async {
              Navigator.of(context).pop();
              controller.copiedImageUrl = ImageUrl(
                imageSource,
                getImageStyleString(controller),
              );

              final imageBytes = await _loadImageBytesFromImageProvider();
              if (imageBytes != null) {
                await ClipboardServiceProvider.instance.copyImage(imageBytes);
              }
            },
          ),
          if (!isReadOnly)
            ListTile(
              leading: Icon(
                Icons.delete_forever_outlined,
                color: materialTheme.colorScheme.error,
              ),
              title: Text(context.loc.remove),
              onTap: () async {
                Navigator.of(context).pop();

                // Call the remove check callback if set
                if (await configurations.shouldRemoveImageCallback
                        ?.call(imageSource) ==
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
                await configurations.onImageRemovedCallback.call(imageSource);
              },
            ),
          if (!kIsWeb)
            ListTile(
              leading: const Icon(Icons.save),
              title: Text(context.loc.save),
              onTap: () async {
                final messenger = ScaffoldMessenger.of(context);
                final localizations = context.loc;
                Navigator.of(context).pop();

                final saveImageResult = await saveImage(
                  imageUrl: imageSource,
                  imageSaverService: imageSaverService,
                );
                final imageSavedSuccessfully = saveImageResult.error == null;

                messenger.clearSnackBars();

                if (!imageSavedSuccessfully) {
                  messenger.showSnackBar(SnackBar(
                      content: Text(
                    localizations.errorWhileSavingImage,
                  )));
                  return;
                }

                var message = switch (saveImageResult.method) {
                  SaveImageResultMethod.network =>
                    localizations.savedUsingTheNetwork,
                  SaveImageResultMethod.localStorage =>
                    localizations.savedUsingLocalStorage,
                };

                if (isDesktopApp) {
                  message = localizations.theImageHasBeenSavedAt(imageSource);
                }

                messenger.showSnackBar(
                  SnackBar(
                    content: Text(message),
                  ),
                );
              },
            ),
          ListTile(
            leading: const Icon(Icons.zoom_in),
            title: Text(context.loc.zoom),
            onTap: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => ImageTapWrapper(
                  assetsPrefix:
                      QuillSharedExtensionsConfigurations.get(context: context)
                          .assetsPrefix,
                  imageUrl: imageSource,
                  configurations: configurations,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // TODO: This will load the image again, in case it was network image
  //  then it will send a GET request each time to load the image.
  Future<Uint8List?> _loadImageBytesFromImageProvider() async {
    final stream = imageProvider.resolve(ImageConfiguration.empty);
    final completer = Completer<ui.Image>();

    ImageStreamListener? listener;
    listener = ImageStreamListener((info, _) {
      completer.complete(info.image);
      stream.removeListener(listener!);
    });

    stream.addListener(listener);

    final image = await completer.future;
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData?.buffer.asUint8List();
  }
}
