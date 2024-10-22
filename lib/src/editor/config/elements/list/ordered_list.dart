import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter/widgets.dart' show Widget;

@immutable
class QuillEditorOrderedListElementOptions {
  const QuillEditorOrderedListElementOptions({
    this.useTextColorForDot = true,
    this.customWidget,
  });

  final bool useTextColorForDot;
  final Widget? customWidget;
}
