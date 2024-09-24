/// [HTML Clipboard Format](https://docs.microsoft.com/en-us/windows/win32/dataxchg/html-clipboard-format)
const _kWindowsMetadataHtmlKeys = {
  'Version',
  'StartHTML',
  'EndHTML',
  'StartFragment',
  'EndFragment',
  'StartSelection',
  'EndSelection'
};

/// Remove the leading description from Windows clipboard HTML.
///
/// This function targets specific metadata keys that precede the actual HTML content:
/// - `Version`
/// - `StartHTML`
/// - `EndHTML`
/// - `StartFragment`
/// - `EndFragment`
/// - `StartSelection`
/// - `EndSelection`
///
/// These keys are not valid HTML and should be removed for proper parsing.
///
/// This function assumes that the metadata block appears before
/// the actual HTML content and that it's formatted consistently with keys
/// followed by values.
///
/// [html] The HTML content retrieved from the clipboard, which includes the metadata.
///
/// Example of the original (dirty) HTML:
///
/// ```html
/// Version:0.9
/// StartHTML:0000000105
/// EndHTML:0000000634
/// StartFragment:0000000141
/// EndFragment:0000000598
/// <html>
/// <body>
/// <!--StartFragment--><div>Example HTML</div><!--EndFragment-->
/// </body>
/// </html>
/// ```
///
/// Refer to [HTML Clipboard Format](https://docs.microsoft.com/en-us/windows/win32/dataxchg/html-clipboard-format)
/// for details.
String stripWin32HtmlDescription(String html) {
  // Can contains dirty lines
  final lines = html.split('\n');

  final cleanedLines = [...lines];

  for (final line in lines) {
    // Stop processing when reaching the start of actual HTML content
    if (line.toLowerCase().startsWith('<html>')) {
      break;
    }

    final isWindowsHtmlMetadata = _kWindowsMetadataHtmlKeys
        .any((metadataKey) => line.startsWith('$metadataKey:'));
    if (isWindowsHtmlMetadata) {
      cleanedLines.remove(line);
      continue;
    }
  }

  return cleanedLines.join('\n');
}
