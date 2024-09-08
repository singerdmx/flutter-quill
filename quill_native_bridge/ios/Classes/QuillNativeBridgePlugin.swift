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
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
