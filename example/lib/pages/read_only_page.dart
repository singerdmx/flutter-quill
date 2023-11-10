// ignore_for_file: avoid_redundant_argument_values

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/extensions.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';

import '../widgets/demo_scaffold.dart';

class ReadOnlyPage extends StatefulWidget {
  const ReadOnlyPage({super.key});

  @override
  _ReadOnlyPageState createState() => _ReadOnlyPageState();
}

class _ReadOnlyPageState extends State<ReadOnlyPage> {
  final FocusNode _focusNode = FocusNode();

  bool _edit = false;

  @override
  Widget build(BuildContext context) {
    return DemoScaffold(
      documentFilename: isDesktop(supportWeb: false)
          ? 'assets/sample_data_nomedia.json'
          : 'sample_data_nomedia.json',
      builder: _buildContent,
      showToolbar: _edit == true,
      floatingActionButton: FloatingActionButton.extended(
        label: Text(_edit == true ? 'Done' : 'Edit'),
        onPressed: _toggleEdit,
        icon: Icon(_edit == true ? Icons.check : Icons.edit),
      ),
    );
  }

  Widget _buildContent(BuildContext context, QuillController? controller) {
    var quillEditor = QuillEditor(
      configurations: QuillEditorConfigurations(
        expands: false,
        padding: EdgeInsets.zero,
        embedBuilders: kIsWeb
            ? FlutterQuillEmbeds.editorWebBuilders()
            : FlutterQuillEmbeds.editorBuilders(),
        scrollable: true,
        autoFocus: true,
      ),
      scrollController: ScrollController(),
      focusNode: _focusNode,
      // readOnly: !_edit,
    );
    if (kIsWeb) {
      quillEditor = QuillEditor(
        configurations: QuillEditorConfigurations(
          autoFocus: true,
          expands: false,
          padding: EdgeInsets.zero,
          embedBuilders: FlutterQuillEmbeds.editorWebBuilders(),
          scrollable: true,
        ),
        scrollController: ScrollController(),
        focusNode: _focusNode,
      );
    }
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: const EdgeInsets.all(8),
      child: quillEditor,
    );
  }

  void _toggleEdit() {
    setState(() {
      _edit = !_edit;
    });
  }
}
