// This file should not be exported as the APIs in it are meant for internal usage only

import 'dart:async' show StreamSubscription;

import 'package:web/web.dart';

import '../quill_controller.dart';

StreamSubscription? _webPasteEventSubscription;

extension QuillControllerWeb on QuillController {
  void initializeWebClipboardEvents() {
    _webPasteEventSubscription =
        EventStreamProviders.pasteEvent.forTarget(window.document).listen((e) {
      clipboardPaste();
      e.preventDefault();
    });
  }

  void closeWebClipboardEvents() {
    _webPasteEventSubscription?.cancel();
    _webPasteEventSubscription = null;
  }
}
