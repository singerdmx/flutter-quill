# Custom Toolbar

If you want to use a custom toolbar but still want the support of this library,
You can use the `QuillBaseToolbar` which is the base for the `QuillToolbar`

Example:

```dart
QuillToolbar.simple(
  configurations: const QuillSimpleToolbarConfigurations(
    buttonOptions: QuillToolbarButtonOptions(
      base: QuillToolbarBaseButtonOptions(
        globalIconSize: 20,
        globalIconButtonFactor: 1.4,
      ),
    ),
  ),
  child: SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Row(
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
        // This is an implementation that only is used on
        // flutter_quill and it's not originally 
        // implemented in Quill JS API, so it could cause conflicts
        // with the original Quill Delta format
        QuillToolbarSelectLineHeightStyleDropdownButton(
          controller: globalController,
        ),
        const VerticalDivider(),
        QuillToolbarSelectHeaderStyleButton(
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
)
```

if you want a more customized toolbar feel free to create your own and use the `controller` to interact with the editor.
checkout the `QuillToolbar` and the buttons inside it to see an example of how that will work
