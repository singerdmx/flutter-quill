package dev.flutterquill.quill_native_bridge

import android.content.ClipDescription
import android.content.ClipboardManager
import android.content.Context

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

class QuillNativeBridgePlugin : FlutterPlugin, MethodCallHandler {
    private lateinit var channel: MethodChannel
    private lateinit var context: Context

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "quill_native_bridge")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "getClipboardHTML" -> {
                val clipboard =
                    context.getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager

                if (!clipboard.hasPrimaryClip()) {
                    result.success(null)
                    return
                }

                val clipData = clipboard.primaryClip

                if (clipData == null) {
                    result.success(null)
                    return
                }

                val item = clipData.getItemAt(0)

                if (item.text == null || clipboard.primaryClipDescription?.hasMimeType(
                        ClipDescription.MIMETYPE_TEXT_HTML
                    ) == false
                ) {
                    result.success(null)
                    return
                }

                val htmlText = item.htmlText
                if (htmlText == null) {
                    result.error(
                        "HTML_TEXT_NULL",
                        "Expected the HTML Text from Clipboard to be not null",
                        null
                    )
                    return
                }
                result.success(htmlText)
            }

            else -> result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) =
        channel.setMethodCallHandler(null)
}
