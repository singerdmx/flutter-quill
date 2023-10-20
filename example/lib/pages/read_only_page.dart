import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/extensions.dart';
import 'package:flutter_quill/flutter_quill.dart' hide QuillText;
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';

import '../universal_ui/universal_ui.dart';
import '../widgets/demo_scaffold.dart';

class ReadOnlyPage extends StatefulWidget {
  @override
  _ReadOnlyPageState createState() => _ReadOnlyPageState();
}

class _ReadOnlyPageState extends State<ReadOnlyPage> {
  final FocusNode _focusNode = FocusNode();

  bool _edit = false;

  @override
  Widget build(BuildContext context) {
    return DemoScaffold(
      documentFilename: isDesktop()
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
      scrollController: ScrollController(),
      scrollable: true,
      focusNode: _focusNode,
      autoFocus: true,
      readOnly: !_edit,
      expands: false,
      padding: EdgeInsets.zero,
      embedBuilders: FlutterQuillEmbeds.builders(),
    );
    if (kIsWeb) {
      quillEditor = QuillEditor(
          scrollController: ScrollController(),
          scrollable: true,
          focusNode: _focusNode,
          autoFocus: true,
          readOnly: !_edit,
          expands: false,
          padding: EdgeInsets.zero,
          embedBuilders: defaultEmbedBuildersWeb);
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

  void _toggleEdit() {
    setState(() {
      _edit = !_edit;
    });
  }
}
