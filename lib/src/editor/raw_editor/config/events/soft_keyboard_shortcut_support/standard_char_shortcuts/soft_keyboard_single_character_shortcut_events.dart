import '../../character_shortcuts_events.dart';
import '../format/soft_keyboard_format_single_character_handler.dart';

const _asterisk = '*';
const _strikeChar = '~';
const _codeChar = '`';

final CharacterShortcutEvent softKeyboardFormatAsterisksToItalic =
    CharacterShortcutEvent(
  key: 'Format single asterisks to italic',
  character: _asterisk,
  handler: (controller) =>
      softKeyboardHandleFormatByWrappingWithSingleCharacter(
    controller: controller,
    character: _asterisk,
    formatStyle: SingleCharacterFormatStyle.italic,
  ),
);

final CharacterShortcutEvent softKeyboardFormatStrikeToStrikethrough =
    CharacterShortcutEvent(
  key: 'Format single strikes to strike style',
  character: _strikeChar,
  handler: (controller) =>
      softKeyboardHandleFormatByWrappingWithSingleCharacter(
    controller: controller,
    character: _strikeChar,
    formatStyle: SingleCharacterFormatStyle.strikethrough,
  ),
);

final CharacterShortcutEvent softKeyboardFormatCodeCharToInlineCode =
    CharacterShortcutEvent(
  key: 'Format single code to inline code style',
  character: _codeChar,
  handler: (controller) =>
      softKeyboardHandleFormatByWrappingWithSingleCharacter(
    controller: controller,
    character: _codeChar,
    formatStyle: SingleCharacterFormatStyle.code,
  ),
);
