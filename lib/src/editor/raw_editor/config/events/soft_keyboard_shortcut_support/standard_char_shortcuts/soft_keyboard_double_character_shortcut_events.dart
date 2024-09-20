import '../../character_shortcuts_events.dart';
import '../format/soft_keyboard_format_double_character_handler.dart';

const _asterisk = '*';
const _underscore = '_';

final CharacterShortcutEvent softKeyboardFormatDoubleAsterisksToBold =
    CharacterShortcutEvent(
  key: 'Format double asterisks to bold',
  character: _asterisk,
  handler: (controller) =>
      softKeyboardHandleFormatByWrappingWithDoubleCharacter(
    controller: controller,
    character: _asterisk,
    formatStyle: DoubleCharacterFormatStyle.bold,
  ),
);

final CharacterShortcutEvent softKeyboardFormatDoubleUnderscoresToBold =
    CharacterShortcutEvent(
  key: 'Format double underscores to bold',
  character: _underscore,
  handler: (controller) =>
      softKeyboardHandleFormatByWrappingWithDoubleCharacter(
    controller: controller,
    character: _underscore,
    formatStyle: DoubleCharacterFormatStyle.bold,
  ),
);
