# 🎨 Custom Toolbar

You can use the `QuillController` in your custom toolbar or use the button widgets of the `QuillSimpleToolbar`:

```dart
SingleChildScrollView(
  scrollDirection: Axis.horizontal,
  child: Wrap(
    children: [
      IconButton(
        onPressed: () => context.read<SettingsCubit>().updateSettings(
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
)
```

