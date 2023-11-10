import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/widgets.dart';
import 'package:flutter_quill/extensions.dart' as base;
import 'package:flutter_quill/flutter_quill.dart';
import 'package:universal_html/html.dart' as html;

import '../../../models/config/editor/image/image_web.dart';
import '../../utils.dart';
import '../shims/dart_ui_fake.dart'
    if (dart.library.html) '../shims/dart_ui_real.dart' as ui;

class QuillEditorWebImageEmbedBuilder extends EmbedBuilder {
  const QuillEditorWebImageEmbedBuilder({
    required this.configurations,
  });

  final QuillEditorWebImageEmbedConfigurations configurations;

  @override
  String get key => BlockEmbed.imageType;

  @override
  bool get expanded => false;

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

    final (height, width, margin, alignment) = _getImageWebAttributes(node);

    var imageSource = node.value.data.toString();

    // This logic make sure if the image is imageBase64 then
    // it make sure if the pattern is like
    // data:image/png;base64, [base64 encoded image string here]
    // if not then it will add the data:image/png;base64, at the first
    if (isImageBase64(imageSource)) {
      // Sometimes the image base 64 for some reasons
      // doesn't displayed with the
      if (!(imageSource.startsWith('data:image/') &&
          imageSource.contains('base64'))) {
        imageSource = 'data:image/png;base64, $imageSource';
      }
    }

    ui.PlatformViewRegistry().registerViewFactory(imageSource, (viewId) {
      return html.ImageElement()
        ..src = imageSource
        ..style.height = height
        ..style.width = width
        ..style.margin = margin
        ..style.alignSelf = alignment;
    });

    return ConstrainedBox(
      constraints: configurations.constraints ??
          BoxConstraints.loose(const Size(200, 200)),
      child: HtmlElementView(
        viewType: imageSource,
      ),
    );
  }
}

/// Prefer the width, and height from the css style attribute if exits
/// it can be `auto` or `100px` so it's specific to HTML && CSS
/// if not, we will use the one from attributes which is usually just an double
(
  String height,
  String width,
  String margin,
  String alignment,
) _getImageWebAttributes(
  Node node,
) {
  var height = 'auto';
  var width = 'auto';
  // TODO: Add support for margin and alignment
  const margin = 'auto';
  const alignment = 'center';

  final cssStyle = node.style.attributes['style'];

  // Usually double value
  final heightValue = node.style.attributes[Attribute.height.key]?.value;
  final widthValue = node.style.attributes[Attribute.width.key]?.value;

  if (cssStyle != null) {
    final attrs = base.parseKeyValuePairs(cssStyle.value.toString(), {
      Attribute.width.key,
      Attribute.height.key,
      Attribute.margin,
      Attribute.alignment,
    });
    final cssHeightValue = attrs[Attribute.height.key];
    if (cssHeightValue != null) {
      height = cssHeightValue;
    } else {
      height = '${heightValue}px';
    }
    final cssWidthValue = attrs[Attribute.width.key];
    if (cssWidthValue != null) {
      width = cssWidthValue;
    } else if (widthValue != null) {
      width = '${widthValue}px';
    }

    return (height, width, margin, alignment);
  }

  if (heightValue != null) {
    height = '${heightValue}px';
  }
  if (widthValue != null) {
    width = '${widthValue}px';
  }

  return (height, width, margin, alignment);
}
