import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/models/documents/document.dart';
import 'package:flutter_quill/models/documents/nodes/leaf.dart' as leaf;
import 'package:flutter_quill/widgets/controller.dart';
import 'package:flutter_quill/widgets/default_styles.dart';
import 'package:flutter_quill/widgets/editor.dart';

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

    print(Directory.current.path); // /

    _loadFromAssets();
  }

  Future<void> _loadFromAssets() async {
    try {
      final result = await rootBundle.loadString('assets/welcome.note');
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
      body: _buildWelcomeEditor(context),
    );
  }

  Widget _buildWelcomeEditor(BuildContext context) {
    return Column(
      children: [
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
              embedBuilder: _embedBuilder,
              enableInteractiveSelection: true,
              expands: false,
              padding: EdgeInsets.zero,
            ),
          ),
        ),
      ],
    );
  }

  Widget _embedBuilder(BuildContext context, leaf.Embed node) {
    if (node.value.type == 'hr') {
      final style = QuillStyles.getStyles(context, true);
      return Divider(
        height: style.paragraph.style.fontSize * style.paragraph.style.height,
        thickness: 2,
        color: Colors.grey.shade200,
      );
    }
    throw UnimplementedError(
        'Embeddable type "${node.value.type}" is not supported by default embed '
        'builder of QuillEditor. You must pass your own builder function to '
        'embedBuilder property of QuillEditor or QuillField widgets.');
  }
}
