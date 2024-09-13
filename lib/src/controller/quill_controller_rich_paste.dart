// This file should not be exported as the APIs in it are meant for internal usage only

import 'package:flutter/widgets.dart' show TextSelection;
import 'package:html/parser.dart' as html_parser;

import '../../quill_delta.dart';
import '../delta/delta_x.dart';
import '../editor_toolbar_controller_shared/clipboard/clipboard_service_provider.dart';
import 'quill_controller.dart';

extension QuillControllerRichPaste on QuillController {
  /// Paste the HTML into the document from [html] if not null, otherwise
  /// will read it from the Clipboard in case the [ClipboardServiceProvider.instance]
  /// support it on the current platform.
  ///
  /// The argument [html] allow to override the HTML that's being pasted,
  /// mainly to support pasting HTML on the web in [_webPasteEventSubscription].
  ///
  /// Return `true` if can paste or have pasted using HTML.
  Future<bool> pasteHTML({String? html}) async {
    final clipboardService = ClipboardServiceProvider.instance;

    Future<String?> getHTML() async {
      if (html != null) {
        return html;
      }
      if (await clipboardService.canProvideHtmlTextFromFile()) {
        return await clipboardService.getHtmlTextFromFile();
      }
      if (await clipboardService.canProvideHtmlText()) {
        return await clipboardService.getHtmlText();
      }
      return null;
    }

    final htmlText = await getHTML();
    if (htmlText != null) {
      final htmlBody = html_parser.parse(htmlText).body?.outerHtml;
      // ignore: deprecated_member_use_from_same_package
      final deltaFromClipboard = DeltaX.fromHtml(htmlBody ?? htmlText);

      _pasteUsingDelta(deltaFromClipboard);

      return true;
    }
    return false;
  }

  // Paste the Markdown into the document from [markdown] if not null, otherwise
  /// will read it from the Clipboard in case the [ClipboardServiceProvider.instance]
  /// support it on the current platform.
  ///
  /// The argument [markdown] allow to override the Markdown that's being pasted,
  /// mainly to support pasting Markdown on the web in [_webPasteEventSubscription].
  ///
  /// Return `true` if can paste or have pasted using Markdown.
  Future<bool> pasteMarkdown({String? markdown}) async {
    final clipboardService = ClipboardServiceProvider.instance;

    Future<String?> getMarkdown() async {
      if (markdown != null) {
        return markdown;
      }
      if (await clipboardService.canProvideMarkdownTextFromFile()) {
        return await clipboardService.getMarkdownTextFromFile();
      }
      if (await clipboardService.canProvideMarkdownText()) {
        return await clipboardService.getMarkdownText();
      }
      return null;
    }

    final markdownText = await getMarkdown();
    if (markdownText != null) {
      // ignore: deprecated_member_use_from_same_package
      final deltaFromClipboard = DeltaX.fromMarkdown(markdownText);

      _pasteUsingDelta(deltaFromClipboard);

      return true;
    }
    return false;
  }

  void _pasteUsingDelta(Delta deltaFromClipboard) {
    replaceText(
      selection.start,
      selection.end - selection.start,
      deltaFromClipboard,
      TextSelection.collapsed(offset: selection.end),
    );
  }
}
