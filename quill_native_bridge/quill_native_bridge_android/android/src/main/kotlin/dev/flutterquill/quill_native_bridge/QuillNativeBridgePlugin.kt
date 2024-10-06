package dev.flutterquill.quill_native_bridge

import dev.flutterquill.quill_native_bridge.generated.QuillNativeBridgeApi
import io.flutter.embedding.engine.plugins.FlutterPlugin

class QuillNativeBridgePlugin : FlutterPlugin {
    private var api: QuillNativeBridgeApi? = null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        api = QuillNativeBridgeImpl(binding.applicationContext)
        requireNotNull(api) { "A new instance of $QuillNativeBridgeApi was created that appeared to be null" }
        QuillNativeBridgeApi.setUp(binding.binaryMessenger, api)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        QuillNativeBridgeApi.setUp(binding.binaryMessenger, api)
        api = null
    }
}
