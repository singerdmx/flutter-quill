import 'package:meta/meta.dart';

import '../../controller/quill_controller.dart';
import '../../editor_toolbar_controller_shared/quill_config.dart';
import '../theme/quill_dialog_theme.dart';
import '../theme/quill_icon_theme.dart';
import './embed_button_builder.dart';

/// Encapsulates the context required for embedding a button in a toolbar.
///
/// This class holds essential parameters for configuring embedded toolbar button,
/// and it is used within the [EmbedButtonBuilder] interface.
///
/// See also:
///
/// * [EmbedButtonBuilder]
class EmbedButtonContext {
  @internal
  EmbedButtonContext({
    required this.controller,
    required this.toolbarIconSize,
    required this.iconTheme,
    required this.dialogTheme,
    required this.baseButtonOptions,
  });

  /// The [QuillController] managing the editor's state.
  final QuillController controller;
  final double toolbarIconSize;
  final QuillIconTheme? iconTheme;
  final QuillDialogTheme? dialogTheme;

  @internal
  @experimental
  final QuillToolbarBaseButtonOptions? baseButtonOptions;
}
