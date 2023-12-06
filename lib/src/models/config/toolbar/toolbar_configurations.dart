// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/widgets.dart' show Widget, immutable;

import '../../../widgets/toolbar/base_toolbar.dart';
import 'toolbar_shared_configurations.dart';

@immutable
class QuillToolbarConfigurations extends QuillSharedToolbarProperties {
  const QuillToolbarConfigurations({
    required this.child,
    super.sharedConfigurations,

    /// Note this only used when you using the quill toolbar buttons like
    /// `QuillToolbarHistoryButton` inside it
    super.buttonOptions = const QuillToolbarButtonOptions(),
  });

  final Widget child;

  @override
  List<Object?> get props => [];
}
