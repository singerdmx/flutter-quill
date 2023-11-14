import 'package:flutter/material.dart';

import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:share_plus/share_plus.dart' show Share;

class QuillScreen extends StatefulWidget {
  const QuillScreen({
    required this.document,
    super.key,
  });

  final Document document;

  @override
  State<QuillScreen> createState() => _QuillScreenState();
}

class _QuillScreenState extends State<QuillScreen> {
  final _controller = QuillController.basic();
  final _isReadOnly = false;

  @override
  void initState() {
    super.initState();
    _controller.document = widget.document;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Quill'),
        actions: [
          IconButton(
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
    );
  }
}
