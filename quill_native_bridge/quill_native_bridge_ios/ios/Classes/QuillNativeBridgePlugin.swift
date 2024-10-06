import Flutter
import UIKit

public class QuillNativeBridgePlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let messenger = registrar.messenger()
        let api = QuillNativeBridgeImpl()
        QuillNativeBridgeApiSetup.setUp(binaryMessenger: messenger, api: api)
    }
}
