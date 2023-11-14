import 'package:flutter/material.dart';

import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:quill_html_converter/quill_html_converter.dart';
import 'package:share_plus/share_plus.dart' show Share;

import '../shared/widgets/home_screen_button.dart';

@immutable
class QuillScreenArgs {
  const QuillScreenArgs({required this.document});

  final Document document;
}

class QuillScreen extends StatefulWidget {
  const QuillScreen({
    required this.args,
    super.key,
  });

  final QuillScreenArgs args;

  static const routeName = '/quill';

  @override
  State<QuillScreen> createState() => _QuillScreenState();
}

class _QuillScreenState extends State<QuillScreen> {
  final _controller = QuillController.basic();
  var _isReadOnly = false;

  @override
  void initState() {
    super.initState();
    _controller.document = widget.args.document;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Quill'),
        actions: [
          IconButton(
            tooltip: 'Load with HTML',
            onPressed: () {
              final html = _controller.document.toDelta().toHtml();
              _controller.document =
                  Document.fromDelta(DeltaHtmlExt.fromHtml(html));
            },
            icon: const Icon(Icons.html),
          ),
          IconButton(
            tooltip: 'Share',
            onPressed: () {
              final plainText = _controller.document.toPlainText(
                FlutterQuillEmbeds.defaultEditorBuilders(),
              );
              if (plainText.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      "We can't share empty document, please enter some text first",
                    ),
                  ),
                );
                return;
              }
              Share.share(plainText);
            },
            icon: const Icon(Icons.share),
          ),
          const HomeScreenButton(),
        ],
      ),
      body: QuillProvider(
        configurations: QuillConfigurations(
          controller: _controller,
          sharedConfigurations: QuillSharedConfigurations(
            animationConfigurations: QuillAnimationConfigurations.disableAll(),
            extraConfigurations: const {
              QuillSharedExtensionsConfigurations.key:
                  QuillSharedExtensionsConfigurations(
                assetsPrefix: 'assets',
              ),
            },
          ),
        ),
        child: Column(
          children: [
            if (!_isReadOnly)
              QuillToolbar(
                configurations: QuillToolbarConfigurations(
                  embedButtons: FlutterQuillEmbeds.toolbarButtons(),
                ),
              ),
            Expanded(
              child: QuillEditor.basic(
                configurations: QuillEditorConfigurations(
                  scrollable: true,
                  readOnly: _isReadOnly,
                  placeholder: 'Start writting your notes...',
                  padding: const EdgeInsets.all(16),
                  embedBuilders: FlutterQuillEmbeds.defaultEditorBuilders(),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(_isReadOnly ? Icons.lock : Icons.edit),
        onPressed: () {
          setState(() {
            _isReadOnly = !_isReadOnly;
          });
        },
      ),
    );
  }
}
