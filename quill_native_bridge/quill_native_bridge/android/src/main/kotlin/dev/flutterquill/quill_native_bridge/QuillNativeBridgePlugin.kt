package dev.flutterquill.quill_native_bridge

import android.content.Context
import dev.flutterquill.quill_native_bridge.clipboard.ClipboardReadImageHandler
import dev.flutterquill.quill_native_bridge.clipboard.ClipboardRichTextHandler
import dev.flutterquill.quill_native_bridge.clipboard.ClipboardWriteImageHandler
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler

class QuillNativeBridgePlugin : FlutterPlugin, MethodCallHandler {
    private lateinit var channel: MethodChannel
    private lateinit var context: Context

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "quill_native_bridge")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "getClipboardHTML" -> ClipboardRichTextHandler.getClipboardHtml(
                context = context, result = result,
            )

            "copyHTMLToClipboard" -> ClipboardRichTextHandler.copyHtmlToClipboard(
                context = context, call = call, result = result,
            )

            "copyImageToClipboard" -> ClipboardWriteImageHandler.copyImageToClipboard(
                context = context, call = call, result = result,
            )

            "getClipboardImage" -> ClipboardReadImageHandler.getClipboardImage(
                context = context,
                // Will convert the image to PNG
                imageType = ClipboardReadImageHandler.ImageType.AnyExceptGif,
                result = result,
            )

            "getClipboardGif" -> ClipboardReadImageHandler.getClipboardImage(
                context = context,
                imageType = ClipboardReadImageHandler.ImageType.Gif,
                result = result,
            )

            else -> result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) =
        channel.setMethodCallHandler(null)
}
