import 'package:flutter/material.dart';
import '../../raw_editor/builders/leading_block_builder.dart';
import '../../style_widgets/style_widgets.dart';

Widget checkboxLeading(LeadingConfigurations config) =>
    QuillEditorCheckboxPoint(
      size: config.lineSize!,
      value: config.value,
      enabled: config.enabled!,
      onChanged: config.onCheckboxTap,
      uiBuilder: config.uiBuilder,
    );
