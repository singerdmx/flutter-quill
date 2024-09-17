import Flutter
import UIKit

public class QuillNativeBridgePlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "quill_native_bridge", binaryMessenger: registrar.messenger())
    let instance = QuillNativeBridgePlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "isIOSSimulator":
      #if targetEnvironment(simulator)
        result(true)
      #else
        result(false)
      #endif
    case "getClipboardHTML":
      let pasteboard = UIPasteboard.general
      if let htmlData = pasteboard.data(forPasteboardType: "public.html") {
        let html = String(data: htmlData, encoding: .utf8)
        result(html)
      } else {
        result(nil)
      }
    case "copyImageToClipboard":
      if let data = call.arguments as? FlutterStandardTypedData {
      if let image = UIImage(data: data.data) {
          UIPasteboard.general.image = image
          result(nil)
        } else {
            result(FlutterError(code: "INVALID_IMAGE", message: "Unable to create UIImage from image bytes.", details: nil))
        }
      } else {
          result(FlutterError(code: "IMAGE_BYTES_REQUIRED", message: "Image bytes are required to copy the image to the clipboard.", details: nil))
      }
    case "getClipboardImage":
      let image = UIPasteboard.general.image
      let data = image?.pngData()
      result(data)
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
