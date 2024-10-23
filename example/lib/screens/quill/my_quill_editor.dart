import 'dart:io' as io show Directory, File;

import 'package:cached_network_image/cached_network_image.dart'
    show CachedNetworkImageProvider;
import 'package:desktop_drop/desktop_drop.dart' show DropTarget;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/internal.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:path/path.dart' as path;

import '../../extensions/scaffold_messenger.dart';
import 'embeds/timestamp_embed.dart';
import 'http_url.dart';

class MyQuillEditor extends StatelessWidget {
  const MyQuillEditor({
    required this.controller,
    required this.config,
    required this.scrollController,
    required this.focusNode,
    super.key,
  });

  final QuillController controller;
  final QuillEditorConfig config;
  final ScrollController scrollController;
  final FocusNode focusNode;

  @override
  Widget build(BuildContext context) {
    final defaultTextStyle = DefaultTextStyle.of(context);
    return Builder(builder: (context) {
      final editor = QuillEditor(
        scrollController: scrollController,
        focusNode: focusNode,
        controller: controller,
        config: config.copyWith(
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
            final newFileName =
                'gifFile-${DateTime.now().toIso8601String()}.gif';
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
                    imageEmbedConfig: QuillEditorImageEmbedConfig(
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
                          if (isHttpUrl(imageUrl)) {
                            return CachedNetworkImageProvider(
                              imageUrl,
                            );
                          }
                        }

                        if (imageUrl.startsWith('assets/')) {
                          return AssetImage(imageUrl);
                        }
                        return null;
                      },
                    ),
                    videoEmbedConfig: QuillEditorVideoEmbedConfig(
                      customVideoBuilder: (videoUrl, readOnly) {
                        // Example: Check for YouTube Video URL and return your
                        // YouTube video widget here.

                        // See https://github.com/singerdmx/flutter-quill/releases/tag/v10.8.0
                        // and https://github.com/singerdmx/flutter-quill/pull/2286

                        // Otherwise return null to fallback to the defualt logic
                        return null;
                      },
                    ),
                  )),
            TimeStampEmbedBuilderWidget(),
          ],
        ),
      );
      // The `desktop_drop` plugin doesn't support iOS platform for now
      if (isIosApp) {
        return editor;
      }
      return DropTarget(
        onDragDone: (details) {
          final scaffoldMessenger = ScaffoldMessenger.of(context);
          final file = details.files.first;
          const imageFileExtensions = <String>[
            '.jpeg',
            '.png',
            '.jpg',
            '.gif',
            '.webp',
            '.tif',
            '.heic'
          ];
          final isSupported = imageFileExtensions.any(file.name.endsWith);
          if (!isSupported) {
            scaffoldMessenger.showText(
              'Only images are supported right now: ${file.mimeType}, ${file.name}, ${file.path}, $imageFileExtensions',
            );
            return;
          }
          controller.insertImageBlock(
            imageSource: file.path,
          );
          scaffoldMessenger.showText('Image is inserted.');
        },
        child: editor,
      );
    });
  }
}
