import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../../../../../flutter_quill.dart';

typedef CharacterShortcutEventHandler = bool Function(
    QuillController controller);

/// Defines the implementation of shortcut event based on character.
@immutable
class CharacterShortcutEvent extends Equatable {
  const CharacterShortcutEvent({
    required this.key,
    required this.character,
    required this.handler,
  }) : assert(character.length == 1 && character != '\n',
            'character cannot be major than one char, and it must not be a new line');

  final String key;
  final String character;
  final CharacterShortcutEventHandler handler;

  bool execute(QuillController controller) {
    return handler(controller);
  }

  CharacterShortcutEvent copyWith({
    String? key,
    String? character,
    CharacterShortcutEventHandler? handler,
  }) {
    return CharacterShortcutEvent(
      key: key ?? this.key,
      character: character ?? this.character,
      handler: handler ?? this.handler,
    );
  }

  @override
  String toString() =>
      'CharacterShortcutEvent(key: $key, character: $character, handler: $handler)';

  @override
  List<Object?> get props => [key, character, handler];
}
