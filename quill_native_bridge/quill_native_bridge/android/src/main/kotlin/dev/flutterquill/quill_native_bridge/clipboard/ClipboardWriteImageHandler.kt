package dev.flutterquill.quill_native_bridge.clipboard

import android.content.ClipData
import android.content.ClipboardManager
import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.ImageDecoder
import android.os.Build
import androidx.core.content.FileProvider
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File

object ClipboardWriteImageHandler {
    fun copyImageToClipboard(
        context: Context,
        call: MethodCall,
        result: MethodChannel.Result,
    ) {
        val imageBytes = call.arguments as? ByteArray ?: run {
            result.error(
                "IMAGE_BYTES_REQUIRED",
                "Image bytes are required to copy the image to the clipboard.",
                null,
            )
            return
        }

        val bitmap: Bitmap = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            // Api 29 and above (use a newer API)
            try {
                ImageDecoder.decodeBitmap(ImageDecoder.createSource(imageBytes))
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
                    null,
                )
                return
            }
            bitmap
        }

        val tempImageFile = File(context.cacheDir, "temp_clipboard_image.png")

        try {
            tempImageFile.outputStream().use { outputStream ->
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
                e.toString(),
            )
            return
        }

        if (!tempImageFile.exists()) {
            result.error(
                "TEMP_FILE_NOT_FOUND",
                "Recently created temporary file for copying the image to the clipboard is missing.",
                null,
            )
            return
        }

        val authority = "${context.packageName}.fileprovider"

        val imageUri = try {
            FileProvider.getUriForFile(
                context,
                authority,
                tempImageFile,
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

            // Don't delete the temporary image file, other apps will be unable to retrieve the image
            // tempImageFile.delete()
        } catch (e: Exception) {
            result.error(
                "COULD_NOT_COPY_IMAGE_TO_CLIPBOARD",
                "Unknown error while copying the image to the clipboard: ${e.message}",
                e.toString(),
            )
            return
        }

        result.success(null)
    }
}