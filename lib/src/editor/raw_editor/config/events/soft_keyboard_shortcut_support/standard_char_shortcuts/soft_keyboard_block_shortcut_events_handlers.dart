import '../../space_shortcut_events.dart';
import '../format/soft_keyboard_format_space_shortcut_event_handler.dart';

const _orderedList = '1.';
const _bulletList = '-';
const _headerStyle = '#';
const _headerStyle2 = '##';
const _headerStyle3 = '###';

final SpaceShortcutEvent softKeyboardFormatOrderedNumberToList =
    SpaceShortcutEvent(
  character: _orderedList,
  handler: (node, controller) => softKeyboardHandleFormatBlockStyleBySpaceEvent(
    controller: controller,
    character: _orderedList,
    formatStyle: BlockFormatStyle.ordered,
  ),
);

final SpaceShortcutEvent softKeyboardFormatHyphenToBulletList =
    SpaceShortcutEvent(
  character: _bulletList,
  handler: (node, controller) => softKeyboardHandleFormatBlockStyleBySpaceEvent(
    controller: controller,
    character: _bulletList,
    formatStyle: BlockFormatStyle.bullet,
  ),
);

final SpaceShortcutEvent softKeyboardFormatHeaderToHeaderStyle =
    SpaceShortcutEvent(
  character: _headerStyle,
  handler: (node, controller) => softKeyboardHandleFormatBlockStyleBySpaceEvent(
    controller: controller,
    character: _headerStyle,
    formatStyle: BlockFormatStyle.header,
  ),
);

final SpaceShortcutEvent softKeyboardFormatHeader2ToHeaderStyle =
    SpaceShortcutEvent(
  character: _headerStyle2,
  handler: (node, controller) => softKeyboardHandleFormatBlockStyleBySpaceEvent(
    controller: controller,
    character: _headerStyle2,
    formatStyle: BlockFormatStyle.header,
  ),
);

final SpaceShortcutEvent softKeyboardFormatHeader3ToHeaderStyle =
    SpaceShortcutEvent(
  character: _headerStyle3,
  handler: (node, controller) => softKeyboardHandleFormatBlockStyleBySpaceEvent(
    controller: controller,
    character: _headerStyle3,
    formatStyle: BlockFormatStyle.header,
  ),
);
