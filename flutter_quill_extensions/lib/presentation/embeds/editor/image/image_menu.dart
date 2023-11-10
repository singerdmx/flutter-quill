import 'package:flutter/cupertino.dart' show showCupertinoModalPopup;
import 'package:flutter/material.dart';
// import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:flutter_quill/extensions.dart'
    show isDesktop, isMobile, replaceStyleStringWithSize;
import 'package:flutter_quill/flutter_quill.dart'
    show ImageUrl, QuillController, StyleAttribute, getEmbedNode;
import 'package:flutter_quill/translations.dart';

import '../../../../logic/services/image_saver/s_image_saver.dart';
import '../../../models/config/editor/image/image.dart';
import '../../utils.dart';
import '../../widgets/image.dart' show ImageTapWrapper, getImageStyleString;
import '../../widgets/image_resizer.dart' show ImageResizer;
import 'image.dart' show OptionalSize;

class ImageOptionsMenu extends StatelessWidget {
  const ImageOptionsMenu({
    required this.controller,
    required this.configurations,
    required this.imageSource,
    required this.imageSize,
    required this.isReadOnly,
    required this.imageSaverService,
    super.key,
  });

  final QuillController controller;
  final QuillEditorImageEmbedConfigurations configurations;
  final String imageSource;
  final OptionalSize imageSize;
  final bool isReadOnly;
  final ImageSaverService imageSaverService;

  @override
  Widget build(BuildContext context) {
    final materialTheme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(50, 0, 50, 0),
      child: SimpleDialog(
        title: Text('Image'.i18n),
        children: [
          if (!isReadOnly)
            ListTile(
              title: Text('Resize'.i18n),
              leading: const Icon(Icons.settings_outlined),
              onTap: () {
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

                        final attr = replaceStyleStringWithSize(
                          getImageStyleString(controller),
                          width: w,
                          height: h,
                          isMobile: isMobile(supportWeb: false),
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
                    );
                  },
                );
              },
            ),
          ListTile(
            leading: const Icon(Icons.copy_all_outlined),
            title: Text('Copy'.i18n),
            onTap: () async {
              final navigator = Navigator.of(context);
              final imageNode =
                  getEmbedNode(controller, controller.selection.start).value;
              final imageUrl = imageNode.value.data;
              controller.copiedImageUrl = ImageUrl(
                imageUrl,
                getImageStyleString(controller),
              );
              // TODO: Implement the copy image
              // await Clipboard.setData(
              //   ClipboardData(text: '$imageUrl'),
              // );
              navigator.pop();
            },
          ),
          if (!isReadOnly)
            ListTile(
              leading: Icon(
                Icons.delete_forever_outlined,
                color: materialTheme.colorScheme.error,
              ),
              title: Text('Remove'.i18n),
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
          ...[
            ListTile(
              leading: const Icon(Icons.save),
              title: Text('Save'.i18n),
              enabled: !isDesktop(supportWeb: false),
              onTap: () async {
                final messenger = ScaffoldMessenger.of(context);
                Navigator.of(context).pop();

                final saveImageResult = await saveImage(
                  imageUrl: imageSource,
                  imageSaverService: imageSaverService,
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
            ),
            ListTile(
              leading: const Icon(Icons.zoom_in),
              title: Text('Zoom'.i18n),
              onTap: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => ImageTapWrapper(
                    imageUrl: imageSource,
                    imageProviderBuilder: configurations.imageProviderBuilder,
                    imageErrorWidgetBuilder:
                        configurations.imageErrorWidgetBuilder,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
