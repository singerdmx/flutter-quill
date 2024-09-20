part of 'soft_keyboard_shortcut_support.dart';

extension _QuillControllerExt on QuillController {
  void removeLastChar({bool? endFormatting}) {
    final selection = this.selection;
    final baseOffset = selection.baseOffset;
    this
      ..moveCursorToPosition(baseOffset - 1)
      ..replaceText(baseOffset - 1, 1, '', null);

    if (endFormatting != null) {
      final style = getSelectionStyle();
      style.attributes.forEach((key, attr) {
        formatText(
          selection.start,
          selection.end - selection.start,
          Attribute.clone(attr, null),
        );
      });
    }
  }
}

/// this method is based of QuillKeyboardServiceWidget._handleSpaceKey
/// and modified to handle soft keyboard (so the space character is
/// briefly added to the text)
bool _handleSpaceKey(
  QuillController controller,
  List<SpaceShortcutEvent> spaceEvents,
) {
  final baseOffset = controller.selection.baseOffset;
  final child = controller.document.queryChild(controller.selection.baseOffset);
  if (child.node == null) {
    return false;
  }

  final line = child.node as Line?;
  if (line == null) {
    return false;
  }

  final text = castOrNull<leaf.QuillText>(line.first);
  if (text == null) {
    return false;
  }

  var effectiveTextValue = text.value;

  final documentOffset = text.documentOffset;
  if (baseOffset > documentOffset + 1 &&
      ((baseOffset - documentOffset - 1) <= text.value.length)) {
    // we need to factor in the space char that is already part of the text, thus -1
    effectiveTextValue =
        text.value.substring(0, baseOffset - documentOffset - 1);
  } else {
    // baseOffset is outside of the first node of the line, space shortcuts
    // can only exist there, therefore we won't handle here
    return false;
  }

  if (spaceEvents.isNotEmpty) {
    for (final spaceEvent in spaceEvents) {
      if (spaceEvent.character == effectiveTextValue) {
        final executed = spaceEvent.execute(text, controller);
        if (executed) return true;
      }
    }
    return false;
  } else if (spaceEvents.isEmpty) {
    return false;
  }

  return false;
}
