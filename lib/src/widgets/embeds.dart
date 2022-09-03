import 'package:flutter/material.dart';

import '../models/documents/nodes/leaf.dart' as leaf;
import '../models/themes/quill_dialog_theme.dart';
import '../models/themes/quill_icon_theme.dart';
import 'controller.dart';

abstract class EmbedBuilder {
  String get key;

  Widget build(
    BuildContext context,
    QuillController controller,
    leaf.Embed node,
    bool readOnly,
    void Function(GlobalKey videoContainerKey)? onVideoInit,
  );
}

abstract class EmbedToolbar {
  Iterable<Widget> build(QuillController controller, double toolbarIconSize,
      QuillIconTheme? iconTheme, QuillDialogTheme? dialogTheme);

  bool get notEmpty;
}
