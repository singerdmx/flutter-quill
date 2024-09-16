import Cocoa
import FlutterMacOS

public class QuillNativeBridgePlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "quill_native_bridge", binaryMessenger: registrar.messenger)
    let instance = QuillNativeBridgePlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getClipboardHTML":
      let pasteboard = NSPasteboard.general
      if let htmlData = pasteboard.data(forType: .html) {
          let html = String(data: htmlData, encoding: .utf8)
          result(html)
      } else {
          result(nil)
      }
    case "copyImageToClipboard":
      if let data = call.arguments as? FlutterStandardTypedData {
      if let image = NSImage(data: data.data) {
          let pasteboard = NSPasteboard.general
          pasteboard.clearContents()
          pasteboard.setData(image.tiffRepresentation!, forType: .png)
          result(nil)
      } else {
          result(FlutterError(code: "INVALID_IMAGE", message: "Unable to create NSImage from image bytes.", details: nil))
      }
      } else {
          result(FlutterError(code: "IMAGE_BYTES_REQUIRED", message: "Image bytes are required to copy the image to the clipboard.", details: nil))
      }
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
