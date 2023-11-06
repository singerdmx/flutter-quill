import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/widgets.dart';
import 'package:flutter_quill/extensions.dart' as base;
import 'package:flutter_quill/flutter_quill.dart';
import 'package:universal_html/html.dart' as html;

import '../../utils.dart';
import 'shims/dart_ui_fake.dart'
    if (dart.library.html) 'shims/dart_ui_real.dart' as ui;

class QuillEditorWebImageEmbedBuilder extends EmbedBuilder {
  const QuillEditorWebImageEmbedBuilder({
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

    if (isImageBase64(imageUrl)) {
      // TODO: handle imageUrl of base64
      return const Text('Image base 64 is not supported yet.');
    }

    var height = 'auto';
    var width = 'auto';

    final style = node.style.attributes['style'];
    if (style != null) {
      final attrs = base.parseKeyValuePairs(style.value.toString(), {
        Attribute.width.key,
        Attribute.height.key,
        Attribute.margin,
        Attribute.alignment,
      });
      final heightValue = attrs[Attribute.height.key];
      if (heightValue != null) {
        height = heightValue;
      }
      final widthValue = attrs[Attribute.width.key];
      if (widthValue != null) {
        width = widthValue;
      }
    }

    ui.PlatformViewRegistry().registerViewFactory(imageUrl, (viewId) {
      return html.ImageElement()
        ..src = imageUrl
        ..style.height = height
        ..style.width = width;
    });

    return ConstrainedBox(
      constraints: constraints ?? BoxConstraints.loose(const Size(200, 200)),
      child: HtmlElementView(
        viewType: imageUrl,
      ),
    );
  }
}
