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
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
