import 'package:flutter/material.dart';
import '../../raw_editor/builders/config/leading_configurations.dart';
import '../../style_widgets/style_widgets.dart';

Widget bulletPointLeading(LeadingConfigurations config) =>
    QuillEditorBulletPoint(
      style: config.style!,
      width: config.width!,
      padding: config.padding!,
    );
