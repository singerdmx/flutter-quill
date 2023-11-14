import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

class TestingHomePage extends StatelessWidget {
  const TestingHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: QuillToolbar(),
    );
  }
}
