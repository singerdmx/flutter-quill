import 'package:flutter/material.dart';

import '../../common/utils/widgets.dart';
import '../../l10n/extensions/localizations_ext.dart';
import '../base_button/base_button_options_resolver.dart';
import '../base_button/base_value_button.dart';
import '../config/buttons/hashtag_button_options.dart';
import '../simple_toolbar.dart';
import '../theme/quill_icon_theme.dart';
import 'quill_icon_button.dart';

/// A toolbar button that inserts the '#' symbol to trigger hashtag tags.
///
/// When clicked, this button inserts '#' at the current cursor position,
/// which automatically triggers the tag overlay to appear, allowing users
/// to search and select from a list of available hashtags.
///
/// The tag overlay is handled by [MentionTagWrapper] and will display
/// suggestions based on the [MentionTagConfig.tagSearch] callback.
/// Selected tags are stored with [TagAttribute] and can be styled with colors.
///
/// Example usage:
/// ```dart
/// QuillToolbarHashtagButton(
///   controller: _controller,
///   options: QuillToolbarHashtagButtonOptions(
///     tooltip: 'Add hashtag',
///     iconData: Icons.tag,
///   ),
/// )
/// ```
class QuillToolbarHashtagButton extends QuillToolbarBaseButton<
    QuillToolbarHashtagButtonOptions,
    QuillToolbarHashtagButtonExtraOptions> {
  /// Creates a hashtag button for the toolbar.
  ///
  /// [controller] is required and must be a valid [QuillController] instance.
  /// [options] allows customization of the button's appearance and behavior.
  /// [baseOptions] can be used to share common options across multiple buttons.
  const QuillToolbarHashtagButton({
    required super.controller,
    super.options = const QuillToolbarHashtagButtonOptions(),
    super.baseOptions,
    super.key,
  });

  @override
  QuillToolbarHashtagButtonState createState() => QuillToolbarHashtagButtonState();
}

/// State class for [QuillToolbarHashtagButton].
///
/// Handles the button's behavior, including inserting the '#' symbol
/// and triggering the tag overlay when pressed.
class QuillToolbarHashtagButtonState
    extends QuillToolbarBaseButtonState<
        QuillToolbarHashtagButton,
        QuillToolbarHashtagButtonOptions,
        QuillToolbarHashtagButtonExtraOptions,
        bool> {
  /// This button is not a toggle button, so it always returns false.
  @override
  bool get currentStateValue => false;

  /// Default tooltip text displayed when hovering over the button.
  @override
  String get defaultTooltip => 'Tag';

  /// Default icon displayed on the button (tag icon for # symbol).
  @override
  IconData get defaultIconData => Icons.tag;

  /// Handles the button press event.
  ///
  /// Inserts the '#' symbol at the current cursor position. If text is selected,
  /// it replaces the selection with '#'. After insertion, the tag overlay
  /// will automatically appear, allowing the user to search for and select a tag.
  void _handleTagButtonPressed() {
    final currentSelection = controller.selection;
    
    // Determine the insertion position:
    // - If cursor is collapsed (no selection), use the cursor position
    // - If text is selected, use the start of the selection (will replace selection)
    final insertionPosition = currentSelection.isCollapsed
        ? currentSelection.baseOffset
        : currentSelection.start;

    // Calculate the length of text to replace (0 if no selection, otherwise selection length)
    final textToReplaceLength = currentSelection.isCollapsed
        ? 0
        : currentSelection.end - currentSelection.start;

    // Insert '#' symbol at the cursor/selection position
    // This will automatically trigger the tag overlay via MentionTagWrapper
    controller.replaceText(
      insertionPosition,
      textToReplaceLength,
      '#', // Hashtag trigger character
      TextSelection.collapsed(offset: insertionPosition + 1), // Move cursor after '#'
    );

    // Call any additional callbacks registered via afterButtonPressed
    afterButtonPressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    // Check if a custom child builder is provided
    final customChildBuilder = this.childBuilder;
    if (customChildBuilder != null) {
      // Use custom builder if provided (allows full customization of button appearance)
      return customChildBuilder(
        options,
        QuillToolbarHashtagButtonExtraOptions(
          context: context,
          controller: controller,
          onPressed: _handleTagButtonPressed,
        ),
      );
    }

    // Default button implementation with tooltip and icon
    return UtilityWidgets.maybeTooltip(
      message: tooltip,
      child: QuillToolbarIconButton(
        icon: Icon(
          iconData,
          size: iconSize * iconButtonFactor,
        ),
        isSelected: false, // Tag button is not a toggle, always unselected
        onPressed: _handleTagButtonPressed,
        afterPressed: afterButtonPressed,
        iconTheme: iconTheme,
      ),
    );
  }
}
