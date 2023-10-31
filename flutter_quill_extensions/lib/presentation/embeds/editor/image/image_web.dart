import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/widgets.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:universal_html/html.dart' as html;

import 'shims/dart_ui_fake.dart'
    if (dart.library.html) 'shims/dart_ui_real.dart' as ui;

class ImageEmbedBuilderWeb extends EmbedBuilder {
  const ImageEmbedBuilderWeb({
    this.constraints,
  });

  final BoxConstraints? constraints;

  @override
  String get key => BlockEmbed.imageType;

  @override
  Widget build(
    BuildContext context,
    QuillController controller,
    Embed node,
    bool readOnly,
    bool inline,
    TextStyle textStyle,
  ) {
    assert(kIsWeb, 'ImageEmbedBuilderWeb is only for web platform');
    final imageUrl = node.value.data;

    ui.PlatformViewRegistry().registerViewFactory(imageUrl, (viewId) {
      return html.ImageElement()
        ..src = imageUrl
        ..style.height = 'auto'
        ..style.width = 'auto';
    });

    return ConstrainedBox(
      constraints: constraints ?? BoxConstraints.loose(const Size(200, 200)),
      child: HtmlElementView(
        viewType: imageUrl,
      ),
    );
  }
}
