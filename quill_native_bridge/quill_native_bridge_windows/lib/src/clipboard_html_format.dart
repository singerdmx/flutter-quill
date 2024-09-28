import 'package:win32/win32.dart';

import '../quill_native_bridge_windows.dart';

/// From [HTML Clipboard Format](https://docs.microsoft.com/en-us/windows/win32/dataxchg/html-clipboard-format).
const _kHtmlFormatName = 'HTML Format';

int? _cfHtml;

extension ClipboardHtmlFormatExt on QuillNativeBridgeWindows {
  /// The id of [HTML Clipboard Format](https://docs.microsoft.com/en-us/windows/win32/dataxchg/html-clipboard-format).
  ///
  /// Registers the format if it doesn't exist; returns the existing format.
  /// Returns `null` if an error occurs.
  int? get cfHtml {
    _cfHtml ??= _registerHtmlFormat();
    return _cfHtml;
  }

  int? _registerHtmlFormat() {
    final htmlFormatPointer = TEXT(_kHtmlFormatName);
    final htmlFormatId = RegisterClipboardFormat(htmlFormatPointer);
    free(htmlFormatPointer);

    if (htmlFormatId == NULL) {
      // When error occurs
      return null;
    }
    return htmlFormatId;
  }
}
