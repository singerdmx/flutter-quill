import 'dart:io' as io show File;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/extensions.dart' show isAndroid, isIOS, isWeb;
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart'
    show getApplicationDocumentsDirectory;

import '../extensions/scaffold_messenger.dart';
import '../settings/cubit/settings_cubit.dart';
import 'embeds/timestamp_embed.dart';

class MyQuillToolbar extends StatelessWidget {
  const MyQuillToolbar({
    required this.focusNode,
    super.key,
  });

  final FocusNode focusNode;

  Future<void> onImageInsertWithCropping(
    String image,
    QuillController controller,
    BuildContext context,
  ) async {
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
    final newSavedImage = await saveImage(io.File(newImage));
    controller.insertImageBlock(imageSource: newSavedImage);
  }

  Future<void> onImageInsert(String image, QuillController controller) async {
    if (isWeb()) {
      controller.insertImageBlock(imageSource: image);
      return;
    }
    final newSavedImage = await saveImage(io.File(image));
    controller.insertImageBlock(imageSource: newSavedImage);
  }

  /// For mobile platforms it will copies the picked file from temporary cache
  /// to applications directory
  ///
  /// for desktop platforms, it will do the same but from user files this time
  Future<String> saveImage(io.File file) async {
    final appDocDir = await getApplicationDocumentsDirectory();
    final fileExt = path.extension(file.path);
    final newFileName = '${DateTime.now().toIso8601String()}$fileExt';
    final newPath = path.join(
      appDocDir.path,
      newFileName,
    );
    final copiedFile = await file.copy(newPath);
    return copiedFile.path;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      buildWhen: (previous, current) =>
          previous.useCustomQuillToolbar != current.useCustomQuillToolbar,
      builder: (context, state) {
        if (state.useCustomQuillToolbar) {
          // For more info
          // https://github.com/singerdmx/flutter-quill/blob/master/doc/custom_toolbar.md
          return QuillBaseToolbar(
            configurations: QuillBaseToolbarConfigurations(
              toolbarSize: 15 * 2,
              multiRowsDisplay: false,
              buttonOptions: const QuillToolbarButtonOptions(
                base: QuillToolbarBaseButtonOptions(
                  globalIconSize: 30,
                ),
              ),
              childrenBuilder: (context) {
                final controller = context.requireQuillController;
                return [
                  QuillToolbarImageButton(
                    controller: controller,
                    options: const QuillToolbarImageButtonOptions(),
                  ),
                  QuillToolbarHistoryButton(
                    controller: controller,
                    options:
                        const QuillToolbarHistoryButtonOptions(isUndo: true),
                  ),
                  QuillToolbarHistoryButton(
                    controller: controller,
                    options:
                        const QuillToolbarHistoryButtonOptions(isUndo: false),
                  ),
                  QuillToolbarToggleStyleButton(
                    attribute: Attribute.bold,
                    controller: controller,
                    options: QuillToolbarToggleStyleButtonOptions(
                      childBuilder: (options, extraOptions) {
                        if (extraOptions.isToggled) {
                          return IconButton.filled(
                            onPressed: extraOptions.onPressed,
                            icon: Icon(options.iconData),
                          );
                        }
                        return IconButton(
                          onPressed: extraOptions.onPressed,
                          icon: Icon(options.iconData),
                        );
                      },
                    ),
                  ),
                  QuillToolbarToggleStyleButton(
                    attribute: Attribute.italic,
                    controller: controller,
                    options: const QuillToolbarToggleStyleButtonOptions(
                      iconData: Icons.format_italic,
                    ),
                  ),
                  QuillToolbarToggleStyleButton(
                    attribute: Attribute.underline,
                    controller: controller,
                    options: const QuillToolbarToggleStyleButtonOptions(
                      iconData: Icons.format_underline,
                      iconSize: 20,
                    ),
                  ),
                  QuillToolbarClearFormatButton(
                    controller: controller,
                    options: const QuillToolbarClearFormatButtonOptions(
                      iconData: Icons.format_clear,
                    ),
                  ),
                  VerticalDivider(
                    indent: 12,
                    endIndent: 12,
                    color: Colors.grey.shade400,
                  ),
                  QuillToolbarSelectHeaderStyleButtons(
                    controller: controller,
                    options: const QuillToolbarSelectHeaderStyleButtonsOptions(
                      iconSize: 20,
                    ),
                  ),
                  QuillToolbarToggleStyleButton(
                    attribute: Attribute.ol,
                    controller: controller,
                    options: const QuillToolbarToggleStyleButtonOptions(
                      iconData: Icons.format_list_numbered,
                      iconSize: 39,
                    ),
                  ),
                  QuillToolbarToggleStyleButton(
                    attribute: Attribute.ul,
                    controller: controller,
                    options: const QuillToolbarToggleStyleButtonOptions(
                      iconData: Icons.format_list_bulleted,
                    ),
                  ),
                  QuillToolbarToggleStyleButton(
                    attribute: Attribute.blockQuote,
                    controller: controller,
                    options: const QuillToolbarToggleStyleButtonOptions(
                      iconData: Icons.format_quote,
                      iconSize: 15,
                    ),
                  ),
                  VerticalDivider(
                    indent: 12,
                    endIndent: 12,
                    color: Colors.grey.shade400,
                  ),
                  QuillToolbarIndentButton(
                      controller: controller,
                      isIncrease: true,
                      options: const QuillToolbarIndentButtonOptions(
                        iconData: Icons.format_indent_increase,
                        iconSize: 20,
                      )),
                  QuillToolbarIndentButton(
                    controller: controller,
                    isIncrease: false,
                    options: const QuillToolbarIndentButtonOptions(
                      iconData: Icons.format_indent_decrease,
                      iconSize: 20,
                    ),
                  ),
                ];
              },
            ),
          );
        }
        return QuillToolbar(
          configurations: QuillToolbarConfigurations(
            showAlignmentButtons: true,
            buttonOptions: QuillToolbarButtonOptions(
              base: QuillToolbarBaseButtonOptions(
                // Request editor focus when any button is pressed
                afterButtonPressed: focusNode.requestFocus,
              ),
            ),
            customButtons: [
              QuillToolbarCustomButtonOptions(
                icon: const Icon(Icons.add_alarm_rounded),
                onPressed: () {
                  final controller = context.requireQuillController;
                  controller.document
                      .insert(controller.selection.extentOffset, '\n');
                  controller.updateSelection(
                    TextSelection.collapsed(
                      offset: controller.selection.extentOffset + 1,
                    ),
                    ChangeSource.local,
                  );

                  controller.document.insert(
                    controller.selection.extentOffset,
                    TimeStampEmbed(
                      DateTime.now().toString(),
                    ),
                  );

                  controller.updateSelection(
                    TextSelection.collapsed(
                      offset: controller.selection.extentOffset + 1,
                    ),
                    ChangeSource.local,
                  );

                  controller.document
                      .insert(controller.selection.extentOffset, ' ');
                  controller.updateSelection(
                    TextSelection.collapsed(
                      offset: controller.selection.extentOffset + 1,
                    ),
                    ChangeSource.local,
                  );

                  controller.document
                      .insert(controller.selection.extentOffset, '\n');
                  controller.updateSelection(
                    TextSelection.collapsed(
                      offset: controller.selection.extentOffset + 1,
                    ),
                    ChangeSource.local,
                  );
                },
              ),
              QuillToolbarCustomButtonOptions(
                icon: const Icon(Icons.ac_unit),
                onPressed: () {
                  ScaffoldMessenger.of(context)
                    ..clearSnackBars()
                    ..showText(
                      'Custom button!',
                    );
                },
              ),
            ],
            embedButtons: FlutterQuillEmbeds.toolbarButtons(
              imageButtonOptions: QuillToolbarImageButtonOptions(
                imageButtonConfigurations: QuillToolbarImageConfigurations(
                  onImageInsertCallback: isAndroid(supportWeb: false) ||
                          isIOS(supportWeb: false) ||
                          isWeb()
                      ? (image, controller) =>
                          onImageInsertWithCropping(image, controller, context)
                      : onImageInsert,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
