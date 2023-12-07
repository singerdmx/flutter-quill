import 'package:flutter/widgets.dart' show immutable;

import '../../../widgets/toolbar/base_toolbar.dart';
import 'toolbar_shared_configurations.dart';

@immutable
class QuillToolbarConfigurations extends QuillSharedToolbarProperties {
  const QuillToolbarConfigurations({
    super.sharedConfigurations,

    /// Note this only used when you using the quill toolbar buttons like
    /// `QuillToolbarHistoryButton` inside it
    super.buttonOptions = const QuillToolbarButtonOptions(),
  });

  @override
  List<Object?> get props => [];
}
