import 'package:flutter/material.dart';
import '../../../document/nodes/node.dart';
import '../../widgets/text/text_line.dart';
import 'config/leading_configurations.dart';
import 'inline_builder_configurations.dart';

typedef LeadingBlockNodeBuilder = Widget? Function(Node, LeadingConfigurations);
typedef TextLineNodeBuilder = Widget? Function(
    Node, TextLine, InlineBuilderConfiguration);
