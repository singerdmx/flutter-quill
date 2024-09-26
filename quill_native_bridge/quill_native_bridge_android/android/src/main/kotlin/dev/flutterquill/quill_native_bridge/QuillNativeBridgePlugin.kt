package dev.flutterquill.quill_native_bridge

import QuillNativeBridgeApi
import io.flutter.embedding.engine.plugins.FlutterPlugin

class QuillNativeBridgePlugin : FlutterPlugin {
    private var quillNativeBridge: QuillNativeBridgeApi? = null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        quillNativeBridge = QuillNativeBridge(binding.applicationContext)
        requireNotNull(quillNativeBridge) { "A new instance of $QuillNativeBridgeApi was created that appeared to be null" }
        QuillNativeBridgeApi.setUp(binding.binaryMessenger, quillNativeBridge)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        QuillNativeBridgeApi.setUp(binding.binaryMessenger, quillNativeBridge)
        quillNativeBridge = null
    }
}
