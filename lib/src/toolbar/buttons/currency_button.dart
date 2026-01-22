import 'package:flutter/material.dart';

import '../../common/utils/widgets.dart';
import '../../l10n/extensions/localizations_ext.dart';
import '../base_button/base_button_options_resolver.dart';
import '../base_button/base_value_button.dart';
import '../config/buttons/dollar_tag_button_options.dart';
import '../simple_toolbar.dart';
import '../theme/quill_icon_theme.dart';
import 'quill_icon_button.dart';

/// A toolbar button that inserts the '$' symbol to trigger currency/dollar tags.
///
/// When clicked, this button inserts '$' at the current cursor position,
/// which automatically triggers the currency tag overlay to appear, allowing
/// users to search and select from a list of available currency values.
///
/// The currency overlay is handled by [MentionTagWrapper] and will display
/// suggestions based on the [MentionTagConfig.dollarSearch] callback.
/// Selected currency tags are stored with [CurrencyAttribute] and are
/// automatically formatted with commas for thousands (e.g., "$1,000").
///
/// Example usage:
/// ```dart
/// QuillToolbarDollarTagButton(
///   controller: _controller,
///   options: QuillToolbarDollarTagButtonOptions(
///     tooltip: 'Add currency',
///     iconData: Icons.attach_money,
///   ),
/// )
/// ```
class QuillToolbarDollarTagButton extends QuillToolbarBaseButton<
    QuillToolbarDollarTagButtonOptions,
    QuillToolbarDollarTagButtonExtraOptions> {
  /// Creates a dollar tag button for the toolbar.
  ///
  /// [controller] is required and must be a valid [QuillController] instance.
  /// [options] allows customization of the button's appearance and behavior.
  /// [baseOptions] can be used to share common options across multiple buttons.
  const QuillToolbarDollarTagButton({
    required super.controller,
    super.options = const QuillToolbarDollarTagButtonOptions(),
    super.baseOptions,
    super.key,
  });

  @override
  QuillToolbarDollarTagButtonState createState() =>
      QuillToolbarDollarTagButtonState();
}

/// State class for [QuillToolbarDollarTagButton].
///
/// Handles the button's behavior, including inserting the '$' symbol
/// and triggering the currency tag overlay when pressed.
class QuillToolbarDollarTagButtonState
    extends QuillToolbarBaseButtonState<
        QuillToolbarDollarTagButton,
        QuillToolbarDollarTagButtonOptions,
        QuillToolbarDollarTagButtonExtraOptions,
        bool> {
  /// This button is not a toggle button, so it always returns false.
  @override
  bool get currentStateValue => false;

  /// Default tooltip text displayed when hovering over the button.
  @override
  String get defaultTooltip => 'Currency';

  /// Default icon displayed on the button (attach_money icon for $ symbol).
  @override
  IconData get defaultIconData => Icons.attach_money;

  /// Handles the button press event.
  ///
  /// Inserts the '$' symbol at the current cursor position. If text is selected,
  /// it replaces the selection with '$'. After insertion, the currency overlay
  /// will automatically appear, allowing the user to search for and select a
  /// currency value. Numeric values will be automatically formatted with
  /// commas (e.g., "1000" becomes "$1,000").
  void _handleCurrencyButtonPressed() {
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

    // Insert '$' symbol at the cursor/selection position
    // This will automatically trigger the currency overlay via MentionTagWrapper
    controller.replaceText(
      insertionPosition,
      textToReplaceLength,
      '\$', // Currency trigger character (escaped for Dart string)
      TextSelection.collapsed(offset: insertionPosition + 1), // Move cursor after '$'
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
        QuillToolbarDollarTagButtonExtraOptions(
          context: context,
          controller: controller,
          onPressed: _handleCurrencyButtonPressed,
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
        isSelected: false, // Currency button is not a toggle, always unselected
        onPressed: _handleCurrencyButtonPressed,
        afterPressed: afterButtonPressed,
        iconTheme: iconTheme,
      ),
    );
  }
}
