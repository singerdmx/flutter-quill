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
    case "copyHTMLToClipboard":
      guard let html = call.arguments as? String else {
        result(FlutterError(code: "HTML_REQUIRED", message: "HTML is required to copy the HTML to the clipboard.", details: nil))
        return
      }
      let pasteboard = NSPasteboard.general
      pasteboard.clearContents()
      pasteboard.setString(html, forType: .html)
      result(nil)
    case "copyImageToClipboard":
        guard let data = call.arguments as? FlutterStandardTypedData else {
            result(FlutterError(code: "IMAGE_BYTES_REQUIRED", message: "Image bytes are required to copy the image to the clipboard.", details: nil))
            return
        }

        guard let image = NSImage(data: data.data) else {
            result(FlutterError(code: "INVALID_IMAGE", message: "Unable to create NSImage from image bytes.", details: nil))
            return
        }

        guard let tiffData = image.tiffRepresentation else {
            result(FlutterError(code: "INVALID_IMAGE", message: "Unable to get TIFF representation from NSImage.", details: nil))
            return
        }

        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setData(tiffData, forType: .png)
        result(nil)

    case "getClipboardImage":
      let pasteboard = NSPasteboard.general

      // TODO: This can return null when copying an image from other apps (e.g Telegram, Apple notes), seems to work
      // with macOS screenshot and Google Chrome, fix this issue later
      guard let image = pasteboard.readObjects(forClasses: [NSImage.self], options: nil)?.first as? NSImage else {
        result(nil)
        return
      }
        if let tiffData = image.tiffRepresentation,
           let bitmap = NSBitmapImageRep(data: tiffData),
           let pngData = bitmap.representation(using: .png, properties: [:]) {
            result(pngData)
        } else {
            result(nil)
        }
    case "getClipboardGif":
    // TODO: Add support for getClipboardGif() on macOS if possible
    let availableTypes = NSPasteboard.general.types
    result(FlutterError(code: "GIF_UNSUPPORTED", message: "Gif image is not supported on macOS. Available types: \(String(describing: availableTypes))", details: nil))
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
