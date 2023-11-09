# Migration guide

Here you can find the migration guide between different versions, you can contribute to this page to make it better for everyone!!


- [Migration guide](#migration-guide)
  - [from 7.0.0 to 8.0.0](#from-700-to-800)

## from 7.0.0 to 8.0.0

We have refactored a lot of the base code to allow you to customize everything you want, and it allows us to add new configurations very easily using inherited widgets without passing configurations all over the constructors everywhere which will be very hard to test, fix bugs, and maintain

1. Passing the controller

The controller code (should be the same)
```dart
QuillController _controller = QuillController.basic();
```

**Old code**:
```dart

Column(
  children: [
    QuillToolbar.basic(controller: _controller),
    Expanded(
      child: QuillEditor.basic(
          controller: _controller,
          readOnly: false, // true for view only mode
      ),
    )
  ],
)

```

**New code**:

```dart
QuillProvider(
  configurations: QuillConfigurations(
    controller: _controller,
    sharedConfigurations: const QuillSharedConfigurations(),
  ),
  child: Column(
    children: [
      const QuillToolbar(),
      Expanded(
        child: QuillEditor.basic(
          configurations: const QuillEditorConfigurations(
            readOnly: false, // true for view only mode
          ),
        ),
      )
    ],
  ),
)
```

The `QuillProvider` is an inherited widget that allows you to pass configurations once and use them in the children of it. here we are passing the `_controller` once in the configurations of `QuillProvider` and the `QuillToolbar` and `QuillEditor` will get the `QuillConfigurations` internally, if it doesn't exist you will get an exception.

we also added the `sharedConfigurations` which allow you to configure shared things like the `Local` so you don't have to define them twice, we have removed those from the `QuillToolbar` and `QuillEditor`

2. Regarding The QuillToolbar buttons, we have renamed almost all the buttons, examples:
   - `QuillHistory` to `QuillToolbarHistoryButton`
   - `IndentButton` to `QuillToolbarIndentButton`

and they usually have two parameters, `controller` and `options`, for example the type for the buttons
   - `QuillToolbarHistoryButton` have `QuillToolbarHistoryButtonOptions`
   - `QuillToolbarIndentButton` have `QuillToolbarIndentButtonOptions`
   - `QuillToolbarClearFormatButton` have `QuillToolbarClearFormatButtonOptions`

All the options have parent `QuillToolbarBaseButtonOptions` which have common things like

```dart
  /// By default it will use Icon data from Icons that come from material
  /// library for each button, to change this, please pass a different value
  /// If there is no Icon in this button then pass null in the child class
  final IconData? iconData;

  /// To change the icon size pass a different value, by default will be
  /// [kDefaultIconSize].
  /// This will be used for all the buttons but you can override this
  final double globalIconSize;

  /// The factor of how much larger the button is in relation to the icon,
  /// by default it will be [kIconButtonFactor].
  final double globalIconButtonFactor;

  /// To do extra logic after pressing the button
  final VoidCallback? afterButtonPressed;

  /// By default it will use the default tooltip which already localized
  final String? tooltip;

  /// Use custom theme
  final QuillIconTheme? iconTheme;

  /// If you want to dispaly a differnet widget based using a builder
  final QuillToolbarButtonOptionsChildBuilder<T, I> childBuilder;

  /// By default it will be from the one in [QuillProvider]
  /// To override it you must pass not null controller
  /// if you wish to use the controller in the [childBuilder], please use the
  /// one from the extraOptions since it will be not null and will be the one
  /// which will be used from the quill toolbar
  final QuillController? controller;
```

The `QuillToolbarBaseButtonOptions is`:
```dart
/// The [T] is the option for the button, usually should reference itself
/// it's used in [childBuilder] so the developer can customize this when using it
/// The [I] is an extra option for the button, usually for its state
@immutable
class QuillToolbarBaseButtonOptions<T, I> extends Equatable
```

Example for the clear format button:

```dart
class QuillToolbarClearFormatButtonExtraOptions
    extends QuillToolbarBaseButtonExtraOptions {
  const QuillToolbarClearFormatButtonExtraOptions({
    required super.controller,
    required super.context,
    required super.onPressed,
  });
}

class QuillToolbarClearFormatButtonOptions
    extends QuillToolbarBaseButtonOptions<QuillToolbarClearFormatButtonOptions,
        QuillToolbarClearFormatButtonExtraOptions> {
  const QuillToolbarClearFormatButtonOptions({
    super.iconData,
    super.afterButtonPressed,
    super.childBuilder,
    super.controller,
    super.iconTheme,
    super.tooltip,
    this.iconSize,
  });

  final double? iconSize;
}

```

The base for extra options:
```dart
@immutable
class QuillToolbarBaseButtonExtraOptions extends Equatable {
  const QuillToolbarBaseButtonExtraOptions({
    required this.controller,
    required this.context,
    required this.onPressed,
  });

  /// If you need the not null controller for some usage in the [childBuilder]
  /// Then please use this instead of the one in the [options]
  final QuillController controller;

  /// If the child builder you must use this when the widget is tapped or pressed
  /// in order to do what it expected to do
  final VoidCallback? onPressed;

  final BuildContext context;
  @override
  List<Object?> get props => [
        controller,
      ];
}
```

which usually share common things, it also add an extra property which was not exist, which is `childBuilder` which allow to rendering of custom widget based on the state of the button and the options it

```dart
QuillToolbar(
    configurations: QuillToolbarConfigurations(
        buttonOptions: QuillToolbarButtonOptions(
        clearFormat: QuillToolbarClearFormatButtonOptions(
            childBuilder: (options, extraOptions) {
            return IconButton.filled(
                onPressed: extraOptions.onPressed,
                icon: const Icon(
                    CupertinoIcons.clear // or options.iconData
                    ),
            );
            },
        ),
        ),
    ),
),
```

the `extraOptions` usually contains the state variables and the events that you need to trigger like the `onPressed`, it also has the end context and the controller that will be used
while the `options` has the custom controller for each button and it's nullable because there could be no custom controller so we will just use the global one

3. The `QuillToolbar` and `QuillToolbar.basic()` factory constructor

since the basic factory constructor has more options than the original `QuillToolbar` which doesn't make much sense, at least to some developers, we have refactored the `QuillToolbar.basic()` to a different widget called the `QuillToolbar` and the `QuillToolbar` has been renamed to `QuillBaseToolbar` which is the base for `QuillToolbar` or any custom toolbar, sure you can create custom toolbar from scratch by just using the `controller` but if you want more support from the library use the `QuillBaseToolbar`

the children widgets of the new `QuillToolbar` and `QuillEditor` access to their configurations by another two inherited widgets
since `QuillToolbar` and `QuillEditor` take the configuration class and provide them internally using `QuillToolbarProvider` and `QuillEditorProvider`
however the `QuillBaseToolbar` has a little bit different configurations so it has a different provider called `QuillBaseToolbarProvider` and it also already provided by default

But there is one **note**: 
> If you are using the toolbar buttons like `QuillToolbarHistoryButton`, `QuillToolbarToggleStyleButton` somewhere like the the custom toolbar (using `QuillBaseToolbar` or any custom widget) then you must provide them with `QuillToolbarProvider` inherited widget, you don't have to do this if you are using the `QuillToolbar` since it will be done for you
>

Example of a custom toolbar:

```dart
QuillProvider(
  configurations: QuillConfigurations(
    controller: _controller,
    sharedConfigurations: const QuillSharedConfigurations(),
  ),
  child: Column(
    children: [
      QuillToolbarProvider(
        toolbarConfigurations: const QuillToolbarConfigurations(),
        child: QuillBaseToolbar(
          configurations: QuillBaseToolbarConfigurations(
            toolbarSize: 15 * 2,
            multiRowsDisplay: false,
            childrenBuilder: (context) {
              final controller = context.requireQuillController; // new extension which is a little bit shorter to access the quill provider then the controller

              // there are many options, feel free to explore them all!!
              return [
                QuillToolbarHistoryButton(
                  controller: controller,
                  options: const QuillToolbarHistoryButtonOptions(
                      isUndo: true),
                ),
                QuillToolbarHistoryButton(
                  controller: controller,
                  options: const QuillToolbarHistoryButtonOptions(
                      isUndo: false),
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
                  options:
                      const QuillToolbarSelectHeaderStyleButtonsOptions(
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

4. The `QuillEditor` and `QuillEditor.basic()`

since the `QuillEditor.basic()` is a lighter version than the original `QuillEditor` since it has fewer required configurations we didn't change much, other than the configuration class, but we must inform you if you plan on sending pull request or you are a maintainer and when you add new property or change anything in `QuillEditorConfigurations` please regenerate the `copyWith` (using IDE extension or plugin) otherwise the `QuilEditor.basic()` will not apply some configurations

we have disabled the line numbers in the code block by default, you can enable them again using the following:

```dart
QuillEditor.basic(
    configurations: const QuillEditorConfigurations(
            elementOptions: QuillEditorElementOptions(
            codeBlock: QuillEditorCodeBlockElementOptions(
                enableLineNumbers: true,
            ),
        ),
    ),
)
```

5. `QuillCustomButton`:

We have renamed the property `icon` to `iconData` to indicate it an icon data and not an icon widget
```dart
    QuillCustomButton(
        iconData: Icons.ac_unit,
        onTap: () {
          debugPrint('snowflake');
        }
    ),
```

6. Using custom local for both `QuillEditor` and `QuillToolbar`

We have added shared configurations property for shared things
```dart
 QuillProvider(
  configurations: QuillConfigurations(
    controller: _controller,
    sharedConfigurations: const QuillSharedConfigurations(
      locale: Locale('fr'),
    ),
  ),
  child: Column(
    children: [
      const QuillToolbar(
        configurations: QuillToolbarConfigurations(),
      ),
      Expanded(
        child: QuillEditor.basic(
          configurations: const QuillEditorConfigurations(),
        ),
      )
    ],
  ),
)
```

7. Custom Images for other platforms (excluding the web)

We have added new properties `width`, `height`, `margin`, `alignment` for all platforms other than mobile and web for the images for example

```dart
{
      "insert": {
         "image": "https://user-images.githubusercontent.com/122956/72955931-ccc07900-3d52-11ea-89b1-d468a6e2aa2b.png"
      },
      "attributes":{
         "style":"width: 50; height: 50; margin: 10; alignment: topLeft"
      }
}
```

8. Other Improvements

You don't need anything to get this done, we have used const more when possible, removed unused events, flutter best practices, converted to stateless widgets when possible, and used better ways to listen for changes example:
 
 instead of 

```dart
MediaQuery.of(context).size;
```

we will use
```dart
MediaQuery.sizeOf(context);
```
We also minimized the number of rebuilds using more efficient logic and there is more.

9. More options

We have added more options in the extension package, for all the buttons, configurations, animations, enable and disable things

If you are facing any issues or questions feel free to ask us on GitHub issues
