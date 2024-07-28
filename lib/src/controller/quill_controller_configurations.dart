import '../editor/config/editor_configurations.dart' show QuillEditorConfigurations;
import '../toolbar/config/toolbar_configurations.dart';

class QuillControllerConfigurations {
  const QuillControllerConfigurations(
      {this.editorConfigurations,
        this.toolbarConfigurations,
      this.onClipboardPaste,
      this.requireScriptFontFeatures = false});

  /// Provides central access to editor configurations required for controller actions
  ///
  /// Future: will be changed to 'required final'
  final QuillEditorConfigurations? editorConfigurations;
  final QuillToolbarConfigurations? toolbarConfigurations;

  /// Callback when the user pastes and data has not already been processed
  ///
  /// Return true if the paste operation was handled
  final Future<bool> Function()? onClipboardPaste;

  /// Render subscript and superscript text using Open Type FontFeatures
  ///
  /// Default is false to use built-in script rendering that is independent of font capabilities
  final bool requireScriptFontFeatures;
}
