import 'package:flutter/widgets.dart' show IconData, immutable;
import 'base.dart';

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
    this.iconSize,
    this.iconButtonFactor,
    super.afterButtonPressed,

    /// This will called on every select alignment button
    super.childBuilder,
    super.controller,
    super.iconTheme,
  });
  final double? iconSize;
  final double? iconButtonFactor;

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
