class QuillControllerConfigurations {
  const QuillControllerConfigurations({this.onClipboardPaste});

  /// Callback when the user pastes and data has not already been processed
  ///
  /// Return true if the paste operation was handled
  final Future<bool> Function()? onClipboardPaste;
}
