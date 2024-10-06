// Used to convert a HTML to format that the Windows Clipboard expect.

const _kStartBodyTag = '<body>';
const _kEndBodyTag = '</body>';

const _kStartHtmlTag = '<html>';
const _kEndHtmlTag = '</html>';

const _kStartFragmentComment = '<!--StartFragment-->';
const _kEndFragmentComment = '<!--EndFragment-->';

/// Provide a header with additional information to the [html]
/// for the HTML to be suitable for storing in the Windows Clipboard.
/// Windows clipboard expect this additional information is set before
/// copying [html] to the clipboard.
///
/// See [HTML Clipboard Format](https://docs.microsoft.com/en-us/windows/win32/dataxchg/html-clipboard-format)
/// for more details.
String constructWindowsHtmlDescriptionHeaders(String html) {
  final htmlBodyContent = _extractBodyContent(html);

  // TODO: Handle the case where the HTML already have those headers (not common)

  // Version `1.0` is supported on Windows 10 20H2 and newer versions.
  // `StartSelection` and `EndSelection` are optional.
  // See  https://learn.microsoft.com/en-us/windows/win32/dataxchg/html-clipboard-format#description-headers-and-offsets
  const version = '1.0';

  /// HTML template containing placeholders for invalid header values; will be replaced in a separate variable.
  final invalidHeaderHtmlTemplate = '''
Version:$version
StartHTML:0001
EndHTML:0002
StartFragment:0003
EndFragment:0004
<html>$_kStartFragmentComment<body>$htmlBodyContent</body>$_kEndFragmentComment</html>
''';

  // Important: Should calculate offsets after adding the headers (StartHTML, EndHTML, etc.)

  // Windows expect those to be -1 if no context provided
  // https://learn.microsoft.com/en-us/windows/win32/dataxchg/html-clipboard-format#description-headers-and-offsets

  final startHtmlPos = invalidHeaderHtmlTemplate.indexOf(_kStartHtmlTag) +
      _kStartHtmlTag.length; // Start After <html>
  final endHtmlPos =
      invalidHeaderHtmlTemplate.indexOf(_kEndHtmlTag); // End before </html>

  final startFragment =
      invalidHeaderHtmlTemplate.indexOf(_kStartFragmentComment) +
          _kStartFragmentComment.length; // Start after <!--StartFragment-->
  final endFragment = invalidHeaderHtmlTemplate
      .indexOf(_kEndFragmentComment); // End before <!--EndFragment-->

  // Important: Those invalid values should remain with the same length
  // in the template as they used to calculate the offsets
  // even if they have different values, otherwise will
  // cause a bug as the offsets will be invalid.
  return invalidHeaderHtmlTemplate
      .replaceFirst('0001', _formatPosition(startHtmlPos))
      .replaceFirst('0002', _formatPosition(endHtmlPos))
      .replaceFirst('0003', _formatPosition(startFragment))
      .replaceFirst('0004', _formatPosition(endFragment));
}

/// Formats a given position to a 4-digit zero-padded string.
///
/// This is necessary because Windows clipboard requires the positions to
/// be formatted in a specific way, using 4 digits, with leading zeros
/// if necessary. For example, the position `121` would be formatted as
/// `00121`.
///
/// [position] The offset position (in bytes) to format.
///
/// Returns: A string representing the formatted position.
///
/// See [HTML Clipboard Format](https://docs.microsoft.com/en-us/windows/win32/dataxchg/html-clipboard-format)
/// for more details.
String _formatPosition(int position) {
  if (position == -1) {
    return position.toString();
  }
  return position.toString().padLeft(4, '0');
}

/// Extracts the content within <body>...</body> tags from the provided [html].
///
/// If `<body>` and `</body>` tags are found, the content between them is returned.
/// If `<body>` and `</body>` tags are not present, the entire HTML string is returned,
/// trimmed of leading and trailing whitespace.
///
/// Example:
/// ```dart
/// String html = '<html><head></head><body>Hello World</body></html>';
/// String bodyContent = _extractBodyContent(html);
/// print(bodyContent); // Output: 'Hello World'
/// ```
///
/// **Note**:
/// This operation is case-insensitive and will treat `<body>` and `<BODY>` as equivalent.
String _extractBodyContent(String html) {
  final startBodyIndex = html.toLowerCase().indexOf(_kStartBodyTag);
  final endBodyIndex = html.toLowerCase().indexOf(_kEndBodyTag);

  final bodyTagFound = startBodyIndex != -1 && endBodyIndex != -1;
  if (bodyTagFound) {
    // Extract the content inside <body>HTML Content</body>
    final bodyContentStartIndex = startBodyIndex + _kStartBodyTag.length;
    final bodyContent =
        html.substring(bodyContentStartIndex, endBodyIndex).trim();
    return bodyContent;
  }

  // No <body> with </body> found
  return html.trim();
}
