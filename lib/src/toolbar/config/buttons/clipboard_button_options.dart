/// @docImport '../../buttons/clipboard_button.dart';

@experimental
library;

import 'package:meta/meta.dart';
import 'toggle_style_options.dart';

@experimental
class QuillToolbarClipboardButtonOptions
    extends QuillToolbarToggleStyleButtonOptions {
  const QuillToolbarClipboardButtonOptions({
    super.iconData,
    super.afterButtonPressed,
    super.childBuilder,
    super.iconTheme,
    super.tooltip,
    super.iconSize,
    super.iconButtonFactor,
    this.enableClipboardPaste,
  });

  /// Determines if the paste button is enabled. The button is disabled and cannot be clicked if set to `false`.
  ///
  /// Defaults to [ClipboardMonitor] in case of `null`, which checks if the clipboard has content to paste every second and only then enables the button, indicating to the user that they can paste something.
  ///
  /// Set it to `true` to enable it even if the clipboard has no content to paste, which will do nothing on a press.
  ///
  /// Only applicable if the [QuillToolbarClipboardButton.clipboardAction]
  /// is [ClipboardAction.paste].
  final bool? enableClipboardPaste;
}
