# Custom Toolbar

If you want to use a custom toolbar but still want the support of this library
You can use the `QuillBaseToolbar` which is the base for the `QuillToolbar`

Example:

```dart
QuillProvider(
  configurations: QuillConfigurations(
    controller: _controller,
    sharedConfigurations: const QuillSharedConfigurations(),
  ),
  child: Column(
    children: [
      QuillBaseToolbar(
        configurations: QuillBaseToolbarConfigurations(
          toolbarSize: 15 * 2,
          multiRowsDisplay: false,
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
                options: const QuillToolbarToggleStyleButtonOptions(
                  iconData: Icons.format_bold,
                  iconSize: 20,
                ),
              ),
              QuillToolbarToggleStyleButton(
                attribute: Attribute.italic,
                controller: controller,
                options: const QuillToolbarToggleStyleButtonOptions(
                  iconData: Icons.format_italic,
                  iconSize: 20,
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
                  iconSize: 20,
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
                  iconSize: 20,
                ),
              ),
              QuillToolbarToggleStyleButton(
                attribute: Attribute.ul,
                controller: controller,
                options: const QuillToolbarToggleStyleButtonOptions(
                  iconData: Icons.format_list_bulleted,
                  iconSize: 20,
                ),
              ),
              QuillToolbarToggleStyleButton(
                attribute: Attribute.blockQuote,
                controller: controller,
                options: const QuillToolbarToggleStyleButtonOptions(
                  iconData: Icons.format_quote,
                  iconSize: 20,
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
      ),
      Expanded(
        child: QuillEditor.basic(
          configurations: const QuillEditorConfigurations(
            readOnly: false,
            placeholder: 'Write your notes',
            padding: EdgeInsets.all(16),
          ),
        ),
      )
    ],
  ),
)
```

if you want a more customized toolbar feel free to create your own and use the `controller` to interact with the editor. checkout the `QuillToolbar` and the buttons inside it to see an example of how that will work
