package dev.flutterquill.quill_native_bridge.clipboard

import android.content.ClipData
import android.content.ClipDescription
import android.content.ClipboardManager
import android.content.Context
import dev.flutterquill.quill_native_bridge.generated.FlutterError

object ClipboardRichTextHandler {
    fun getClipboardHtml(context: Context): String? {
        val clipboard =
            context.getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager

        if (!clipboard.hasPrimaryClip()) {
            return null
        }

        val primaryClipData = clipboard.primaryClip

        if (primaryClipData == null || primaryClipData.itemCount == 0) {
            return null
        }

        if (!primaryClipData.description.hasMimeType(ClipDescription.MIMETYPE_TEXT_HTML)) {
            return null
        }

        val clipboardItem = primaryClipData.getItemAt(0)

        val htmlText = clipboardItem.htmlText ?: throw FlutterError(
            "HTML_TEXT_NULL",
            "Expected the HTML Text from the Clipboard to be not null"
        )
        return htmlText
    }

    fun copyHtmlToClipboard(
        context: Context,
        html: String,
    ) {
        try {
            val clipboard =
                context.getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager
            val clip = ClipData.newHtmlText("HTML", html, html)
            clipboard.setPrimaryClip(clip)
        } catch (e: Exception) {
            throw FlutterError(
                "COULD_NOT_COPY_HTML_TO_CLIPBOARD",
                "Unknown error while copying the HTML to the clipboard: ${e.message}",
                e.toString(),
            )
        }
    }
}