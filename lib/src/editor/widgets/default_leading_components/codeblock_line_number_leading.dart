import 'package:flutter/material.dart';
import '../../raw_editor/builders/leading_block_builder.dart';
import '../../style_widgets/style_widgets.dart';

Widget codeBlockLineNumberLeading(LeadingConfigurations config) =>
    QuillEditorNumberPoint(
      index: config.getIndexNumberByIndent!,
      indentLevelCounts: config.indentLevelCounts,
      count: config.count,
      style: config.style!,
      attrs: config.attrs,
      width: config.width!,
      padding: config.padding!,
    );
