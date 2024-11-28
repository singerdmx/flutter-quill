import 'package:meta/meta.dart';
import '../../../../controller/quill_controller.dart';
import '../../../../document/nodes/leaf.dart';

typedef SpaceShortcutEventHandler = bool Function(
    QuillText node, QuillController controller);

/// Defines the implementation of shortcut events for space key calls.
@immutable
@experimental
class SpaceShortcutEvent {
  SpaceShortcutEvent({
    required this.character,
    required this.handler,
  }) : assert(character != '\n' && character.trim().isNotEmpty,
            'character that cannot be empty, a whitespace or a new line. Ensure that you are passing a not empty character');

  final String character;
  final SpaceShortcutEventHandler handler;

  bool execute(QuillText node, QuillController controller) {
    return handler(node, controller);
  }

  SpaceShortcutEvent copyWith({
    String? character,
    SpaceShortcutEventHandler? handler,
  }) {
    return SpaceShortcutEvent(
      character: character ?? this.character,
      handler: handler ?? this.handler,
    );
  }

  @override
  String toString() =>
      'SpaceShortcutEvent(character: $character, handler: $handler)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SpaceShortcutEvent &&
        other.character == character &&
        other.handler == handler;
  }

  @override
  int get hashCode => character.hashCode ^ handler.hashCode;
}
