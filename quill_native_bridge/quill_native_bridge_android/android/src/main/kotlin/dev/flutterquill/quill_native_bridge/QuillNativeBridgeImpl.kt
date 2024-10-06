package dev.flutterquill.quill_native_bridge

import android.content.Context
import dev.flutterquill.quill_native_bridge.clipboard.ClipboardReadImageHandler
import dev.flutterquill.quill_native_bridge.clipboard.ClipboardRichTextHandler
import dev.flutterquill.quill_native_bridge.clipboard.ClipboardWriteImageHandler
import dev.flutterquill.quill_native_bridge.generated.QuillNativeBridgeApi

class QuillNativeBridgeImpl(private val context: Context) : QuillNativeBridgeApi {
    override fun getClipboardHtml(): String? = ClipboardRichTextHandler.getClipboardHtml(context)

    override fun copyHtmlToClipboard(html: String) =
        ClipboardRichTextHandler.copyHtmlToClipboard(context, html)

    override fun getClipboardImage(): ByteArray? = ClipboardReadImageHandler.getClipboardImage(
        context,
        // Will convert the image to PNG
        imageType = ClipboardReadImageHandler.ImageType.AnyExceptGif,
    )

    override fun copyImageToClipboard(imageBytes: ByteArray) =
        ClipboardWriteImageHandler.copyImageToClipboard(context, imageBytes)

    override fun getClipboardGif(): ByteArray? = ClipboardReadImageHandler.getClipboardImage(
        context,
        imageType = ClipboardReadImageHandler.ImageType.Gif,
    )
}