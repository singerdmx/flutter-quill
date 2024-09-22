package dev.flutterquill.quill_native_bridge

import android.content.ClipData
import android.content.ClipDescription
import android.content.ClipboardManager
import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.ImageDecoder
import android.os.Build
import androidx.core.content.FileProvider
import androidx.core.graphics.decodeBitmap
import dev.flutterquill.quill_native_bridge.clipboard.ClipboardImageHandler
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import java.io.File

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
            "getClipboardHTML" -> {
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

                val item = primaryClipData.getItemAt(0)

                if (!primaryClipData.description.hasMimeType(ClipDescription.MIMETYPE_TEXT_HTML)) {
                    result.success(null)
                    return
                }

                val htmlText = item.htmlText
                if (htmlText == null) {
                    result.error(
                        "HTML_TEXT_NULL",
                        "Expected the HTML Text from the Clipboard to be not null",
                        null
                    )
                    return
                }
                result.success(htmlText)
            }

            "copyHTMLToClipboard" -> {
                val html = call.arguments as? String
                if (html == null) {
                    result.error(
                        "HTML_REQUIRED",
                        "HTML is required to copy the HTML to the clipboard.",
                        null
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
                        e.toString()
                    )
                    return
                }

                result.success(null)
            }

            "copyImageToClipboard" -> {
                val imageBytes = call.arguments as? ByteArray
                if (imageBytes == null) {
                    result.error(
                        "IMAGE_BYTES_REQUIRED",
                        "Image bytes are required to copy the image to the clipboard.",
                        null,
                    )
                    return
                }

                val bitmap: Bitmap = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                    // Api 29 and above
                    try {
                        ImageDecoder.createSource(imageBytes).decodeBitmap { _, _ -> }
                    } catch (e: Exception) {
                        result.error(
                            "INVALID_IMAGE",
                            "The provided image bytes are invalid, image could not be decoded: ${e.message}",
                            e.toString(),
                        )
                        return
                    }
                } else {
                    // Backward compatibility with older versions
                    val bitmap: Bitmap? =
                        BitmapFactory.decodeByteArray(imageBytes, 0, imageBytes.size)
                    if (bitmap == null) {
                        result.error(
                            "INVALID_IMAGE",
                            "The provided image bytes are invalid. Image could not be decoded.",
                            null
                        )
                        return
                    }
                    bitmap
                }

                val tempFile = File(context.cacheDir, "temp_clipboard_image.png")

                try {
                    tempFile.outputStream().use { outputStream ->
                        val compressedSuccessfully =
                            bitmap.compress(Bitmap.CompressFormat.PNG, 100, outputStream)
                        if (!compressedSuccessfully) {
                            result.error(
                                "COULD_NOT_COMPRESS_IMAGE",
                                "Unknown error while compressing the image",
                                null,
                            )
                            return
                        }
                    }
                } catch (e: Exception) {
                    result.error(
                        "COULD_NOT_SAVE_TEMP_FILE",
                        "Unknown error while compressing and saving the temporary image file: ${e.message}",
                        e.toString()
                    )
                    return
                }

                val authority = "${context.packageName}.fileprovider"

                val imageUri = try {
                    FileProvider.getUriForFile(
                        context,
                        authority,
                        tempFile,
                    )
                } catch (e: IllegalArgumentException) {
                    result.error(
                        "ANDROID_MANIFEST_NOT_CONFIGURED",
                        "You need to configure your AndroidManifest.xml file " +
                                "to register the provider with the meta-data with authority " +
                                authority,
                        e.toString(),
                    )
                    return
                }

                try {
                    val clipboard =
                        context.getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager
                    val clip = ClipData.newUri(context.contentResolver, "Image", imageUri)
                    clipboard.setPrimaryClip(clip)
                } catch (e: Exception) {
                    result.error(
                        "COULD_NOT_COPY_IMAGE_TO_CLIPBOARD",
                        "Unknown error while copying the image to the clipboard: ${e.message}",
                        e.toString()
                    )
                    return
                }

                result.success(null)
            }

            "getClipboardImage" -> {
                ClipboardImageHandler.getClipboardImage(
                    context = context,
                    // Will convert the image to PNG
                    imageType = ClipboardImageHandler.ImageType.AnyExceptGif,
                    result = result,
                )
            }

            "getClipboardGif" -> {
                ClipboardImageHandler.getClipboardImage(
                    context = context,
                    result = result,
                    imageType = ClipboardImageHandler.ImageType.Gif,
                )
            }

            else -> result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) =
        channel.setMethodCallHandler(null)
}
