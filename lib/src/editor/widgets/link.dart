import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../controller/quill_controller.dart';
import '../../document/attribute.dart';
import '../../document/nodes/node.dart';
import '../../l10n/extensions/localizations_ext.dart';

const linkPrefixes = [
  'mailto:', // email
  'tel:', // telephone
  'sms:', // SMS
  'callto:',
  'wtai:',
  'market:',
  'geopoint:',
  'ymsgr:',
  'msnim:',
  'gtalk:', // Google Talk
  'skype:',
  'sip:', // Lync
  'whatsapp:',
  'http'
];

/// List of possible actions returned from [LinkActionPickerDelegate].
enum LinkMenuAction {
  /// Launch the link
  launch,

  /// Copy to clipboard
  copy,

  /// Remove link style attribute
  remove,

  /// No-op
  none,
}

/// Used internally by widget layer.
typedef LinkActionPicker = Future<LinkMenuAction> Function(Node linkNode);

typedef LinkActionPickerDelegate = Future<LinkMenuAction> Function(
    BuildContext context, String link, Node node);

Future<LinkMenuAction> defaultLinkActionPickerDelegate(
    BuildContext context, String link, Node node) async {
  switch (defaultTargetPlatform) {
    case TargetPlatform.iOS:
      return _showCupertinoLinkMenu(context, link);
    case TargetPlatform.android:
      return _showMaterialMenu(context, link);
    default:
      assert(
        false,
        'defaultShowLinkActionsMenu not supposed to '
        'be invoked for $defaultTargetPlatform. '
        "it's only supported for iOS and Android.",
      );
      return LinkMenuAction.none;
  }
}

TextRange getLinkRange(Node node) {
  var start = node.documentOffset;
  var length = node.length;
  var prev = node.previous;
  final linkAttr = node.style.attributes[Attribute.link.key]!;
  while (prev != null) {
    if (prev.style.attributes[Attribute.link.key] == linkAttr) {
      start = prev.documentOffset;
      length += prev.length;
      prev = prev.previous;
    } else {
      break;
    }
  }

  var next = node.next;
  while (next != null) {
    if (next.style.attributes[Attribute.link.key] == linkAttr) {
      length += next.length;
      next = next.next;
    } else {
      break;
    }
  }
  return TextRange(start: start, end: start + length);
}

/// Contains information about link and text.
class QuillTextLink {
  QuillTextLink(
    this.text,
    this.link,
  );

  factory QuillTextLink.prepare(QuillController controller) {
    final link = _getLinkAttributeValue(controller);
    final index = controller.selection.start;

    String? text;
    if (link != null) {
      // text should be the link's corresponding text, not selection
      final leaf = controller.document.querySegmentLeafNode(index).leaf;
      if (leaf != null) {
        text = leaf.toPlainText();
      }
    }

    final len = controller.selection.end - index;
    text ??= len == 0 ? '' : controller.document.getPlainText(index, len);

    return QuillTextLink(text, link);
  }

  final String text;
  final String? link;

  void submit(QuillController controller) {
    var index = controller.selection.start;
    var length = controller.selection.end - index;
    final linkValue = _getLinkAttributeValue(controller);

    if (linkValue != null) {
      // text should be the link's corresponding text, not selection
      final leaf = controller.document.querySegmentLeafNode(index).leaf;
      if (leaf != null) {
        final range = getLinkRange(leaf);
        index = range.start;
        length = range.end - range.start;
      }
    }
    controller
      ..replaceText(index, length, text, null)
      ..formatText(index, text.length, LinkAttribute(link));
  }

  static String? _getLinkAttributeValue(QuillController controller) {
    return controller.getSelectionStyle().attributes[Attribute.link.key]?.value;
  }

  static bool isSelected(QuillController controller) {
    return _getLinkAttributeValue(controller) != null;
  }
}

Future<LinkMenuAction> _showCupertinoLinkMenu(
    BuildContext context, String link) async {
  final result = await showCupertinoModalPopup<LinkMenuAction>(
    // Set useRootNavigator to false to fix https://github.com/singerdmx/flutter-quill/issues/1170
    useRootNavigator: false,
    context: context,
    builder: (ctx) {
      return CupertinoActionSheet(
        title: Text(link),
        actions: [
          _CupertinoAction(
            title: context.loc.open,
            icon: Icons.language_sharp,
            onPressed: () => Navigator.of(context).pop(LinkMenuAction.launch),
          ),
          _CupertinoAction(
            title: context.loc.copy,
            icon: Icons.copy_sharp,
            onPressed: () => Navigator.of(context).pop(LinkMenuAction.copy),
          ),
          _CupertinoAction(
            title: context.loc.remove,
            icon: Icons.link_off_sharp,
            onPressed: () => Navigator.of(context).pop(LinkMenuAction.remove),
          ),
        ],
      );
    },
  );
  return result ?? LinkMenuAction.none;
}

class _CupertinoAction extends StatelessWidget {
  const _CupertinoAction({
    required this.title,
    required this.icon,
    required this.onPressed,
  });

  final String title;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return CupertinoActionSheetAction(
      onPressed: onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                textAlign: TextAlign.start,
                style: TextStyle(color: theme.colorScheme.onSurface),
              ),
            ),
            Icon(
              icon,
              size: theme.iconTheme.size,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.75),
            )
          ],
        ),
      ),
    );
  }
}

Future<LinkMenuAction> _showMaterialMenu(
    BuildContext context, String link) async {
  final result = await showModalBottomSheet<LinkMenuAction>(
    context: context,
    builder: (ctx) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _MaterialAction(
            title: context.loc.open,
            icon: Icons.language_sharp,
            onPressed: () => Navigator.of(context).pop(LinkMenuAction.launch),
          ),
          _MaterialAction(
            title: context.loc.copy,
            icon: Icons.copy_sharp,
            onPressed: () => Navigator.of(context).pop(LinkMenuAction.copy),
          ),
          _MaterialAction(
            title: context.loc.remove,
            icon: Icons.link_off_sharp,
            onPressed: () => Navigator.of(context).pop(LinkMenuAction.remove),
          ),
        ],
      );
    },
  );

  return result ?? LinkMenuAction.none;
}

class _MaterialAction extends StatelessWidget {
  const _MaterialAction({
    required this.title,
    required this.icon,
    required this.onPressed,
  });

  final String title;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(
        icon,
        size: theme.iconTheme.size,
        color: theme.colorScheme.onSurface.withValues(alpha: 0.75),
      ),
      title: Text(title),
      onTap: onPressed,
    );
  }
}
