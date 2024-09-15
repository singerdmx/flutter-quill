import '../events.dart';

/// These all the common CharacterShortcutEvents that are implemented
/// by the package and correspond with markdown syntax
final standardCharactersShortcutEvents =
    List<CharacterShortcutEvent>.unmodifiable(<CharacterShortcutEvent>[
  formatAsterisksToItalic,
  formatStrikeToStrikethrough,
  formatCodeCharToInlineCode,
  formatDoubleAsterisksToBold,
  formatDoubleUnderscoresToBold,
]);

/// These all the common SpaceShortcutEvent that are implemented
/// by the package and correspond with markdown syntax
final standardSpaceShorcutEvents =
    List<SpaceShortcutEvent>.unmodifiable(<SpaceShortcutEvent>[
  formatOrderedNumberToList,
  formatHyphenToBulletList,
  formatHeaderToHeaderStyle,
  formatHeader2ToHeaderStyle,
  formatHeader3ToHeaderStyle,
]);
