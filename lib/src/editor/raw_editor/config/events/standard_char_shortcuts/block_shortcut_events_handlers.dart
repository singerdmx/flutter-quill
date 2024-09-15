import '../format/format_space_shortcut_event_handler.dart';
import '../space_shortcut_events.dart';

const _orderedList = '1.';
const _bulletList = '-';
const _headerStyle = '#';
const _headerStyle2 = '##';
const _headerStyle3 = '###';

final SpaceShortcutEvent formatOrderedNumberToList = SpaceShortcutEvent(
  character: _orderedList,
  handler: (node, controller) => handleFormatBlockStyleBySpaceEvent(
    controller: controller,
    character: _orderedList,
    formatStyle: BlockFormatStyle.ordered,
  ),
);

final SpaceShortcutEvent formatHyphenToBulletList = SpaceShortcutEvent(
  character: _bulletList,
  handler: (node, controller) => handleFormatBlockStyleBySpaceEvent(
    controller: controller,
    character: _bulletList,
    formatStyle: BlockFormatStyle.bullet,
  ),
);

final SpaceShortcutEvent formatHeaderToHeaderStyle = SpaceShortcutEvent(
  character: _headerStyle,
  handler: (node, controller) => handleFormatBlockStyleBySpaceEvent(
    controller: controller,
    character: _headerStyle,
    formatStyle: BlockFormatStyle.header,
  ),
);

final SpaceShortcutEvent formatHeader2ToHeaderStyle = SpaceShortcutEvent(
  character: _headerStyle2,
  handler: (node, controller) => handleFormatBlockStyleBySpaceEvent(
    controller: controller,
    character: _headerStyle2,
    formatStyle: BlockFormatStyle.header,
  ),
);

final SpaceShortcutEvent formatHeader3ToHeaderStyle = SpaceShortcutEvent(
  character: _headerStyle3,
  handler: (node, controller) => handleFormatBlockStyleBySpaceEvent(
    controller: controller,
    character: _headerStyle3,
    formatStyle: BlockFormatStyle.header,
  ),
);
