import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import '../../../../controller/quill_controller.dart';
import '../../../../document/nodes/leaf.dart';

typedef SpaceShortcutEventHandler = bool Function(
    QuillText node, QuillController controller);

/// Defines the implementation of shortcut events for space key calls.
@immutable
class SpaceShortcutEvent extends Equatable {
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
  List<Object?> get props => [character, handler];
}
