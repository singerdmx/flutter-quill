import 'package:flutter/cupertino.dart' show showCupertinoModalPopup;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart'
    show ImageUrl, QuillController, StyleAttribute, getEmbedNode;
import 'package:flutter_quill/internal.dart';
import 'package:path/path.dart' as p;
import 'package:url_launcher/url_launcher.dart';

import '../../common/utils/element_utils/element_utils.dart';
import '../../common/utils/string.dart';
import 'config/image_config.dart';
import 'image_load_utils.dart';
import 'image_save_utils.dart';
import 'widgets/image.dart' show ImageTapWrapper, getImageStyleString;
import 'widgets/image_resizer.dart' show ImageResizer;

class ImageOptionsMenu extends StatelessWidget {
  const ImageOptionsMenu({
    required this.controller,
    required this.config,
    required this.imageSource,
    required this.imageSize,
    required this.readOnly,
    required this.imageProvider,
    this.prefersGallerySave = true,
    super.key,
  });

  final QuillController controller;
  final QuillEditorImageEmbedConfig config;
  final String imageSource;
  final ElementSize imageSize;
  final bool readOnly;
  final ImageProvider imageProvider;

  // TODO(quill_native_bridge): Update this doc comment once saveImageToGallery()
  //  is supported on Windows too (will be applicable like macOS). See https://pub.dev/packages/quill_native_bridge#-features
  /// Determines if the image should be saved to the gallery instead of using the
  /// system file save dialog for platforms that support both.
  ///
  /// Currently, the only platform where this applies is macOS.
  ///
  /// This is silently ignored on platforms that only support gallery save (Android and iOS)
  /// or only image save.
  ///
  /// For more details, refer to [quill_native_bridge Saving images](https://pub.dev/packages/quill_native_bridge#-saving-images).
  final bool prefersGallerySave;

  @override
  Widget build(BuildContext context) {
    final materialTheme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(50, 0, 50, 0),
      child: SimpleDialog(
        title: Text(context.loc.image),
        children: [
          if (!readOnly)
            ListTile(
              title: Text(context.loc.resize),
              leading: const Icon(Icons.settings_outlined),
              onTap: () {
                Navigator.pop(context);
                showCupertinoModalPopup<void>(
                  context: context,
                  builder: (modalContext) {
                    final screenSize = MediaQuery.sizeOf(modalContext);
                    return ImageResizer(
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

              final imageBytes = await ImageLoader.instance
                  .loadImageBytesFromImageProvider(
                      imageProvider: imageProvider);
              if (imageBytes != null) {
                await ClipboardServiceProvider.instance.copyImage(imageBytes);
              }
            },
          ),
          if (!readOnly)
            ListTile(
              leading: Icon(
                Icons.delete_forever_outlined,
                color: materialTheme.colorScheme.error,
              ),
              title: Text(context.loc.remove),
              onTap: () async {
                Navigator.of(context).pop();

                // Call the remove check callback if set
                if (await config.shouldRemoveImageCallback?.call(imageSource) ==
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
                await config.onImageRemovedCallback.call(imageSource);
              },
            ),
          ListTile(
            leading: const Icon(Icons.save),
            title: Text(context.loc.save),
            onTap: () async {
              final messenger = ScaffoldMessenger.of(context);
              final localizations = context.loc;
              Navigator.of(context).pop();

              SaveImageResult? result;
              try {
                result = await ImageSaver.instance.saveImage(
                  imageUrl: imageSource,
                  imageProvider: imageProvider,
                  prefersGallerySave: prefersGallerySave,
                );
              } on GalleryImageSaveAccessDeniedException {
                messenger.showSnackBar(SnackBar(
                    content: Text(
                  localizations.saveImagePermissionDenied,
                )));
                return;
              }

              if (result == null) {
                messenger.showSnackBar(SnackBar(
                    content: Text(
                  localizations.errorUnexpectedSavingImage,
                )));
                return;
              }

              if (kIsWeb) {
                messenger.showSnackBar(SnackBar(
                    content: Text(localizations.successImageDownloaded)));
                return;
              }

              if (result.isGallerySave) {
                messenger.showSnackBar(SnackBar(
                  content: Text(localizations.successImageSavedGallery),
                  action: SnackBarAction(
                    label: localizations.openGallery,
                    onPressed: () =>
                        QuillNativeProvider.instance.openGalleryApp(),
                  ),
                ));
                return;
              }

              if (isDesktopApp) {
                final imageFilePath = result.imageFilePath;
                if (imageFilePath == null) {
                  // User canceled the system save dialog.
                  return;
                }

                messenger.showSnackBar(
                  SnackBar(
                    content: Text(localizations.successImageSaved),
                    // On macOS the app only has access to the picked file from the system save
                    // dialog and not the directory where it was saved.
                    // Opening the directory of that file requires entitlements on macOS
                    // See https://pub.dev/packages/url_launcher#macos-file-access-configuration
                    // Open the saved image file instead of the directory
                    action: defaultTargetPlatform == TargetPlatform.macOS
                        ? SnackBarAction(
                            label: localizations.openFile,
                            onPressed: () => launchUrl(Uri.file(imageFilePath)),
                          )
                        : SnackBarAction(
                            label: localizations.openFileLocation,
                            onPressed: () => launchUrl(
                                Uri.directory(p.dirname(imageFilePath))),
                          ),
                  ),
                );

                return;
              }

              throw StateError(
                  'Image save result is not handled on $defaultTargetPlatform');
            },
          ),
          ListTile(
            leading: const Icon(Icons.zoom_in),
            title: Text(context.loc.zoom),
            onTap: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => ImageTapWrapper(
                  imageUrl: imageSource,
                  config: config,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
