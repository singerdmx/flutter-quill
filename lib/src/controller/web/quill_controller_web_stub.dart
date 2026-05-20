// This file should not be exported as the APIs in it are meant for internal usage only

import '../quill_controller.dart';

// This is a mock implementation to compile the app on non-web platforms.
// The real implementation is quill_controller_web_real.dart

extension QuillControllerWeb on QuillController {
  void initializeWebClipboardEvents() {
    throw UnsupportedError(
      'The initializeWebClipboardEvents() method should be called only on web.',
    );
  }

  void closeWebClipboardEvents() {
    throw UnsupportedError(
      'The closeWebClipboardEvents() method should be called only on web.',
    );
  }
}
