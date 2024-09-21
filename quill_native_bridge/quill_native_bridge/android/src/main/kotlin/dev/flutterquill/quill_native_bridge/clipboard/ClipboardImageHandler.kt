package dev.flutterquill.quill_native_bridge.clipboard

import android.content.ClipData
import android.content.ClipboardManager
import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.ImageDecoder
import android.net.Uri
import android.os.Build
import androidx.core.graphics.decodeBitmap
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream
import java.io.FileNotFoundException

// TODO: Extract what can be extracted outside of ClipboardImageHandler for other method channels

object ClipboardImageHandler {
    private const val MIME_TYPE_IMAGE_ALL = "image/*"
    private const val MIME_TYPE_IMAGE_PNG = "image/png"
    private const val MIME_TYPE_IMAGE_JPEG = "image/jpeg"
    private const val MIME_TYPE_IMAGE_GIF = "image/gif"

    /**
     * The media/image type.
     *
     * @property Png [MIME_TYPE_IMAGE_PNG]
     * @property AnyExceptGif All images that are [MIME_TYPE_IMAGE_ALL] but not [MIME_TYPE_IMAGE_GIF]
     * @property Gif [MIME_TYPE_IMAGE_GIF]
     * @property Jpeg [MIME_TYPE_IMAGE_JPEG]
     * */
    enum class ImageType { Png, Jpeg, AnyExceptGif, Gif }

    /**
     * Read the primary clip of the system clipboard using [ClipboardManager]
     * */
    private fun getPrimaryClip(context: Context): ClipData? {
        val clipboard =
            context.getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager

        if (!clipboard.hasPrimaryClip()) {
            return null
        }

        val clipData = clipboard.primaryClip

        if (clipData == null || clipData.itemCount <= 0) {
            return null
        }

        return clipData
    }

    /**
     * Return Image URI from [clipData].
     *
     * If the [ClipData.Item.getUri] is `null` then will check if the [clipData]
     * is a text containing the file path, parse it and return the [Uri].
     *
     * Should check if can read the [Uri] even if it's non null using [readOrThrow] otherwise a exception
     * can arise when the app no longer have access to the [Uri].
     *
     * @param clipData The clip data to extract the [Uri] from.
     * @param imageType The type of the image whatever if it's png, gif or any.
     * */
    private fun getImageUri(
        clipData: ClipData,
        imageType: ImageType,
    ): Uri? {
        val clipboardItem = clipData.getItemAt(0)

        val imageUri = clipboardItem.uri
        val matchMimeType: Boolean = when (imageType) {
            ImageType.Png -> clipData.description.hasMimeType(MIME_TYPE_IMAGE_PNG)
            ImageType.Jpeg -> clipData.description.hasMimeType(MIME_TYPE_IMAGE_JPEG)
            ImageType.AnyExceptGif -> clipData.description.hasMimeType(MIME_TYPE_IMAGE_ALL) &&
                    !clipData.description.hasMimeType(MIME_TYPE_IMAGE_GIF)

            ImageType.Gif -> clipData.description.hasMimeType(MIME_TYPE_IMAGE_GIF)
        }
        if (imageUri == null || !matchMimeType) {
            // Image URI is null or the mime type doesn't match.
            // This is not widely supported but some apps do store images as file paths in a text

            // Optional: Check if the clipboard item contains text that might be a file path
            val text = clipboardItem.text ?: return null
            if (!text.startsWith("file://")) {
                return null
            }
            val fileUri = Uri.parse(text.toString())
            return try {
                fileUri
            } catch (e: Exception) {
                e.printStackTrace()
                null
            }
        }
        return imageUri
    }

    /**
     * A method to see if any exceptions can occur
     * before start reading the file.
     *
     * The app can lose access to the [Uri] due to lifecycle changes.
     *
     * @throws SecurityException When the app loses access to the [Uri] due to app lifecycle changes
     * or app restart.
     * @throws FileNotFoundException Could be thrown when the [Uri] is no longer on the clipboard.
     * */
    @Throws(Exception::class)
    private fun Uri.readOrThrow(
        context: Context,
    ) = try {
        context.contentResolver.openInputStream(this)?.close()
    } catch (e: Exception) {
        throw e
    }

    /**
     * Get the clipboard Image.
     * */
    fun getClipboardImage(
        context: Context,
        imageType: ImageType,
        result: MethodChannel.Result,
    ) {
        val primaryClipData = getPrimaryClip(context) ?: kotlin.run {
            result.success(null)
            return
        }
        val imageUri = getImageUri(
            clipData = primaryClipData,
            imageType = imageType,
        )
        if (imageUri == null) {
            result.success(null)
            return
        }
        try {
            imageUri.readOrThrow(context)
        } catch (e: Exception) {
            when (e) {
                is SecurityException -> result.error(
                    "FILE_READ_PERMISSION_DENIED",
                    "An image exists on the clipboard, but the app no longer " +
                            "has permission to access it. This may be due to the app's " +
                            "lifecycle or a recent app restart: ${e.message}",
                    e.toString(),
                )

                is FileNotFoundException -> result.error(
                    "FILE_NOT_FOUND",
                    "The image file can't be found, the provided URI could not be opened: ${e.message}",
                    e.toString()
                )

                else -> result.error(
                    "UNKNOWN_ERROR_READING_FILE",
                    "An unknown occurred while reading the image file URI: ${e.message}",
                    e.toString()
                )
            }
            return
        }
        when (imageType) {
            ImageType.Png, ImageType.Jpeg,
            ImageType.AnyExceptGif -> getClipboardImageAsPng(context, result, imageUri)

            ImageType.Gif -> getClipboardGif(context, result, imageUri)
        }
    }

    /**
     * Get the image from [imageUri] and then convert it to [Bitmap] to decode and compress it
     * to [ImageType.Png]
     * */
    private fun getClipboardImageAsPng(
        context: Context,
        result: MethodChannel.Result,
        imageUri: Uri
    ) {
        val bitmap = try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                // Api 29 and above (use a newer API)
                val source = ImageDecoder.createSource(context.contentResolver, imageUri)
                source.decodeBitmap { _, _ -> }
            } else {
                // Backward compatibility with older versions
                checkNotNull(context.contentResolver.openInputStream(imageUri)) {
                    "Input stream is null, the provider might have recently crashed."
                }.use { inputStream ->
                    val bitmap: Bitmap? = BitmapFactory.decodeStream(inputStream)
                    checkNotNull(bitmap) { "The image could not be decoded" }
                    bitmap
                }
            }
        } catch (e: Exception) {
            result.error(
                "COULD_NOT_DECODE_IMAGE",
                "Could not decode bitmap from Uri: ${e.message}",
                e.toString(),
            )
            return
        }

        val imageBytes = ByteArrayOutputStream().use { outputStream ->
            val compressedSuccessfully =
                bitmap.compress(
                    Bitmap.CompressFormat.PNG,
                    /**
                     * Quality will be ignored for png images. See [Bitmap.CompressFormat.PNG] docs
                     * */
                    100,
                    outputStream
                )
            if (!compressedSuccessfully) {
                result.error(
                    "COULD_NOT_COMPRESS_IMAGE",
                    "Unknown error while compressing the image",
                    null,
                )
                return
            }
            outputStream.toByteArray()
        }
        result.success(imageBytes)
    }

    private fun getClipboardGif(
        context: Context,
        result: MethodChannel.Result,
        imageUri: Uri
    ) {
        try {
            val imageBytes = uriToByteArray(context, imageUri)
            result.success(imageBytes)
        } catch (e: Exception) {
            result.error(
                "COULD_NOT_CONVERT_URI_TO_BYTES",
                "Could not convert Image URI to ByteArray: ${e.message}",
                e.toString(),
            )
            return
        }
    }

    private fun uriToByteArray(context: Context, uri: Uri): ByteArray {
        return checkNotNull(context.contentResolver.openInputStream(uri)) {
            "Input stream is null, the provider might have recently crashed."
        }.use { inputStream ->
            inputStream.readBytes()
        }
    }
}