class QuillControllerConfigurations {
  const QuillControllerConfigurations(
      {this.onClipboardPaste, this.requireScriptFontFeatures = false});

  /// Callback when the user pastes and data has not already been processed
  ///
  /// Return true if the paste operation was handled
  final Future<bool> Function()? onClipboardPaste;

  /// Render subscript and superscript text using Open Type FontFeatures
  ///
  /// Default is false to use built-in script rendering that is independent of font capabilities
  final bool requireScriptFontFeatures;
}
