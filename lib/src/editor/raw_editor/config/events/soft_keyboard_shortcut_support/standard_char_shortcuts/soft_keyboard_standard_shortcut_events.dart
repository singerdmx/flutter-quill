import '../../character_shortcuts_events.dart';
import '../../space_shortcut_events.dart';
import 'soft_keyboard_block_shortcut_events_handlers.dart';
import 'soft_keyboard_double_character_shortcut_events.dart';
import 'soft_keyboard_single_character_shortcut_events.dart';

/// These all the common CharacterShortcutEvents that are implemented
/// by the package and correspond with markdown syntax
final softKeyboardStandardCharactersShortcutEvents =
    List<CharacterShortcutEvent>.unmodifiable(<CharacterShortcutEvent>[
  softKeyboardFormatAsterisksToItalic,
  softKeyboardFormatStrikeToStrikethrough,
  softKeyboardFormatCodeCharToInlineCode,
  softKeyboardFormatDoubleAsterisksToBold,
  softKeyboardFormatDoubleUnderscoresToBold,
]);

/// These all the common SpaceShortcutEvent that are implemented
/// by the package and correspond with markdown syntax
final softKeyboardStandardSpaceShorcutEvents =
    List<SpaceShortcutEvent>.unmodifiable(<SpaceShortcutEvent>[
  softKeyboardFormatOrderedNumberToList,
  softKeyboardFormatHyphenToBulletList,
  softKeyboardFormatHeaderToHeaderStyle,
  softKeyboardFormatHeader2ToHeaderStyle,
  softKeyboardFormatHeader3ToHeaderStyle,
]);
