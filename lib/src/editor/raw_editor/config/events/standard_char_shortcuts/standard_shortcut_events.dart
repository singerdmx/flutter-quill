import '../events.dart';

final standardCharactersShortcutEvents =
    List<CharacterShortcutEvent>.unmodifiable(<CharacterShortcutEvent>[
  formatAsterisksToItalic,
  formatStrikeToStrikethrough,
  formatCodeCharToInlineCode,
  formatDoubleAsterisksToBold,
  formatDoubleUnderscoresToBold,
]);

final standardSpaceShorcutEvents =
    List<SpaceShortcutEvent>.unmodifiable(<SpaceShortcutEvent>[
  formatOrderedNumberToList,
  formatHyphenToBulletList,
  formatHeaderToHeaderStyle,
  formatHeader2ToHeaderStyle,
  formatHeader3ToHeaderStyle,
]);
