import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart' show Brightness, Uint8List, immutable;
import 'package:flutter/material.dart'
    show TextCapitalization, TextInputAction, TextSelectionThemeData;
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart' show experimental;

import '../../controller/quill_controller.dart';
import '../../editor_toolbar_shared/config/quill_shared_configurations.dart';
import '../../toolbar/theme/quill_dialog_theme.dart';
import '../editor_builder.dart';
import '../embed/embed_editor_builder.dart';
import '../raw_editor/raw_editor.dart';
import '../widgets/default_styles.dart';
import '../widgets/delegate.dart';
import '../widgets/link.dart';
import 'element_options.dart';
import 'search_configurations.dart';

export 'element_options.dart';

/// The configurations for the quill editor widget of flutter quill
@immutable
class QuillEditorConfigurations extends Equatable {
  /// Important note for the maintainers
  /// When editing this class please update the [copyWith] function too.
  const QuillEditorConfigurations({
    @Deprecated(
        'controller should be passed directly to the editor - this parameter will be removed in future versions.')
    this.controller,
    this.sharedConfigurations = const QuillSharedConfigurations(),
    this.scrollable = true,
    this.padding = EdgeInsets.zero,
    this.autoFocus = false,
    this.expands = false,
    this.placeholder,
    this.checkBoxReadOnly,
    this.disableClipboard = false,
    this.textSelectionThemeData,
    this.showCursor,
    this.paintCursorAboveText,
    this.enableInteractiveSelection = true,
    this.enableSelectionToolbar = true,
    this.scrollBottomInset = 0,
    this.minHeight,
    this.maxHeight,
    this.maxContentWidth,
    this.customStyles,
    this.textCapitalization = TextCapitalization.sentences,
    this.keyboardAppearance = Brightness.light,
    this.scrollPhysics,
    this.onLaunchUrl,
    this.onTapDown,
    this.onTapUp,
    this.onSingleLongTapStart,
    this.onSingleLongTapMoveUpdate,
    this.onSingleLongTapEnd,
    this.enableMarkdownStyleConversion = true,
    this.embedBuilders,
    this.unknownEmbedBuilder,
    this.searchConfigurations = const QuillSearchConfigurations(),
    this.linkActionPickerDelegate = defaultLinkActionPickerDelegate,
    this.customStyleBuilder,
    this.customRecognizerBuilder,
    this.floatingCursorDisabled = false,
    this.textSelectionControls,
    this.onImagePaste,
    this.onGifPaste,
    this.customShortcuts,
    this.customActions,
    this.detectWordBoundary = true,
    this.isOnTapOutsideEnabled = true,
    this.onTapOutside,
    this.customLinkPrefixes = const <String>[],
    this.dialogTheme,
    this.contentInsertionConfiguration,
    this.contextMenuBuilder,
    this.editorKey,
    this.requestKeyboardFocusOnCheckListChanged = false,
    this.elementOptions = const QuillEditorElementOptions(),
    this.builder,
    this.magnifierConfiguration,
    this.textInputAction = TextInputAction.newline,
    this.enableScribble = false,
    this.onScribbleActivated,
    this.scribbleAreaInsets,
    this.readOnlyMouseCursor = SystemMouseCursors.text,
    this.onPerformAction,
  });

  final QuillSharedConfigurations sharedConfigurations;

  @Deprecated('controller will be removed in future versions.')
  final QuillController? controller;

  /// The text placeholder in the quill editor
  final String? placeholder;

  /// Whether the text can be changed.
  ///
  /// When this is set to `true`, the text cannot be modified
  /// by any shortcut or keyboard operation. The text is still selectable.
  ///
  /// Defaults to `false`. Must not be `null`.
  // ignore: deprecated_member_use_from_same_package
  bool get readOnly => controller?.readOnly != false;

  /// Override [readOnly] for checkbox.
  ///
  /// When this is set to `false`, the checkbox can be checked
  /// or unchecked while [readOnly] is set to `true`.
  /// When this is set to `null`, the [readOnly] value is used.
  ///
  /// Defaults to `null`.
  final bool? checkBoxReadOnly;

  /// Disable Clipboard features
  ///
  /// when this is set to `true` clipboard can not be used
  /// this disables the clipboard notification for requesting permissions
  ///
  /// Defaults to `false`. Must not be `null`.
  final bool disableClipboard;

  /// Whether this editor should create a scrollable container for its content.
  ///
  /// When set to `true` the editor's height can be controlled by [minHeight],
  /// [maxHeight] and [expands] properties.
  ///
  /// When set to `false` the editor always expands to fit the entire content
  /// of the document and should normally be placed as a child of another
  /// scrollable widget, otherwise the content may be clipped.
  /// by default it will by true
  final bool scrollable;
  final double scrollBottomInset;

  /// Configuration to enable or disable automatic Markdown style conversions.
  ///
  /// This setting controls the behavior of input. Specifically, when enabled,
  /// entering '1.' followed by a space or '-' followed by a space
  /// will automatically convert the input into a Markdown list format.
  final bool enableMarkdownStyleConversion;

  /// Additional space around the content of this editor.
  /// by default will be [EdgeInsets.zero]
  final EdgeInsetsGeometry padding;

  /// Whether this editor should focus itself if nothing else is already
  /// focused.
  ///
  /// If true, the keyboard will open as soon as this editor obtains focus.
  /// Otherwise, the keyboard is only shown after the user taps the editor.
  ///
  /// Defaults to `false`. Cannot be `null`.
  final bool autoFocus;

  /// Whether the [onTapOutside] should be triggered or not
  /// Defaults to `true`
  /// it have default implementation, check [onTapOutside] for more
  final bool isOnTapOutsideEnabled;

  /// This will run only when [isOnTapOutsideEnabled] is true
  /// by default on desktop and web it will un-focus
  /// on mobile it will only unFocus if the kind property of
  /// event [PointerDownEvent] is [PointerDeviceKind.unknown]
  /// you can override this to fit your needs
  final Function(PointerDownEvent event, FocusNode focusNode)? onTapOutside;

  /// Whether to show cursor.
  ///
  /// The cursor refers to the blinking caret when the editor is focused.
  final bool? showCursor;
  final bool? paintCursorAboveText;

  /// The [readOnlyMouseCursor] is used for Windows, macOS when [readOnly] is [true]
  final MouseCursor readOnlyMouseCursor;

  /// Whether to enable user interface affordances for changing the
  /// text selection.
  ///
  /// For example, setting this to true will enable features such as
  /// long-pressing the editor to select text and show the
  /// cut/copy/paste menu, and tapping to move the text cursor.
  ///
  /// When this is false, the text selection cannot be adjusted by
  /// the user, text cannot be copied, and the user cannot paste into
  /// the text field from the clipboard.
  ///
  /// To disable just the selection toolbar, set enableSelectionToolbar
  /// to false.
  final bool enableInteractiveSelection;

  /// Whether to show the cut/copy/paste menu when selecting text.
  final bool enableSelectionToolbar;

  /// The minimum height to be occupied by this editor.
  ///
  /// This only has effect if [scrollable] is set to `true` and [expands] is
  /// set to `false`.
  final double? minHeight;

  /// The maximum height to be occupied by this editor.
  ///
  /// This only has effect if [scrollable] is set to `true` and [expands] is
  /// set to `false`.
  final double? maxHeight;

  /// The maximum width to be occupied by the content of this editor.
  ///
  /// If this is not null and and this editor's width is larger than this value
  /// then the contents will be constrained to the provided maximum width and
  /// horizontally centered. This is mostly useful on devices with wide screens.
  final double? maxContentWidth;

  /// Allows to override [DefaultStyles].
  final DefaultStyles? customStyles;

  /// Whether this editor's height will be sized to fill its parent.
  ///
  /// This only has effect if [scrollable] is set to `true`.
  ///
  /// If expands is set to true and wrapped in a parent widget like [Expanded]
  /// or [SizedBox], the editor will expand to fill the parent.
  ///
  /// [maxHeight] and [minHeight] must both be `null` when this is set to
  /// `true`.
  ///
  /// Defaults to `false`.
  final bool expands;

  /// Configures how the platform keyboard will select an uppercase or
  /// lowercase keyboard.
  ///
  /// Only supports text keyboards, other keyboard types will ignore this
  /// configuration. Capitalization is locale-aware.
  ///
  /// Defaults to [TextCapitalization.sentences]. Must not be `null`.
  final TextCapitalization textCapitalization;

  /// The appearance of the keyboard.
  ///
  /// This setting is only honored on iOS devices.
  ///
  /// Defaults to [Brightness.light].
  final Brightness keyboardAppearance;

  /// The [ScrollPhysics] to use when vertically scrolling the input.
  ///
  /// This only has effect if [scrollable] is set to `true`.
  ///
  /// If not specified, it will behave according to the current platform.
  ///
  /// See [Scrollable.physics].
  final ScrollPhysics? scrollPhysics;

  /// Callback to invoke when user wants to launch a URL.
  final ValueChanged<String>? onLaunchUrl;

  // Returns whether gesture is handled
  final bool Function(
      TapDownDetails details, TextPosition Function(Offset offset))? onTapDown;

  // Returns whether gesture is handled
  final bool Function(
      TapUpDetails details, TextPosition Function(Offset offset))? onTapUp;

  // Returns whether gesture is handled
  final bool Function(
          LongPressStartDetails details, TextPosition Function(Offset offset))?
      onSingleLongTapStart;

  // Returns whether gesture is handled
  final bool Function(LongPressMoveUpdateDetails details,
      TextPosition Function(Offset offset))? onSingleLongTapMoveUpdate;

  // Returns whether gesture is handled
  final bool Function(
          LongPressEndDetails details, TextPosition Function(Offset offset))?
      onSingleLongTapEnd;

  final Iterable<EmbedBuilder>? embedBuilders;
  final EmbedBuilder? unknownEmbedBuilder;
  final CustomStyleBuilder? customStyleBuilder;
  final CustomRecognizerBuilder? customRecognizerBuilder;

  final QuillSearchConfigurations searchConfigurations;

  /// Delegate function responsible for showing menu with link actions on
  /// mobile platforms (iOS, Android).
  ///
  /// The menu is triggered in editing mode ([readOnly] is set to `false`)
  /// when the user long-presses a link-styled text segment.
  ///
  /// FlutterQuill provides default implementation which can be overridden by
  /// this field to customize the user experience.
  ///
  /// By default on iOS the menu is displayed with [showCupertinoModalPopup]
  /// which constructs an instance of [CupertinoActionSheet]. For Android,
  /// the menu is displayed with [showModalBottomSheet] and a list of
  /// Material [ListTile]s.
  final LinkActionPickerDelegate linkActionPickerDelegate;

  final bool floatingCursorDisabled;

  /// allows to create a custom textSelectionControls,
  /// if this is null a default textSelectionControls based on the app's theme
  /// will be used
  final TextSelectionControls? textSelectionControls;

  /// Callback when the user pastes the given image.
  ///
  /// Returns the url of the image if the image should be inserted.
  final Future<String?> Function(Uint8List imageBytes)? onImagePaste;

  /// Callback when the user pastes the given gif.
  ///
  /// Returns the url of the gif if the gif should be inserted.
  final Future<String?> Function(Uint8List imageBytes)? onGifPaste;

  /// Contains user-defined shortcuts map.
  ///
  /// [https://docs.flutter.dev/development/ui/advanced/actions-and-shortcuts#shortcuts]
  final Map<ShortcutActivator, Intent>? customShortcuts;

  /// Contains user-defined actions.
  ///
  /// [https://docs.flutter.dev/development/ui/advanced/actions-and-shortcuts#actions]
  final Map<Type, Action<Intent>>? customActions;

  final bool detectWordBoundary;

  /// Additional list if links prefixes, which must not be prepended
  /// with "https://" when [LinkMenuAction.launch] happened
  ///
  /// Useful for deep-links
  final List<String> customLinkPrefixes;

  /// Configures the dialog theme.
  final QuillDialogTheme? dialogTheme;

  // Allows for creating a custom context menu
  final QuillEditorContextMenuBuilder? contextMenuBuilder;

  /// Configuration of handler for media content inserted via the system input
  /// method.
  ///
  /// See [https://api.flutter.dev/flutter/widgets/EditableText/contentInsertionConfiguration.html]
  final ContentInsertionConfiguration? contentInsertionConfiguration;

  /// Using the editorKey for get getLocalRectForCaret
  /// editorKey.currentState?.renderEditor.getLocalRectForCaret
  final GlobalKey<EditorState>? editorKey;

  /// By default we will use
  /// ```
  /// TextSelectionTheme.of(context)
  /// ```
  /// to change it please pass a different value
  final TextSelectionThemeData? textSelectionThemeData;

  /// When there is a change the check list values
  /// should we request keyboard focus??
  final bool requestKeyboardFocusOnCheckListChanged;

  /// This is not complete yet and might changed
  final QuillEditorElementOptions elementOptions;

  final QuillEditorBuilder? builder;

  /// Currently this feature is experimental
  @experimental
  final TextMagnifierConfiguration? magnifierConfiguration;

  /// Default to [TextInputAction.newline]
  final TextInputAction textInputAction;

  /// Enable Scribble? Currently Apple Pencil only, defaults to false.
  final bool enableScribble;

  /// Called when Scribble is activated.
  final void Function()? onScribbleActivated;

  /// Optional insets for the scribble area.
  final EdgeInsets? scribbleAreaInsets;

  /// Called when a text input action is performed.
  final void Function(TextInputAction action)? onPerformAction;

  @override
  List<Object?> get props => [
        placeholder,
        // ignore: deprecated_member_use_from_same_package
        controller?.readOnly,
      ];

  // We might use code generator like freezed but sometimes it can be limited
  // instead whatever there is a change to the parameters in this class please
  // regenerate this function using extension in vs code or plugin in intellij

  QuillEditorConfigurations copyWith({
    QuillSharedConfigurations? sharedConfigurations,
    QuillController? controller,
    String? placeholder,
    bool? readOnly,
    bool? checkBoxReadOnly,
    bool? disableClipboard,
    bool? scrollable,
    bool? enableMarkdownStyleConversion,
    double? scrollBottomInset,
    EdgeInsetsGeometry? padding,
    bool? autoFocus,
    bool? isOnTapOutsideEnabled,
    Function(PointerDownEvent event, FocusNode focusNode)? onTapOutside,
    bool? showCursor,
    bool? paintCursorAboveText,
    bool? enableInteractiveSelection,
    bool? enableSelectionToolbar,
    double? minHeight,
    double? maxHeight,
    double? maxContentWidth,
    DefaultStyles? customStyles,
    bool? expands,
    TextCapitalization? textCapitalization,
    Brightness? keyboardAppearance,
    ScrollPhysics? scrollPhysics,
    ValueChanged<String>? onLaunchUrl,
    Iterable<EmbedBuilder>? embedBuilders,
    EmbedBuilder? unknownEmbedBuilder,
    QuillSearchConfigurations? searchConfigurations,
    CustomStyleBuilder? customStyleBuilder,
    CustomRecognizerBuilder? customRecognizerBuilder,
    LinkActionPickerDelegate? linkActionPickerDelegate,
    bool? floatingCursorDisabled,
    TextSelectionControls? textSelectionControls,
    Future<String?> Function(Uint8List imageBytes)? onImagePaste,
    Future<String?> Function(Uint8List imageBytes)? onGifPaste,
    Map<ShortcutActivator, Intent>? customShortcuts,
    Map<Type, Action<Intent>>? customActions,
    bool? detectWordBoundary,
    List<String>? customLinkPrefixes,
    QuillDialogTheme? dialogTheme,
    QuillEditorContextMenuBuilder? contextMenuBuilder,
    ContentInsertionConfiguration? contentInsertionConfiguration,
    GlobalKey<EditorState>? editorKey,
    TextSelectionThemeData? textSelectionThemeData,
    bool? requestKeyboardFocusOnCheckListChanged,
    QuillEditorElementOptions? elementOptions,
    QuillEditorBuilder? builder,
    TextMagnifierConfiguration? magnifierConfiguration,
    TextInputAction? textInputAction,
    bool? enableScribble,
    void Function()? onScribbleActivated,
    EdgeInsets? scribbleAreaInsets,
    void Function(TextInputAction action)? onPerformAction,
  }) {
    return QuillEditorConfigurations(
      sharedConfigurations: sharedConfigurations ?? this.sharedConfigurations,
      // ignore: deprecated_member_use_from_same_package
      controller: controller ?? this.controller,
      placeholder: placeholder ?? this.placeholder,
      checkBoxReadOnly: checkBoxReadOnly ?? this.checkBoxReadOnly,
      disableClipboard: disableClipboard ?? this.disableClipboard,
      scrollable: scrollable ?? this.scrollable,
      scrollBottomInset: scrollBottomInset ?? this.scrollBottomInset,
      padding: padding ?? this.padding,
      enableMarkdownStyleConversion:
          enableMarkdownStyleConversion ?? this.enableMarkdownStyleConversion,
      autoFocus: autoFocus ?? this.autoFocus,
      isOnTapOutsideEnabled:
          isOnTapOutsideEnabled ?? this.isOnTapOutsideEnabled,
      onTapOutside: onTapOutside ?? this.onTapOutside,
      showCursor: showCursor ?? this.showCursor,
      paintCursorAboveText: paintCursorAboveText ?? this.paintCursorAboveText,
      enableInteractiveSelection:
          enableInteractiveSelection ?? this.enableInteractiveSelection,
      enableSelectionToolbar:
          enableSelectionToolbar ?? this.enableSelectionToolbar,
      minHeight: minHeight ?? this.minHeight,
      maxHeight: maxHeight ?? this.maxHeight,
      maxContentWidth: maxContentWidth ?? this.maxContentWidth,
      customStyles: customStyles ?? this.customStyles,
      expands: expands ?? this.expands,
      textCapitalization: textCapitalization ?? this.textCapitalization,
      keyboardAppearance: keyboardAppearance ?? this.keyboardAppearance,
      scrollPhysics: scrollPhysics ?? this.scrollPhysics,
      onLaunchUrl: onLaunchUrl ?? this.onLaunchUrl,
      embedBuilders: embedBuilders ?? this.embedBuilders,
      unknownEmbedBuilder: unknownEmbedBuilder ?? this.unknownEmbedBuilder,
      searchConfigurations: searchConfigurations ?? this.searchConfigurations,
      customStyleBuilder: customStyleBuilder ?? this.customStyleBuilder,
      customRecognizerBuilder:
          customRecognizerBuilder ?? this.customRecognizerBuilder,
      linkActionPickerDelegate:
          linkActionPickerDelegate ?? this.linkActionPickerDelegate,
      floatingCursorDisabled:
          floatingCursorDisabled ?? this.floatingCursorDisabled,
      textSelectionControls:
          textSelectionControls ?? this.textSelectionControls,
      onImagePaste: onImagePaste ?? this.onImagePaste,
      onGifPaste: onGifPaste ?? this.onGifPaste,
      customShortcuts: customShortcuts ?? this.customShortcuts,
      customActions: customActions ?? this.customActions,
      detectWordBoundary: detectWordBoundary ?? this.detectWordBoundary,
      customLinkPrefixes: customLinkPrefixes ?? this.customLinkPrefixes,
      dialogTheme: dialogTheme ?? this.dialogTheme,
      contextMenuBuilder: contextMenuBuilder ?? this.contextMenuBuilder,
      contentInsertionConfiguration:
          contentInsertionConfiguration ?? this.contentInsertionConfiguration,
      editorKey: editorKey ?? this.editorKey,
      textSelectionThemeData:
          textSelectionThemeData ?? this.textSelectionThemeData,
      requestKeyboardFocusOnCheckListChanged:
          requestKeyboardFocusOnCheckListChanged ??
              this.requestKeyboardFocusOnCheckListChanged,
      elementOptions: elementOptions ?? this.elementOptions,
      builder: builder ?? this.builder,
      magnifierConfiguration:
          magnifierConfiguration ?? this.magnifierConfiguration,
      textInputAction: textInputAction ?? this.textInputAction,
      enableScribble: enableScribble ?? this.enableScribble,
      onScribbleActivated: onScribbleActivated ?? this.onScribbleActivated,
      scribbleAreaInsets: scribbleAreaInsets ?? this.scribbleAreaInsets,
      onPerformAction: onPerformAction ?? this.onPerformAction,
    );
  }
}
