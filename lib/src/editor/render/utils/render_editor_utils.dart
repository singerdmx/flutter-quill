import 'package:flutter/widgets.dart';

/// Signature for the callback that reports when the user changes the selection
/// (including the cursor location).
///
/// Used by [RenderEditor.onSelectionChanged].
typedef TextSelectionChangedHandler = void Function(
    TextSelection selection, SelectionChangedCause cause);

/// Signature for the callback that reports when a selection action is actually
/// completed and ratified. Completion is defined as when the user input has
/// concluded for an entire selection action. For simple taps and keyboard input
/// events that change the selection, this callback is invoked immediately
/// following the TextSelectionChangedHandler. For long taps, the selection is
/// considered complete at the up event of a long tap. For drag selections, the
/// selection completes once the drag/pan event ends or is interrupted.
///
/// Used by [RenderEditor.onSelectionCompleted].
typedef TextSelectionCompletedHandler = void Function();

// The padding applied to text field. Used to determine the bounds when
// moving the floating cursor.
const EdgeInsets kFloatingCursorAddedMargin = EdgeInsets.fromLTRB(4, 4, 4, 5);

// The additional size on the x and y axis with which to expand the prototype
// cursor to render the floating cursor in pixels.
const EdgeInsets kFloatingCaretSizeIncrease =
    EdgeInsets.symmetric(horizontal: 0.5, vertical: 1);
