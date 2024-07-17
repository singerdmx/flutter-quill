import 'package:flutter/widgets.dart' show Widget;

import '../../controller/quill_controller.dart';
import '../theme/quill_dialog_theme.dart';
import '../theme/quill_icon_theme.dart';

typedef EmbedButtonBuilder = Widget Function(
  QuillController controller,
  double toolbarIconSize,
  QuillIconTheme? iconTheme,
  QuillDialogTheme? dialogTheme,
);
