import 'package:flutter/material.dart';
import '../../../../document/nodes/node.dart';
import '../../../widgets/default_styles.dart';
import '../../../widgets/delegate.dart';

/// The base class for the configurations of the custom nodes builders
abstract class BaseBuilderConfiguration<T extends Node> {
  BaseBuilderConfiguration({
    required this.textDirection,
    required this.node,
    required this.customRecognizerBuilder,
    required this.customStyleBuilder,
    required this.customLinkPrefixes,
    required this.readOnly,
    required this.styles,
  });

  final TextDirection textDirection;
  final T node;
  final CustomRecognizerBuilder? customRecognizerBuilder;
  final CustomStyleBuilder? customStyleBuilder;
  final List<String> customLinkPrefixes;
  final bool readOnly;
  final DefaultStyles? styles;
}
