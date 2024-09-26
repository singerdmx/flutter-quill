// This file should not be exported as the APIs in it are meant for internal usage only

import 'dart:async' show StreamSubscription;

import 'package:web/web.dart';

import '../quill_controller.dart';
// ignore: unused_import
import '../quill_controller_rich_paste.dart';

/// Paste event for the web.
///
/// Will be `null` when [QuillControllerWeb.initializeWebPasteEvent] was not called
/// or the subscription was canceled due to calling [QuillControllerWeb.cancelWebPasteEvent]
///
/// See: https://developer.mozilla.org/en-US/docs/Web/API/Element/paste_event
StreamSubscription? _webPasteEventSubscription;

extension QuillControllerWeb on QuillController {
  void initializeWebPasteEvent() {
    _webPasteEventSubscription =
        EventStreamProviders.pasteEvent.forTarget(window.document).listen((e) {
      // TODO: See if we can support markdown paste
      final html = e.clipboardData?.getData('text/html');
      if (html == null) {
        return;
      }
      // TODO: Temporarily disable the rich text pasting feature as a workaround
      //    due to issue https://github.com/singerdmx/flutter-quill/issues/2220
      // pasteHTML(html: html);
    });
  }

  void cancelWebPasteEvent() {
    _webPasteEventSubscription?.cancel();
    _webPasteEventSubscription = null;
  }
}
