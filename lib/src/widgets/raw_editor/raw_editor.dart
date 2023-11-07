import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Uint8List;

import '../../models/themes/quill_dialog_theme.dart';
import '../controller.dart';
import '../cursor.dart';
import '../default_styles.dart';
import '../delegate.dart';
import '../link.dart';
import 'raw_editor_state.dart';

class QuillRawEditor extends StatefulWidget {
  const QuillRawEditor({
    required this.controller,
    required this.focusNode,
    required this.scrollController,
    required this.scrollBottomInset,
    required this.cursorStyle,
    required this.selectionColor,
    required this.selectionCtrls,
    required this.embedBuilder,
    required this.autoFocus,
    super.key,
    this.scrollable = true,
    this.padding = EdgeInsets.zero,
    this.readOnly = false,
    this.placeholder,
    this.onLaunchUrl,
    this.contextMenuBuilder = defaultContextMenuBuilder,
    this.showSelectionHandles = false,
    bool? showCursor,
    this.textCapitalization = TextCapitalization.none,
    this.maxHeight,
    this.minHeight,
    this.maxContentWidth,
    this.customStyles,
    this.customShortcuts,
    this.customActions,
    this.expands = false,
    this.enableUnfocusOnTapOutside = true,
    this.keyboardAppearance = Brightness.light,
    this.enableInteractiveSelection = true,
    this.scrollPhysics,
    this.linkActionPickerDelegate = defaultLinkActionPickerDelegate,
    this.customStyleBuilder,
    this.customRecognizerBuilder,
    this.floatingCursorDisabled = false,
    this.onImagePaste,
    this.customLinkPrefixes = const <String>[],
    this.dialogTheme,
    this.contentInsertionConfiguration,
  })  : assert(maxHeight == null || maxHeight > 0, 'maxHeight cannot be null'),
        assert(minHeight == null || minHeight >= 0, 'minHeight cannot be null'),
        assert(maxHeight == null || minHeight == null || maxHeight >= minHeight,
            'maxHeight cannot be null'),
        showCursor = showCursor ?? true;

  /// Controls the document being edited.
  final QuillController controller;

  /// Controls whether this editor has keyboard focus.
  final FocusNode focusNode;
  final ScrollController scrollController;
  final bool scrollable;
  final double scrollBottomInset;
  final bool enableUnfocusOnTapOutside;

  /// Additional space around the editor contents.
  final EdgeInsetsGeometry padding;

  /// Whether the text can be changed.
  ///
  /// When this is set to true, the text cannot be modified
  /// by any shortcut or keyboard operation. The text is still selectable.
  ///
  /// Defaults to false. Must not be null.
  final bool readOnly;

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
  /// Defaults to [Brightness.light].
  final Brightness keyboardAppearance;

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

  final Future<String?> Function(Uint8List imageBytes)? onImagePaste;

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

  @override
  State<StatefulWidget> createState() => QuillRawEditorState();
}

/// Signature for a widget builder that builds a context menu for the given
/// [QuillRawEditorState].
///
/// See also:
///
///  * [EditableTextContextMenuBuilder], which performs the same role for
///    [EditableText]
typedef QuillEditorContextMenuBuilder = Widget Function(
  BuildContext context,
  QuillRawEditorState rawEditorState,
);

class QuillEditorGlyphHeights {
  QuillEditorGlyphHeights(
    this.startGlyphHeight,
    this.endGlyphHeight,
  );

  final double startGlyphHeight;
  final double endGlyphHeight;
}
