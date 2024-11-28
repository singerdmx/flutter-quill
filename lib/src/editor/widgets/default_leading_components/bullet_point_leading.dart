import 'package:flutter/material.dart';
import '../../raw_editor/builders/leading_block_builder.dart';
import '../../style_widgets/style_widgets.dart';

Widget bulletPointLeading(LeadingConfig config) => QuillBulletPoint(
      style: config.style!,
      width: config.width!,
      padding: config.padding!,
    );
