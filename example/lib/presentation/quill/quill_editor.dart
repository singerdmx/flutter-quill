import 'package:cached_network_image/cached_network_image.dart'
    show CachedNetworkImageProvider;
import 'package:desktop_drop/desktop_drop.dart' show DropTarget;
import 'package:flutter/material.dart';
import 'package:flutter_quill/extensions.dart' show isAndroid, isIOS, isWeb;
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:flutter_quill_extensions/presentation/embeds/widgets/image.dart'
    show getImageProviderByImageSource, imageFileExtensions;

import '../extensions/scaffold_messenger.dart';

class MyQuillEditor extends StatelessWidget {
  const MyQuillEditor({
    required this.configurations,
    required this.scrollController,
    required this.focusNode,
    super.key,
  });

  final QuillEditorConfigurations configurations;
  final ScrollController scrollController;
  final FocusNode focusNode;

  @override
  Widget build(BuildContext context) {
    return QuillEditor(
      scrollController: scrollController,
      focusNode: focusNode,
      configurations: configurations.copyWith(
        scrollable: true,
        placeholder: 'Start writting your notes...',
        padding: const EdgeInsets.all(16),
        embedBuilders: isWeb()
            ? FlutterQuillEmbeds.editorWebBuilders()
            : FlutterQuillEmbeds.editorBuilders(
                imageEmbedConfigurations: QuillEditorImageEmbedConfigurations(
                  imageErrorWidgetBuilder: (context, error, stackTrace) {
                    return Text(
                      'Error while loading an image: ${error.toString()}',
                    );
                  },
                  imageProviderBuilder: (imageUrl) {
                    // cached_network_image is supported
                    // only for Android, iOS and web

                    // We will use it only if image from network
                    if (isAndroid(supportWeb: false) ||
                        isIOS(supportWeb: false) ||
                        isWeb()) {
                      if (isHttpBasedUrl(imageUrl)) {
                        return CachedNetworkImageProvider(
                          imageUrl,
                        );
                      }
                    }
                    return getImageProviderByImageSource(
                      imageUrl,
                      imageProviderBuilder: null,
                      assetsPrefix: QuillSharedExtensionsConfigurations.get(
                              context: context)
                          .assetsPrefix,
                    );
                  },
                ),
              ),
        builder: (context, rawEditor) {
          // The `desktop_drop` plugin doesn't support iOS platform for now
          if (isIOS(supportWeb: false)) {
            return rawEditor;
          }
          return DropTarget(
            onDragDone: (details) {
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              final file = details.files.first;
              final isSupported = imageFileExtensions.any(file.name.endsWith);
              if (!isSupported) {
                scaffoldMessenger.showText(
                  'Only images are supported right now: ${file.mimeType}, ${file.name}, ${file.path}, $imageFileExtensions',
                );
                return;
              }
              context.requireQuillController.insertImageBlock(
                imageSource: file.path,
              );
              scaffoldMessenger.showText('Image is inserted.');
            },
            child: rawEditor,
          );
        },
      ),
    );
  }
}
