import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' hide Text;
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';

import '../universal_ui/universal_ui.dart';
import '../widgets/demo_scaffold.dart';

class CustomAttrPage extends StatefulWidget {
  CustomAttrPage() {
    // should probably be called when the app first starts but since the
    // registry is a hashmap then it won't really matter for this example
    Attribute.addCustomAttribute(const RandomColorAttribute(true));
  }

  @override
  _CustomAttrPageState createState() => _CustomAttrPageState();
}

class _CustomAttrPageState extends State<CustomAttrPage> {
  final FocusNode _focusNode = FocusNode();
  QuillController? _controller;

  @override
  Widget build(BuildContext context) {
    return DemoScaffold(
      documentFilename: 'sample_data_nomedia.json',
      builder: _buildContent,
      customButtons: [
        QuillCustomButton(
            icon: Icons.smart_toy_sharp,
            onTap: () {
              if (_controller != null) {
                if (_controller!
                    .getSelectionStyle()
                    .attributes
                    .keys
                    .contains(RandomColorAttribute.KEY)) {
                  _controller!
                      .formatSelection(const RandomColorAttribute(null));
                } else {
                  _controller!
                      .formatSelection(const RandomColorAttribute(true));
                }
              }
            },
            isToggled: () {
              return _controller != null &&
                  _controller!
                      .getSelectionStyle()
                      .attributes
                      .containsKey(RandomColorAttribute.KEY);
            })
      ],
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            // update ui and randomize the colors
          });
        },
        child: const Icon(Icons.refresh),
      ),
      title: 'Custom attribute demo',
    );
  }

  Widget _buildContent(BuildContext context, QuillController? controller) {
    _controller = controller;
    var quillEditor = QuillEditor(
      controller: controller!,
      scrollController: ScrollController(),
      scrollable: true,
      focusNode: _focusNode,
      autoFocus: true,
      readOnly: false,
      expands: false,
      padding: EdgeInsets.zero,
      embedBuilders: FlutterQuillEmbeds.builders(),
      customStyleBuilder: _customStyleBuilder,
    );
    if (kIsWeb) {
      quillEditor = QuillEditor(
        controller: controller,
        scrollController: ScrollController(),
        scrollable: true,
        focusNode: _focusNode,
        autoFocus: true,
        readOnly: false,
        expands: false,
        padding: EdgeInsets.zero,
        embedBuilders: defaultEmbedBuildersWeb,
        customStyleBuilder: _customStyleBuilder,
      );
    }

    return Padding(
      padding: const EdgeInsets.all(8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: quillEditor,
      ),
    );
  }

  TextStyle _customStyleBuilder(Attribute attr) {
    if (attr.key == RandomColorAttribute.KEY) {
      // generate a random text color
      return TextStyle(
          color:
              Color((Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1));
    }

    return const TextStyle();
  }
}

// custom inline attribute
class RandomColorAttribute extends Attribute<bool?> {
  const RandomColorAttribute(bool? val)
      : super(KEY, AttributeScope.INLINE, val);

  static const String KEY = 'random-color';
}
