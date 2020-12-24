import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_quill/widgets/controller.dart';
import 'package:flutter_quill/widgets/editor.dart';
import 'package:flutter_quill/widgets/toolbar.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  QuillController _controller = QuillController.basic();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      children: [
        QuillToolbar.basic(
            controller: _controller, uploadFileCallback: _uploadImageCallBack),
        Expanded(
          child: Container(
            child: QuillEditor.basic(
              controller: _controller,
              readOnly: false, // change to true to be view only mode
            ),
          ),
        )
      ],
    ));
  }

  Future<String> _uploadImageCallBack(File file) async {
    // call upload file API and return file's absolute url
    return new Completer<String>().future;
  }
}
