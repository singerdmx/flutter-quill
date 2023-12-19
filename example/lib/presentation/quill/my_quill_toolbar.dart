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

import '../settings/cubit/settings_cubit.dart';
import 'embeds/timestamp_embed.dart';

class MyQuillToolbar extends StatelessWidget {
  const MyQuillToolbar({
    required this.controller,
    required this.focusNode,
    super.key,
  });

  final QuillController controller;
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
    if (isWeb() || isHttpBasedUrl(image)) {
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
          return QuillToolbar(
            configurations: const QuillToolbarConfigurations(),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Wrap(
                children: [
                  IconButton(
                    onPressed: () => context
                        .read<SettingsCubit>()
                        .updateSettings(
                            state.copyWith(useCustomQuillToolbar: false)),
                    icon: const Icon(
                      Icons.width_normal,
                    ),
                  ),
                  QuillToolbarHistoryButton(
                    isUndo: true,
                    controller: controller,
                  ),
                  QuillToolbarHistoryButton(
                    isUndo: false,
                    controller: controller,
                  ),
                  QuillToolbarToggleStyleButton(
                    options: const QuillToolbarToggleStyleButtonOptions(),
                    controller: controller,
                    attribute: Attribute.bold,
                  ),
                  QuillToolbarToggleStyleButton(
                    options: const QuillToolbarToggleStyleButtonOptions(),
                    controller: controller,
                    attribute: Attribute.italic,
                  ),
                  QuillToolbarToggleStyleButton(
                    controller: controller,
                    attribute: Attribute.underline,
                  ),
                  QuillToolbarClearFormatButton(
                    controller: controller,
                  ),
                  const VerticalDivider(),
                  QuillToolbarImageButton(
                    controller: controller,
                  ),
                  QuillToolbarCameraButton(
                    controller: controller,
                  ),
                  QuillToolbarVideoButton(
                    controller: controller,
                  ),
                  const VerticalDivider(),
                  QuillToolbarColorButton(
                    controller: controller,
                    isBackground: false,
                  ),
                  QuillToolbarColorButton(
                    controller: controller,
                    isBackground: true,
                  ),
                  const VerticalDivider(),
                  QuillToolbarSelectHeaderStyleDropdownButton(
                    controller: controller,
                  ),
                  const VerticalDivider(),
                  QuillToolbarToggleCheckListButton(
                    controller: controller,
                  ),
                  QuillToolbarToggleStyleButton(
                    controller: controller,
                    attribute: Attribute.ol,
                  ),
                  QuillToolbarToggleStyleButton(
                    controller: controller,
                    attribute: Attribute.ul,
                  ),
                  QuillToolbarToggleStyleButton(
                    controller: controller,
                    attribute: Attribute.inlineCode,
                  ),
                  QuillToolbarToggleStyleButton(
                    controller: controller,
                    attribute: Attribute.blockQuote,
                  ),
                  QuillToolbarIndentButton(
                    controller: controller,
                    isIncrease: true,
                  ),
                  QuillToolbarIndentButton(
                    controller: controller,
                    isIncrease: false,
                  ),
                  const VerticalDivider(),
                  QuillToolbarLinkStyleButton(controller: controller),
                ],
              ),
            ),
          );
        }
        return QuillToolbar.simple(
          configurations: QuillSimpleToolbarConfigurations(
            controller: controller,
            showAlignmentButtons: true,
            headerStyleType: HeaderStyleType.dropdown,
            buttonOptions: QuillSimpleToolbarButtonOptions(
              base: QuillToolbarBaseButtonOptions(
                // Request editor focus when any button is pressed
                afterButtonPressed: focusNode.requestFocus,
                // globalIconSize: 18,
              ),
              selectHeaderStyleDropdownButton:
                  const QuillToolbarSelectHeaderStyleDropdownButtonOptions(
                style: TextStyle(
                  fontSize: 20,
                ),
                iconTheme: QuillIconTheme(
                  iconSelectedColor: Colors.red,
                ),
              ),
            ),
            customButtons: [
              QuillToolbarCustomButtonOptions(
                icon: const Icon(Icons.add_alarm_rounded),
                onPressed: () {
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
                icon: const Icon(Icons.dashboard_customize),
                onPressed: () {
                  context.read<SettingsCubit>().updateSettings(
                      state.copyWith(useCustomQuillToolbar: true));
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
