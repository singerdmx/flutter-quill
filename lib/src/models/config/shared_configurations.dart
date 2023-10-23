import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart' show Color, Colors, Locale;

import './editor/configurations.dart' show QuillEditorConfigurations;
import './toolbar/configurations.dart' show QuillToolbarConfigurations;
import '../themes/quill_dialog_theme.dart';
import 'others/animations.dart';

export './others/animations.dart';

/// The shared configurations between [QuillEditorConfigurations] and
/// [QuillToolbarConfigurations] so we don't duplicate things
class QuillSharedConfigurations extends Equatable {
  const QuillSharedConfigurations({
    this.dialogBarrierColor = Colors.black54,
    this.dialogTheme,
    this.locale,
    this.animationConfigurations = const QuillAnimationConfigurations(
      checkBoxPointItem: false,
    ),
  });

  // This is just example or showcase of this major update to make the library
  // more maintanable, flexible, and customizable
  /// The barrier color of the shown dialogs
  final Color dialogBarrierColor;

  /// The default dialog theme for all the dialogs for quill editor and
  /// quill toolbar
  final QuillDialogTheme? dialogTheme;

  /// The locale to use for the editor and toolbar, defaults to system locale
  /// More https://github.com/singerdmx/flutter-quill#translation
  final Locale? locale;

  /// To configure which animations you want to be enabled
  final QuillAnimationConfigurations animationConfigurations;

  @override
  List<Object?> get props => [
        dialogBarrierColor,
        dialogTheme,
        locale,
        animationConfigurations,
      ];
}
