import 'dart:io' as io show File;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/flutter_quill_internal.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:google_fonts/google_fonts.dart';
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
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Cropper',
          aspectRatioPresets: [
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.ratio3x2,
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.ratio4x3,
            CropAspectRatioPreset.ratio16x9
          ],
          toolbarColor: Colors.deepOrange,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
        ),
        IOSUiSettings(
          title: 'Cropper',
          aspectRatioPresets: [
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.ratio3x2,
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.ratio4x3,
            CropAspectRatioPreset.ratio16x9
          ],
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
    if (kIsWeb) {
      controller.insertImageBlock(imageSource: newImage);
      return;
    }
    final newSavedImage = await saveImage(io.File(newImage));
    controller.insertImageBlock(imageSource: newSavedImage);
  }

  Future<void> onImageInsert(String image, QuillController controller) async {
    if (kIsWeb || isHttpBasedUrl(image)) {
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
                  QuillToolbarSelectLineHeightStyleDropdownButton(
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
          controller: controller,

          /// configurations parameter:
          ///   Optional: if not provided will use the configuration set when the controller was instantiated.
          ///   Override: Provide parameter here to override the default configuration - useful if configuration will change.
          configurations: QuillSimpleToolbarConfigurations(
            showAlignmentButtons: true,
            multiRowsDisplay: true,
            fontFamilyValues: {
              'Amatic': GoogleFonts.amaticSc().fontFamily!,
              'Annie': GoogleFonts.annieUseYourTelescope().fontFamily!,
              'Formal': GoogleFonts.petitFormalScript().fontFamily!,
              'Roboto': GoogleFonts.roboto().fontFamily!
            },
            fontSizesValues: const {
              '14': '14.0',
              '16': '16.0',
              '18': '18.0',
              '20': '20.0',
              '22': '22.0',
              '24': '24.0',
              '26': '26.0',
              '28': '28.0',
              '30': '30.0',
              '35': '35.0',
              '40': '40.0'
            },
            searchButtonType: SearchButtonType.modern,
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
                  onImageInsertCallback: isAndroidApp || isIosApp || kIsWeb
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
