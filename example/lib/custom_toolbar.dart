import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';

/// Custom toolbar that uses the buttons of [`flutter_quill`](https://pub.dev/packages/flutter_quill).
///
/// See also: [Custom toolbar](https://github.com/singerdmx/flutter-quill/blob/master/doc/custom_toolbar.md).
class CustomToolbar extends StatelessWidget {
  const CustomToolbar({super.key, required this.controller});

  final QuillController controller;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Wrap(
        children: [
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
    );
  }
}
