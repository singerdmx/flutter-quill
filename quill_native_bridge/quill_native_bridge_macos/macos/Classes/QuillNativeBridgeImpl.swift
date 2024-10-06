import Foundation
import FlutterMacOS

class QuillNativeBridgeImpl: QuillNativeBridgeApi  {
    func getClipboardHtml() throws -> String? {
        guard let htmlData = NSPasteboard.general.data(forType: .html) else {
            return nil
        }
        let html = String(data: htmlData, encoding: .utf8)
        return html
    }
    
    func copyHtmlToClipboard(html: String) throws {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(html, forType: .html)
    }
    
    func getClipboardImage() throws -> FlutterStandardTypedData? {
        // TODO: This can return null when copying an image from some apps (e.g Telegram, Apple notes), seems to work with macOS screenshot and Google Chrome, attemp to fix it later
        guard let image = NSPasteboard.general.readObjects(forClasses: [NSImage.self], options: nil)?.first as? NSImage else {
            return nil
        }
        guard let tiffData = image.tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: tiffData),
              let pngData = bitmap.representation(using: .png, properties: [:]) else {
            return nil
        }
        return FlutterStandardTypedData(bytes: pngData)
    }
    
    func copyImageToClipboard(imageBytes: FlutterStandardTypedData) throws {
        guard let image = NSImage(data: imageBytes.data) else {
            throw PigeonError(code: "INVALID_IMAGE", message: "Unable to create NSImage from image bytes.", details: nil)
        }
        
        guard let tiffData = image.tiffRepresentation else {
            throw PigeonError(code: "INVALID_IMAGE", message: "Unable to get TIFF representation from NSImage.", details: nil)
        }
        
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setData(tiffData, forType: .png)
    }
    
    func getClipboardGif() throws -> FlutterStandardTypedData? {
        let availableTypes = NSPasteboard.general.types
        throw PigeonError(code: "GIF_UNSUPPORTED", message: "Gif image is not supported on macOS. Available types: \(String(describing: availableTypes))", details: nil)
    }
    
    func getClipboardFiles() throws -> [String] {
        guard let urlList = NSPasteboard.general.readObjects(forClasses: [NSURL.self], options: nil) as? [NSURL] else {
            return []
        }
        return urlList.compactMap { url in url.path }
    }
}
