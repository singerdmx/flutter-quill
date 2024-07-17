// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/widgets.dart' show IconData, immutable;

import '../../../document/attribute.dart';
import '../base_button_configurations.dart';

class QuillToolbarSelectAlignmentButtonExtraOptions
    extends QuillToolbarBaseButtonExtraOptions {
  const QuillToolbarSelectAlignmentButtonExtraOptions({
    required super.controller,
    required super.context,
    required super.onPressed,
  });
}

class QuillToolbarSelectAlignmentButtonOptions
    extends QuillToolbarBaseButtonOptions<
        QuillToolbarSelectAlignmentButtonOptions,
        QuillToolbarBaseButtonExtraOptions> {
  const QuillToolbarSelectAlignmentButtonOptions({
    this.iconsData,
    this.tooltips,
    super.iconSize,
    super.iconButtonFactor,
    super.afterButtonPressed,

    /// This will called on every select alignment button
    super.childBuilder,
    super.iconTheme,
    this.attributes,
    this.showLeftAlignment = true,
    this.showCenterAlignment = true,
    this.showRightAlignment = true,
    this.showJustifyAlignment = true,
  });

  /// Default to
  /// const QuillToolbarSelectAlignmentValues(
  ///   leftAlignment: Icons.format_align_left,
  ///   centerAlignment: Icons.format_align_center,
  ///   rightAlignment: Icons.format_align_right,
  ///   justifyAlignment: Icons.format_align_justify,
  /// )
  final QuillSelectAlignmentValues<IconData>? iconsData;

  /// By default will use the localized tooltips
  final QuillSelectAlignmentValues<String>? tooltips;

  final List<Attribute>? attributes;

  final bool showLeftAlignment;
  final bool showCenterAlignment;
  final bool showRightAlignment;
  final bool showJustifyAlignment;

  QuillToolbarSelectAlignmentButtonOptions copyWith({
    QuillSelectAlignmentValues<IconData>? iconsData,
    QuillSelectAlignmentValues<String>? tooltips,
    List<Attribute>? attributes,
    bool? showLeftAlignment,
    bool? showCenterAlignment,
    bool? showRightAlignment,
    bool? showJustifyAlignment,
  }) {
    return QuillToolbarSelectAlignmentButtonOptions(
      iconsData: iconsData ?? this.iconsData,
      tooltips: tooltips ?? this.tooltips,
      attributes: attributes ?? this.attributes,
      showLeftAlignment: showLeftAlignment ?? this.showLeftAlignment,
      showCenterAlignment: showCenterAlignment ?? this.showCenterAlignment,
      showRightAlignment: showRightAlignment ?? this.showRightAlignment,
      showJustifyAlignment: showJustifyAlignment ?? this.showJustifyAlignment,
    );
  }
}

/// A helper class which hold all the values for the alignments of the
/// [QuillToolbarSelectAlignmentButtonOptions]
/// it's not really related to the toolbar so we called it just Quill without
/// toolbar but the name might change in the future
@immutable
class QuillSelectAlignmentValues<T> {
  const QuillSelectAlignmentValues({
    required this.leftAlignment,
    required this.centerAlignment,
    required this.rightAlignment,
    required this.justifyAlignment,
  });

  final T leftAlignment;
  final T centerAlignment;
  final T rightAlignment;
  final T justifyAlignment;
}
