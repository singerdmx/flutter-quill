import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

class SimpleScreen extends StatefulWidget {
  const SimpleScreen({super.key});

  @override
  State<SimpleScreen> createState() => _SimpleScreenState();
}

class _SimpleScreenState extends State<SimpleScreen> {
  final _controller = QuillController.basic();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          QuillToolbar.simple(
            controller: _controller,
            configurations: const QuillSimpleToolbarConfigurations(),
          ),
          Expanded(
            child: QuillEditor.basic(
              controller: _controller,
              configurations: const QuillEditorConfigurations(
                padding: EdgeInsets.all(16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
