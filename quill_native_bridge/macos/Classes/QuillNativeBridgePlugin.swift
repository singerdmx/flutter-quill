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
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
