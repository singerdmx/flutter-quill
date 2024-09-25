package dev.flutterquill.quill_native_bridge.clipboard

import android.content.ClipData
import android.content.ClipDescription
import android.content.ClipboardManager
import android.content.Context
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

object ClipboardRichTextHandler {
    fun getClipboardHtml(
        context: Context,
        result: MethodChannel.Result,
    ) {
        val clipboard =
            context.getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager

        if (!clipboard.hasPrimaryClip()) {
            result.success(null)
            return
        }

        val primaryClipData = clipboard.primaryClip

        if (primaryClipData == null || primaryClipData.itemCount == 0) {
            result.success(null)
            return
        }

        if (!primaryClipData.description.hasMimeType(ClipDescription.MIMETYPE_TEXT_HTML)) {
            result.success(null)
            return
        }

        val clipboardItem = primaryClipData.getItemAt(0)

        val htmlText = clipboardItem.htmlText ?: run {
            result.error(
                "HTML_TEXT_NULL",
                "Expected the HTML Text from the Clipboard to be not null",
                null,
            )
            return
        }
        result.success(htmlText)
    }

    fun copyHtmlToClipboard(
        context: Context,
        result: MethodChannel.Result,
        call: MethodCall
    ) {
        val html = call.arguments as? String ?: run {
            result.error(
                "HTML_REQUIRED",
                "HTML is required to copy the HTML to the clipboard.",
                null,
            )
            return
        }

        try {
            val clipboard =
                context.getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager
            val clip = ClipData.newHtmlText("HTML", html, html)
            clipboard.setPrimaryClip(clip)
        } catch (e: Exception) {
            result.error(
                "COULD_NOT_COPY_HTML_TO_CLIPBOARD",
                "Unknown error while copying the HTML to the clipboard: ${e.message}",
                e.toString(),
            )
            return
        }

        result.success(null)
    }
}