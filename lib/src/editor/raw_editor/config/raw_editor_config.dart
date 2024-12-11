import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

import '../../../document/nodes/node.dart';
import '../../../editor/embed/embed_editor_builder.dart';
import '../../../editor/raw_editor/raw_editor.dart';
import '../../../editor/raw_editor/raw_editor_state.dart';
import '../../../editor/widgets/cursor.dart';
import '../../../editor/widgets/default_styles.dart';
import '../../../editor/widgets/delegate.dart';
import '../../../editor/widgets/link.dart';
import '../../../toolbar/theme/quill_dialog_theme.dart';
import '../builders/leading_block_builder.dart';
import 'events/events.dart';

@immutable
class QuillRawEditorConfig {
  const QuillRawEditorConfig({
    required this.focusNode,
    required this.scrollController,
    required this.scrollBottomInset,
    required this.cursorStyle,
    required this.selectionColor,
    required this.selectionCtrls,
    required this.embedBuilder,
    required this.autoFocus,
    required this.characterShortcutEvents,
    required this.spaceShortcutEvents,
    @experimental this.onKeyPressed,
    this.showCursor = true,
    this.scrollable = true,
    this.padding = EdgeInsets.zero,
    this.readOnly = false,
    this.checkBoxReadOnly,
    this.disableClipboard = false,
    this.placeholder,
    this.onLaunchUrl,
    this.contextMenuBuilder = defaultContextMenuBuilder,
    this.showSelectionHandles = false,
    this.textCapitalization = TextCapitalization.none,
    this.maxHeight,
    this.minHeight,
    this.maxContentWidth,
    this.customStyles,
    this.customShortcuts,
    this.customActions,
    this.expands = false,
    this.onTapOutsideEnabled = true,
    this.enableAlwaysIndentOnTab = false,
    this.onTapOutside,
    this.keyboardAppearance,
    this.enableInteractiveSelection = true,
    this.scrollPhysics,
    this.linkActionPickerDelegate = defaultLinkActionPickerDelegate,
    this.customStyleBuilder,
    this.customRecognizerBuilder,
    this.floatingCursorDisabled = false,
    this.customLinkPrefixes = const <String>[],
    this.dialogTheme,
    this.contentInsertionConfiguration,
    this.textInputAction = TextInputAction.newline,
    this.requestKeyboardFocusOnCheckListChanged = false,
    this.enableScribble = false,
    this.onScribbleActivated,
    this.scribbleAreaInsets,
    this.readOnlyMouseCursor = SystemMouseCursors.text,
    this.onPerformAction,
    @experimental this.customLeadingBuilder,
  });

  /// Controls whether this editor has keyboard focus.
  final FocusNode focusNode;
  final ScrollController scrollController;
  final bool scrollable;
  final double scrollBottomInset;
  @experimental
  final LeadingBlockNodeBuilder? customLeadingBuilder;

  /// Contains all the events that will be handled when
  /// the exact characters satifies the condition. This mean
  /// if you press asterisk key, if you have a `CharacterShortcutEvent` with
  /// the asterisk then that event will be handled
  ///
  /// Supported by:
  ///
  ///    - Web
  ///    - Desktop
  ///
  /// ### Example
  ///```dart
  /// // you can get also the default implemented shortcuts
  /// // calling [standardSpaceShorcutEvents]
  ///final defaultShorcutsImplementation =
  ///               List.from([...standardCharactersShortcutEvents])
  ///
  ///final boldFormat = CharacterShortcutEvent(
  ///   key: 'Shortcut event that will format current wrapped text in asterisk'
  ///   character: '*',
  ///   handler: (controller) {...your implementation}
  ///);
  ///```
  final List<CharacterShortcutEvent> characterShortcutEvents;

  /// Contains all the events that will be handled when
  /// space key is pressed
  ///
  /// Supported by:
  ///
  ///    - Web
  ///    - Desktop
  ///
  /// ### Example
  ///```dart
  /// // you can get also the default implemented shortcuts
  /// // calling [standardSpaceShorcutEvents]
  ///final defaultShorcutsImplementation =
  ///       List.from([...standardSpaceShorcutEvents])
  ///
  ///final spaceBulletList = SpaceShortcutEvent(
  ///   character: '-',
  ///   handler: (QuillText textNode, controller) {...your implementation}
  ///);
  ///```
  final List<SpaceShortcutEvent> spaceShortcutEvents;

  /// A handler for keys that are pressed when the editor is focused.
  ///
  /// This feature is supported on **desktop devices only**.
  ///
  /// # Example:
  /// To prevent the user from removing any **Embed Object**, try:
  ///
  ///```dart
  ///onKeyPressed: (event, node) {
  ///   if (event.logicalKey == LogicalKeyboardKey.backspace &&
  ///       (node is Line || node is Block)) {
  ///     // Use [DeltaIterator] to jump directly to the position before the current.
  ///     final iterator = DeltaIterator(_controller.document.toDelta())
  ///           ..skip(_controller.selection.baseOffset - 1);
  ///     // Get the [Operation] where the caret is on
  ///     final cur = iterator.next();
  ///     final isOperationWithEmbed = cur.data is! String && cur.data != null;
  ///     if (isOperationWithEmbed) {
  ///         // Ignore this [KeyEvent] to prevent the user from removing the [Embed Object].
  ///         return KeyEventResult.handled;
  ///     }
  ///   }
  ///   // Apply custom logic or return null to use default events
  ///   return null;
  ///},
  ///```
  @experimental
  final KeyEventResult? Function(KeyEvent event, Node? node)? onKeyPressed;

  /// Additional space around the editor contents.
  final EdgeInsetsGeometry padding;

  /// Enables always indenting when the TAB key is pressed.
  ///
  /// When set to true, pressing the TAB key will always insert an indentation
  /// regardless of the context. If set to false, the TAB key will only indent
  /// when the cursor is at the beginning of a list item. In other cases, it will
  /// insert a tab character.
  ///
  /// Defaults to false. Must not be null.
  final bool enableAlwaysIndentOnTab;

  /// Whether the text can be changed.
  ///
  /// When this is set to true, the text cannot be modified
  /// by any shortcut or keyboard operation. The text is still selectable.
  ///
  /// Defaults to false. Must not be null.
  final bool readOnly;

  /// Override readOnly for checkbox.
  ///
  /// When this is set to false, the checkbox can be checked
  /// or unchecked while readOnly is set to true.
  /// When this is set to null, the readOnly value is used.
  ///
  /// Defaults to null.
  final bool? checkBoxReadOnly;

  // TODO: (11.0.0) Should move this property to QuillClipboardConfig? Also exist in QuillEditorConfig
  /// Disable Clipboard features
  ///
  /// when this is set to true clipboard can not be used
  /// this disables the clipboard notification for requesting permissions
  ///
  /// Defaults to `false`.
  final bool disableClipboard;

  final String? placeholder;

  /// Callback which is triggered when the user wants to open a URL from
  /// a link in the document.
  final ValueChanged<String>? onLaunchUrl;

  /// Builds the text selection toolbar when requested by the user.
  ///
  /// See also:
  ///   * [EditableText.contextMenuBuilder], which builds the default
  ///     text selection toolbar for [EditableText].
  ///
  /// If not provided, no context menu will be shown.
  final QuillEditorContextMenuBuilder? contextMenuBuilder;

  static Widget defaultContextMenuBuilder(
    BuildContext context,
    QuillRawEditorState state,
  ) {
    return TextFieldTapRegion(
      child: AdaptiveTextSelectionToolbar.buttonItems(
        buttonItems: state.contextMenuButtonItems,
        anchors: state.contextMenuAnchors,
      ),
    );
  }

  /// Whether to show selection handles.
  ///
  /// When a selection is active, there will be two handles at each side of
  /// boundary, or one handle if the selection is collapsed. The handles can be
  /// dragged to adjust the selection.
  ///
  /// See also:
  ///
  ///  * [showCursor], which controls the visibility of the cursor.
  final bool showSelectionHandles;

  /// Whether to show cursor.
  ///
  /// The cursor refers to the blinking caret when the editor is focused.
  ///
  /// See also:
  ///
  ///  * [cursorStyle], which controls the cursor visual representation.
  ///  * [showSelectionHandles], which controls the visibility of the selection
  ///    handles.
  final bool showCursor;

  /// The style to be used for the editing cursor.
  final CursorStyle cursorStyle;

  /// The [readOnlyMouseCursor] is used for Windows, macOS when [readOnly] is [true]
  final MouseCursor readOnlyMouseCursor;

  /// Configures how the platform keyboard will select an uppercase or
  /// lowercase keyboard.
  ///
  /// Only supports text keyboards, other keyboard types will ignore this
  /// configuration. Capitalization is locale-aware.
  ///
  /// Defaults to [TextCapitalization.none]. Must not be null.
  ///
  /// See also:
  ///
  ///  * [TextCapitalization], for a description of each capitalization behavior
  final TextCapitalization textCapitalization;

  /// The maximum height this editor can have.
  ///
  /// If this is null then there is no limit to the editor's height and it will
  /// expand to fill its parent.
  final double? maxHeight;

  /// The minimum height this editor can have.
  final double? minHeight;

  /// The maximum width to be occupied by the content of this editor.
  ///
  /// If this is not null and and this editor's width is larger than this value
  /// then the contents will be constrained to the provided maximum width and
  /// horizontally centered. This is mostly useful on devices with wide screens.
  final double? maxContentWidth;

  /// Allows to override [DefaultStyles].
  final DefaultStyles? customStyles;

  /// Whether this widget's height will be sized to fill its parent.
  ///
  /// If set to true and wrapped in a parent widget like [Expanded] or
  ///
  /// Defaults to false.
  final bool expands;

  /// Whether this editor should focus itself if nothing else is already
  /// focused.
  ///
  /// If true, the keyboard will open as soon as this text field obtains focus.
  /// Otherwise, the keyboard is only shown after the user taps the text field.
  ///
  /// Defaults to false. Cannot be null.
  final bool autoFocus;

  /// The color to use when painting the selection.
  final Color selectionColor;

  /// Delegate for building the text selection handles and toolbar.
  ///
  /// The [QuillRawEditor] widget used on its own will not trigger the display
  /// of the selection toolbar by itself. The toolbar is shown by calling
  /// [QuillRawEditorState.showToolbar] in response to
  /// an appropriate user event.
  final TextSelectionControls selectionCtrls;

  /// The appearance of the keyboard.
  ///
  /// This setting is only honored on iOS devices.
  ///
  /// Defaults to Material/Cupertino App Brightness.
  ///
  /// The keyboardd appearance will set using the following:
  ///
  /// ```dart
  /// widget.configurations.keyboardAppearance ??
  /// CupertinoTheme.maybeBrightnessOf(context) ??
  /// Theme.of(context).brightness
  /// ```
  ///
  /// See also: https://github.com/flutter/flutter/blob/06b9f7ba0bef2b5b44a643c73f4295a096de1202/packages/flutter/lib/src/services/text_input.dart#L621-L626
  final Brightness? keyboardAppearance;

  /// If true, then long-pressing this TextField will select text and show the
  /// cut/copy/paste menu, and tapping will move the text caret.
  ///
  /// True by default.
  ///
  /// If false, most of the accessibility support for selecting text, copy
  /// and paste, and moving the caret will be disabled.
  final bool enableInteractiveSelection;

  bool get selectionEnabled => enableInteractiveSelection;

  /// The [ScrollPhysics] to use when vertically scrolling the input.
  ///
  /// If not specified, it will behave according to the current platform.
  ///
  /// See [Scrollable.physics].
  final ScrollPhysics? scrollPhysics;

  /// Contains user-defined shortcuts map.
  ///
  /// [https://docs.flutter.dev/development/ui/advanced/actions-and-shortcuts#shortcuts]
  final Map<ShortcutActivator, Intent>? customShortcuts;

  /// Contains user-defined actions.
  ///
  /// [https://docs.flutter.dev/development/ui/advanced/actions-and-shortcuts#actions]
  final Map<Type, Action<Intent>>? customActions;

  /// Builder function for embeddable objects.
  final EmbedsBuilder embedBuilder;
  final LinkActionPickerDelegate linkActionPickerDelegate;
  final CustomStyleBuilder? customStyleBuilder;
  final CustomRecognizerBuilder? customRecognizerBuilder;
  final bool floatingCursorDisabled;
  final List<String> customLinkPrefixes;

  /// Configures the dialog theme.
  final QuillDialogTheme? dialogTheme;

  /// Configuration of handler for media content inserted via the system input
  /// method.
  ///
  /// See [https://api.flutter.dev/flutter/widgets/EditableText/contentInsertionConfiguration.html]
  final ContentInsertionConfiguration? contentInsertionConfiguration;

  /// Whether the [onTapOutside] should be triggered or not.
  ///
  /// Defaults to `true`.
  ///
  /// See also: [onTapOutside].
  final bool onTapOutsideEnabled;

  /// By default on non-mobile platforms, the editor will unfocus.
  ///
  /// On mobile platforms, it will only unfocus if the input kind in [PointerDownEvent.kind]
  /// is [ui.PointerDeviceKind.unknown].
  ///
  /// By passing a non-null value, you will override the default behavior.
  ///
  /// See also: [onTapOutsideEnabled].
  final Function(PointerDownEvent event, FocusNode focusNode)? onTapOutside;

  /// When there is a change the check list values
  /// should we request keyboard focus??
  final bool requestKeyboardFocusOnCheckListChanged;

  final TextInputAction textInputAction;

  /// Enable Scribble? Currently Apple Pencil only, defaults to false.
  final bool enableScribble;

  /// Called when Scribble is activated.
  final void Function()? onScribbleActivated;

  /// Optional insets for the scribble area.
  final EdgeInsets? scribbleAreaInsets;

  /// Called when a text input action is performed.
  final void Function(TextInputAction action)? onPerformAction;
}
