import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:app/pages/read_only_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/models/documents/document.dart';
import 'package:flutter_quill/widgets/controller.dart';
import 'package:flutter_quill/widgets/editor.dart';
import 'package:flutter_quill/widgets/toolbar.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  QuillController _controller;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _loadFromAssets();
  }

  Future<void> _loadFromAssets() async {
    try {
      final result = await rootBundle.loadString('assets/sample_data.json');
      final doc = Document.fromJson(jsonDecode(result));
      setState(() {
        _controller = QuillController(
            document: doc, selection: TextSelection.collapsed(offset: 0));
      });
    } catch (error) {
      final doc = Document()..insert(0, 'Empty asset');
      setState(() {
        _controller = QuillController(
            document: doc, selection: TextSelection.collapsed(offset: 0));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null) {
      return Scaffold(body: Center(child: Text('Loading...')));
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey.shade800,
        elevation: 0,
        centerTitle: false,
        title: Text(
          'Flutter Quill',
        ),
        actions: [],
      ),
      drawer: Material(
        color: Colors.grey.shade800,
        child: _buildMenuBar(context),
      ),
      body: _buildWelcomeEditor(context),
    );
  }

  Widget _buildWelcomeEditor(BuildContext context) {
    return Column(
      children: [
        QuillToolbar.basic(
            controller: _controller,
            uploadFileCallback: _fakeUploadImageCallBack),
        Divider(height: 1, thickness: 1, color: Colors.grey.shade200),
        Expanded(
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.only(left: 16.0, right: 16.0),
            child: QuillEditor(
              controller: _controller,
              scrollController: ScrollController(),
              scrollable: true,
              focusNode: _focusNode,
              autoFocus: true,
              readOnly: false,
              enableInteractiveSelection: true,
              expands: false,
              padding: EdgeInsets.zero,
            ),
          ),
        ),
      ],
    );
  }

  Future<String> _fakeUploadImageCallBack(File file) async {
    print(file);
    var completer = new Completer<String>();
    completer.complete(
        'https://user-images.githubusercontent.com/122956/72955931-ccc07900-3d52-11ea-89b1-d468a6e2aa2b.png');
    return completer.future;
  }

  Widget _buildMenuBar(BuildContext context) {
    final itemStyle = TextStyle(color: Colors.white);
    return ListView(
      children: [
        ListTile(
          title: Text('Read only demo', style: itemStyle),
          dense: true,
          visualDensity: VisualDensity.compact,
          onTap: _readOnly,
        )
      ],
    );
  }

  void _readOnly() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => ReadOnlyPage(),
      ),
    );
  }
}
