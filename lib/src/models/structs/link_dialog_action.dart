import 'package:flutter/widgets.dart' show Widget;
import 'package:meta/meta.dart' show immutable;

@immutable
class LinkDialogAction {
  const LinkDialogAction({required this.builder});

  final Widget Function(bool canPress, void Function() applyLink) builder;
}
