import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:web/web.dart';

// Should minimize the usage of [dart:js_interop_unsafe] when possible.
// Importing [dart:js_interop_unsafe] into it's own file
// to avoid accidentally using APIs from it.

/// Verify if the [Clipboard API](https://developer.mozilla.org/en-US/docs/Web/API/Clipboard_API)
/// is supported and available.
///
/// Can be `false` for some browsers (e.g. **Firefox**), fallback to
/// Clipboard events (e.g. [paste_event](https://developer.mozilla.org/en-US/docs/Web/API/Element/paste_event)).
bool get isClipboardApiSupported =>
    window.navigator.getProperty('clipboard'.toJS) != null &&
    window.navigator.hasProperty('clipboard'.toJS).toDart;

/// Negation of [isClipboardApiSupported]
bool get isClipbaordApiUnsupported => !isClipboardApiSupported;
