import 'package:meta/meta.dart';

import '../../quill_delta.dart';
import 'clipboard/quill_clipboard_config.dart';

export 'clipboard/quill_clipboard_config.dart';

class QuillControllerConfig {
  const QuillControllerConfig({
    this.requireScriptFontFeatures = false,
    @experimental this.clipboardConfig,
    @experimental this.fromHtml,
  });

  @experimental
  final QuillClipboardConfig? clipboardConfig;

  /// Render subscript and superscript text using Open Type FontFeatures
  ///
  /// Default is false to use built-in script rendering that is independent of font capabilities
  final bool requireScriptFontFeatures;

  /// Override for converting clipboard HTML to Delta
  final Delta Function(String html)? fromHtml;
}
