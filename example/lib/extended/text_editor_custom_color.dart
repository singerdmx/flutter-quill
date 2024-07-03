import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_quill/flutter_quill.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _controller = quill.QuillController.basic();

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Text Editor'),
        ),
        body: Stack(
          children: [
            quill.QuillEditor.basic(
              configurations: quill.QuillEditorConfigurations(
                controller: _controller,
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: QuillToolbar(
                configurations: const QuillToolbarConfigurations(
                  buttonOptions: QuillSimpleToolbarButtonOptions(
                    base: QuillToolbarBaseButtonOptions(),
                  ),
                ),
                child: Row(
                  children: [
                    MinimalColorButton(
                      controller: _controller,
                      color: Colors.red,
                      child: Icon(Icons.circle, color: Colors.red),
                    ),
                    MinimalColorButton(
                      controller: _controller,
                      color: Colors.green,
                      child: Icon(Icons.circle, color: Colors.green),
                    ),
                    MinimalColorButton(
                      controller: _controller,
                      color: Colors.blue,
                      child: Icon(Icons.circle, color: Colors.blue),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}


