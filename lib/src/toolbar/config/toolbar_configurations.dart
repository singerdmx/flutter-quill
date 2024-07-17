import 'package:flutter/widgets.dart' show immutable;

import 'simple_toolbar_button_options.dart';
import 'toolbar_shared_configurations.dart';

@immutable
class QuillToolbarConfigurations extends QuillSharedToolbarProperties {
  const QuillToolbarConfigurations({
    super.sharedConfigurations,

    /// Note this only used when you using the quill toolbar buttons like
    /// `QuillToolbarHistoryButton` inside it
    super.buttonOptions = const QuillSimpleToolbarButtonOptions(),
  });

  @override
  List<Object?> get props => [];
}
