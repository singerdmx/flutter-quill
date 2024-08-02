import '../editor/config/editor_configurations.dart'
    show QuillEditorConfigurations;

class QuillControllerConfigurations {
  const QuillControllerConfigurations(
      {@Deprecated(
          'This parameter is not used and will be removed in future versions.')
      this.editorConfigurations,
      this.onClipboardPaste,
      this.requireScriptFontFeatures = false});

  @Deprecated(
      'This parameter is not used and will be removed in future versions.')
  final QuillEditorConfigurations? editorConfigurations;

  /// Callback when the user pastes and data has not already been processed
  ///
  /// Return true if the paste operation was handled
  final Future<bool> Function()? onClipboardPaste;

  /// Render subscript and superscript text using Open Type FontFeatures
  ///
  /// Default is false to use built-in script rendering that is independent of font capabilities
  final bool requireScriptFontFeatures;
}
