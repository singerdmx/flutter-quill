import 'package:flutter/widgets.dart'
    show Axis, WrapAlignment, WrapCrossAlignment, immutable;

import '../../../widgets/toolbar/base_toolbar.dart';
import 'toolbar_shared_configurations.dart';

@immutable
class QuillBaseToolbarConfigurations extends QuillSharedToolbarProperties {
  const QuillBaseToolbarConfigurations({
    required this.childrenBuilder,
    super.axis = Axis.horizontal,
    super.toolbarSize = kDefaultIconSize * 2,
    super.toolbarSectionSpacing = kToolbarSectionSpacing,
    super.toolbarIconAlignment = WrapAlignment.center,
    super.toolbarIconCrossAlignment = WrapCrossAlignment.center,
    super.color,
    super.customButtons = const [],
    super.sectionDividerColor,
    super.sectionDividerSpace,
    super.linkDialogAction,
    super.multiRowsDisplay = true,
    super.decoration,

    /// Note this only used when you using the quill toolbar buttons like
    /// `QuillToolbarHistoryButton` inside it
    super.buttonOptions = const QuillToolbarButtonOptions(),
  });

  final QuillBaseToolbarChildrenBuilder childrenBuilder;

  @override
  List<Object?> get props => [];
}
