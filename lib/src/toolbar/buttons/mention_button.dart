import 'package:flutter/material.dart';

import '../../common/utils/widgets.dart';
import '../../l10n/extensions/localizations_ext.dart';
import '../base_button/base_button_options_resolver.dart';
import '../base_button/base_value_button.dart';
import '../config/buttons/user_mention_button_options.dart';
import '../simple_toolbar.dart';
import '../theme/quill_icon_theme.dart';
import 'quill_icon_button.dart';

/// A toolbar button that inserts the '@' symbol to trigger user mentions.
///
/// When clicked, this button inserts '@' at the current cursor position,
/// which automatically triggers the mention overlay to appear, allowing users
/// to search and select from a list of available users.
///
/// The mention overlay is handled by [MentionTagWrapper] and will display
/// suggestions based on the [MentionTagConfig.mentionSearch] callback.
///
/// Example usage:
/// ```dart
/// QuillToolbarUserMentionButton(
///   controller: _controller,
///   options: QuillToolbarUserMentionButtonOptions(
///     tooltip: 'Mention user',
///     iconData: Icons.alternate_email,
///   ),
/// )
/// ```
class QuillToolbarUserMentionButton extends QuillToolbarBaseButton<
    QuillToolbarUserMentionButtonOptions,
    QuillToolbarUserMentionButtonExtraOptions> {
  /// Creates a user mention button for the toolbar.
  ///
  /// [controller] is required and must be a valid [QuillController] instance.
  /// [options] allows customization of the button's appearance and behavior.
  /// [baseOptions] can be used to share common options across multiple buttons.
  const QuillToolbarUserMentionButton({
    required super.controller,
    super.options = const QuillToolbarUserMentionButtonOptions(),
    super.baseOptions,
    super.key,
  });

  @override
  QuillToolbarUserMentionButtonState createState() =>
      QuillToolbarUserMentionButtonState();
}

/// State class for [QuillToolbarUserMentionButton].
///
/// Handles the button's behavior, including inserting the '@' symbol
/// and triggering the mention overlay when pressed.
class QuillToolbarUserMentionButtonState
    extends QuillToolbarBaseButtonState<
        QuillToolbarUserMentionButton,
        QuillToolbarUserMentionButtonOptions,
        QuillToolbarUserMentionButtonExtraOptions,
        bool> {
  /// This button is not a toggle button, so it always returns false.
  @override
  bool get currentStateValue => false;

  /// Default tooltip text displayed when hovering over the button.
  @override
  String get defaultTooltip => 'Mention';

  /// Default icon displayed on the button (alternate_email icon for @ symbol).
  @override
  IconData get defaultIconData => Icons.alternate_email;

  /// Handles the button press event.
  ///
  /// Inserts the '@' symbol at the current cursor position. If text is selected,
  /// it replaces the selection with '@'. After insertion, the mention overlay
  /// will automatically appear, allowing the user to search for and select a user.
  void _handleMentionButtonPressed() {
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

    // Insert '@' symbol at the cursor/selection position
    // This will automatically trigger the mention overlay via MentionTagWrapper
    controller.replaceText(
      insertionPosition,
      textToReplaceLength,
      '@', // Mention trigger character
      TextSelection.collapsed(offset: insertionPosition + 1), // Move cursor after '@'
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
        QuillToolbarUserMentionButtonExtraOptions(
          context: context,
          controller: controller,
          onPressed: _handleMentionButtonPressed,
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
        isSelected: false, // Mention button is not a toggle, always unselected
        onPressed: _handleMentionButtonPressed,
        afterPressed: afterButtonPressed,
        iconTheme: iconTheme,
      ),
    );
  }
}
