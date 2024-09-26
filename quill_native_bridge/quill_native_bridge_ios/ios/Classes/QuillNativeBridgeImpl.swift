import Foundation
import Flutter

class QuillNativeBridgeImpl: QuillNativeBridgeApi {
    func isIosSimulator() throws -> Bool {
#if targetEnvironment(simulator)
        return true
#else
        return false
#endif
    }
    
    func getClipboardHtml() throws -> String? {
        guard let htmlData = UIPasteboard.general.data(forPasteboardType: "public.html") else {
            return nil
        }
        let html = String(data: htmlData, encoding: .utf8)
        return html
    }
    
    func copyHtmlToClipboard(html: String) throws {
        UIPasteboard.general.setValue(html, forPasteboardType: "public.html")
    }
    
    func copyImageToClipboard(imageBytes: FlutterStandardTypedData) throws {
        guard let image = UIImage(data: imageBytes.data) else {
            throw PigeonError(code: "INVALID_IMAGE", message: "Unable to create UIImage from image bytes.", details: nil)
        }
        UIPasteboard.general.image = image
    }
    
    func getClipboardImage() throws -> FlutterStandardTypedData? {
        let image = UIPasteboard.general.image
        guard let data = image?.pngData() else {
            return nil
        }
        return FlutterStandardTypedData(bytes: data)
    }
    
    func getClipboardGif() throws -> FlutterStandardTypedData? {
        guard let data = UIPasteboard.general.data(forPasteboardType: "com.compuserve.gif") else {
            return nil
        }
        return FlutterStandardTypedData(bytes: data)
        
    }
}
