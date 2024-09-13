import '../../../../../flutter_quill.dart';

typedef CharacterShortcutEventHandler = bool Function(QuillController controller);

/// Defines the implementation of shortcut event based on character.
class CharacterShortcutEvent {
  CharacterShortcutEvent({
    required this.character,
    required this.handler,
  }) : assert(character.length == 1);

  String character;
  final CharacterShortcutEventHandler handler;

  void updateCharacter(String newCharacter) {
    assert(newCharacter.length == 1);
    character = newCharacter;
  }

  bool execute(QuillController controller) {
    return handler(controller);
  }

  CharacterShortcutEvent copyWith({
    String? character,
    CharacterShortcutEventHandler? handler,
  }) {
    return CharacterShortcutEvent(
      character: character ?? this.character,
      handler: handler ?? this.handler,
    );
  }

  @override
  String toString() => 'CharacterShortcutEvent(character: $character, handler: $handler)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CharacterShortcutEvent && other.character == character && other.handler == handler;
  }

  @override
  int get hashCode => character.hashCode ^ handler.hashCode;
}
