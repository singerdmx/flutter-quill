import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/extensions.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:flutter_quill_extensions/presentation/embeds/widgets/image.dart'
    show getImageProviderByImageSource, imageFileExtensions;
import 'package:image_cropper/image_cropper.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:quill_html_converter/quill_html_converter.dart';
import 'package:share_plus/share_plus.dart' show Share;

import '../extensions/scaffold_messenger.dart';
import '../shared/widgets/home_screen_button.dart';

@immutable
class QuillScreenArgs {
  const QuillScreenArgs({required this.document});

  final Document document;
}

class QuillScreen extends StatefulWidget {
  const QuillScreen({
    required this.args,
    super.key,
  });

  final QuillScreenArgs args;

  static const routeName = '/quill';

  @override
  State<QuillScreen> createState() => _QuillScreenState();
}

class _QuillScreenState extends State<QuillScreen> {
  final _controller = QuillController.basic();
  var _isReadOnly = false;

  @override
  void initState() {
    super.initState();
    _controller.document = widget.args.document;
  }

  Future<void> onImageInsertWithCropping(
      String image, QuillController controller) async {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: image,
      aspectRatioPresets: [
        CropAspectRatioPreset.square,
        CropAspectRatioPreset.ratio3x2,
        CropAspectRatioPreset.original,
        CropAspectRatioPreset.ratio4x3,
        CropAspectRatioPreset.ratio16x9
      ],
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Cropper',
          toolbarColor: Colors.deepOrange,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
        ),
        IOSUiSettings(
          title: 'Cropper',
        ),
        WebUiSettings(
          context: context,
        ),
      ],
    );
    final newImage = croppedFile?.path;
    if (newImage == null) {
      return;
    }
    if (isWeb()) {
      controller.insertImageBlock(imageSource: newImage);
      return;
    }
    final newSavedImage = await saveImage(File(newImage));
    controller.insertImageBlock(imageSource: newSavedImage);
  }

  Future<void> onImageInsert(String image, QuillController controller) async {
    if (isWeb()) {
      controller.insertImageBlock(imageSource: image);
      return;
    }
    final newSavedImage = await saveImage(File(image));
    controller.insertImageBlock(imageSource: newSavedImage);
  }

  /// Copies the picked file from temporary cache to applications directory
  Future<String> saveImage(File file) async {
    final appDocDir = await getApplicationDocumentsDirectory();
    final copiedFile = await file.copy(path.join(
      appDocDir.path,
      '${DateTime.now().toIso8601String()}${path.extension(file.path)}',
    ));
    return copiedFile.path;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Quill'),
        actions: [
          IconButton(
            tooltip: 'Load with HTML',
            onPressed: () {
              final html = _controller.document.toDelta().toHtml();
              _controller.document =
                  Document.fromDelta(DeltaHtmlExt.fromHtml(html));
            },
            icon: const Icon(Icons.html),
          ),
          IconButton(
            tooltip: 'Share',
            onPressed: () {
              final plainText = _controller.document.toPlainText(
                FlutterQuillEmbeds.defaultEditorBuilders(),
              );
              if (plainText.trim().isEmpty) {
                ScaffoldMessenger.of(context).showText(
                  "We can't share empty document, please enter some text first",
                );
                return;
              }
              Share.share(plainText);
            },
            icon: const Icon(Icons.share),
          ),
          const HomeScreenButton(),
        ],
      ),
      body: QuillProvider(
        configurations: QuillConfigurations(
          controller: _controller,
          sharedConfigurations: QuillSharedConfigurations(
            animationConfigurations: QuillAnimationConfigurations.disableAll(),
            extraConfigurations: const {
              QuillSharedExtensionsConfigurations.key:
                  QuillSharedExtensionsConfigurations(
                assetsPrefix: 'assets',
              ),
            },
          ),
        ),
        child: Column(
          children: [
            if (!_isReadOnly)
              QuillToolbar(
                configurations: QuillToolbarConfigurations(
                  embedButtons: FlutterQuillEmbeds.toolbarButtons(
                    imageButtonOptions: QuillToolbarImageButtonOptions(
                      imageButtonConfigurations:
                          QuillToolbarImageConfigurations(
                        onImageInsertCallback: isAndroid(supportWeb: false) ||
                                isIOS(supportWeb: false) ||
                                isWeb()
                            ? onImageInsertWithCropping
                            : onImageInsert,
                      ),
                    ),
                  ),
                ),
              ),
            Builder(
              builder: (context) {
                return Expanded(
                  child: QuillEditor.basic(
                    configurations: QuillEditorConfigurations(
                      scrollable: true,
                      readOnly: _isReadOnly,
                      placeholder: 'Start writting your notes...',
                      padding: const EdgeInsets.all(16),
                      embedBuilders: isWeb()
                          ? FlutterQuillEmbeds.editorWebBuilders()
                          : FlutterQuillEmbeds.editorBuilders(
                              imageEmbedConfigurations:
                                  QuillEditorImageEmbedConfigurations(
                                imageErrorWidgetBuilder:
                                    (context, error, stackTrace) {
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
                                    assetsPrefix:
                                        QuillSharedExtensionsConfigurations.get(
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
                            final scaffoldMessenger =
                                ScaffoldMessenger.of(context);
                            final file = details.files.first;
                            final isSupported = imageFileExtensions
                                .any((ext) => file.name.endsWith(ext));
                            if (!isSupported) {
                              scaffoldMessenger.showText(
                                'Only images are supported right now: ${file.mimeType}, ${file.name}, ${file.path}, $imageFileExtensions',
                              );
                              return;
                            }
                            _controller.insertImageBlock(
                              imageSource: file.path,
                            );
                            scaffoldMessenger.showText('Image is inserted.');
                          },
                          child: rawEditor,
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(_isReadOnly ? Icons.lock : Icons.edit),
        onPressed: () => setState(() => _isReadOnly = !_isReadOnly),
      ),
    );
  }
}
