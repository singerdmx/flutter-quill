import 'package:web/web.dart';
import '../dart_ui/dart_ui_fake.dart'
    if (dart.library.js_interop) '../dart_ui/dart_ui_real.dart' as ui;

void main(List<String> args) {
  HTMLImageElement;
}

void createHtmlImageElement({
  required String src,
  required String height,
  required String width,
  required String margin,
  required String alignSelf,
}) {
  ui.PlatformViewRegistry().registerViewFactory(src, (viewId) {
    return createHtmlImageElement(
      src: src,
      alignSelf: alignSelf,
      width: width,
      height: height,
      margin: margin,
    );
  });
}

void createHtmlIFrameElement({
  required String src,
  required String height,
  required String width,
  required String margin,
  required String alignSelf,
}) {
  ui.PlatformViewRegistry().registerViewFactory(
    src,
    (id) {
      return HTMLIFrameElement()
        ..style.width = width
        ..style.height = height
        ..src = src
        ..style.border = 'none'
        ..style.margin = margin
        ..style.alignSelf = alignSelf;
    },
  );
}
