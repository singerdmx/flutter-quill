import 'dart:io' as io show Directory, File;

import 'package:cached_network_image/cached_network_image.dart'
    show CachedNetworkImageProvider;
import 'package:desktop_drop/desktop_drop.dart' show DropTarget;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/flutter_quill_internal.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
// ignore: implementation_imports
import 'package:flutter_quill_extensions/src/editor/image/widgets/image.dart'
    show getImageProviderByImageSource, imageFileExtensions;
import 'package:path/path.dart' as path;

import '../../extensions/scaffold_messenger.dart';
import 'embeds/timestamp_embed.dart';

class MyQuillEditor extends StatelessWidget {
  const MyQuillEditor({
    required this.controller,
    required this.configurations,
    required this.scrollController,
    required this.focusNode,
    super.key,
  });

  final QuillController controller;
  final QuillEditorConfigurations configurations;
  final ScrollController scrollController;
  final FocusNode focusNode;

  @override
  Widget build(BuildContext context) {
    final defaultTextStyle = DefaultTextStyle.of(context);
    return QuillEditor(
      scrollController: scrollController,
      focusNode: focusNode,
      controller: controller,
      configurations: configurations.copyWith(
        elementOptions: const QuillEditorElementOptions(
          codeBlock: QuillEditorCodeBlockElementOptions(
            enableLineNumbers: true,
          ),
          orderedList: QuillEditorOrderedListElementOptions(),
          unorderedList: QuillEditorUnOrderedListElementOptions(
            useTextColorForDot: true,
          ),
        ),
        customStyles: DefaultStyles(
          h1: DefaultTextBlockStyle(
            defaultTextStyle.style.copyWith(
              fontSize: 32,
              height: 1.15,
              fontWeight: FontWeight.w300,
            ),
            HorizontalSpacing.zero,
            const VerticalSpacing(16, 0),
            VerticalSpacing.zero,
            null,
          ),
          sizeSmall: defaultTextStyle.style.copyWith(fontSize: 9),
        ),
        scrollable: true,
        placeholder: 'Start writing your notes...',
        padding: const EdgeInsets.all(16),
        onImagePaste: (imageBytes) async {
          if (kIsWeb) {
            return null;
          }
          // We will save it to system temporary files
          final newFileName =
              'imageFile-${DateTime.now().toIso8601String()}.png';
          final newPath = path.join(
            io.Directory.systemTemp.path,
            newFileName,
          );
          final file = await io.File(
            newPath,
          ).writeAsBytes(imageBytes, flush: true);
          return file.path;
        },
        onGifPaste: (gifBytes) async {
          if (kIsWeb) {
            return null;
          }
          // We will save it to system temporary files
          final newFileName = 'gifFile-${DateTime.now().toIso8601String()}.gif';
          final newPath = path.join(
            io.Directory.systemTemp.path,
            newFileName,
          );
          final file = await io.File(
            newPath,
          ).writeAsBytes(gifBytes, flush: true);
          return file.path;
        },
        embedBuilders: [
          ...(kIsWeb
              ? FlutterQuillEmbeds.editorWebBuilders()
              : FlutterQuillEmbeds.editorBuilders(
                  imageEmbedConfigurations: QuillEditorImageEmbedConfigurations(
                    imageErrorWidgetBuilder: (context, error, stackTrace) {
                      return Text(
                        'Error while loading an image: ${error.toString()}',
                      );
                    },
                    imageProviderBuilder: (context, imageUrl) {
                      // cached_network_image is supported
                      // only for Android, iOS and web

                      // We will use it only if image from network
                      if (isAndroidApp || isIosApp || kIsWeb) {
                        if (isHttpBasedUrl(imageUrl)) {
                          return CachedNetworkImageProvider(
                            imageUrl,
                          );
                        }
                      }
                      return getImageProviderByImageSource(
                        imageUrl,
                        imageProviderBuilder: null,
                        context: context,
                        assetsPrefix: QuillSharedExtensionsConfigurations.get(
                                context: context)
                            .assetsPrefix,
                      );
                    },
                  ),
                  videoEmbedConfigurations: QuillEditorVideoEmbedConfigurations(
                    // Loading YouTube videos on Desktop is not supported yet
                    // when using iframe platform view
                    youtubeVideoSupportMode: isDesktopApp
                        ? YoutubeVideoSupportMode.customPlayerWithDownloadUrl
                        : YoutubeVideoSupportMode.iframeView,
                  ),
                )),
          TimeStampEmbedBuilderWidget(),
        ],
        builder: (context, rawEditor) {
          // The `desktop_drop` plugin doesn't support iOS platform for now
          if (isIosApp) {
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
