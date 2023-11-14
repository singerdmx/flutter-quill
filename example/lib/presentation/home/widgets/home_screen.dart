import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _controller = QuillController.basic();
  @override
  Widget build(BuildContext context) {
    return QuillProvider(
      configurations: QuillConfigurations(
        controller: _controller,
        sharedConfigurations: QuillSharedConfigurations(
          animationConfigurations: QuillAnimationConfigurations.disableAll(),
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Flutter Quill Demo'),
        ),
        body: Column(
          children: [
            const QuillToolbar(),
            Expanded(
              child: QuillEditor.basic(
                configurations: const QuillEditorConfigurations(
                  scrollable: true,
                  padding: EdgeInsets.all(16),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
