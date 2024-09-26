import '../character_shortcuts_events.dart';
import '../format/format_single_character_handler.dart';

const _asterisk = '*';
const _strikeChar = '~';
const _codeChar = '`';

final CharacterShortcutEvent formatAsterisksToItalic = CharacterShortcutEvent(
  key: 'Format single asterisks to italic',
  character: _asterisk,
  handler: (controller) => handleFormatByWrappingWithSingleCharacter(
    controller: controller,
    character: _asterisk,
    formatStyle: SingleCharacterFormatStyle.italic,
  ),
);

final CharacterShortcutEvent formatStrikeToStrikethrough =
    CharacterShortcutEvent(
  key: 'Format single strikes to strike style',
  character: _strikeChar,
  handler: (controller) => handleFormatByWrappingWithSingleCharacter(
    controller: controller,
    character: _strikeChar,
    formatStyle: SingleCharacterFormatStyle.strikethrough,
  ),
);

final CharacterShortcutEvent formatCodeCharToInlineCode =
    CharacterShortcutEvent(
  key: 'Format single code to inline code style',
  character: _codeChar,
  handler: (controller) => handleFormatByWrappingWithSingleCharacter(
    controller: controller,
    character: _codeChar,
    formatStyle: SingleCharacterFormatStyle.code,
  ),
);
