import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter/material.dart' show Icons;

import '../../documents/attribute.dart';
import 'buttons/base.dart';
import 'buttons/font_family.dart';
import 'buttons/history.dart';

export './buttons/base.dart';
export './buttons/history.dart';
export './buttons/toggle_style.dart';

/// The default size of the icon of a button.
const double kDefaultIconSize = 18;

/// The default size for the toolbar (width, height)
const double defaultToolbarSize = kDefaultIconSize * 2;

/// The factor of how much larger the button is in relation to the icon.
const double kIconButtonFactor = 1.77;

/// The horizontal margin between the contents of each toolbar section.
const double kToolbarSectionSpacing = 4;

/// The configurations for the toolbar widget of flutter quill
@immutable
class QuillToolbarConfigurations {
  const QuillToolbarConfigurations({
    this.buttonOptions = const QuillToolbarButtonOptions(),
    this.multiRowsDisplay = true,
    this.fontFamilyValues,

    /// By default it will calculated based on the [baseOptions] iconSize
    /// You can change it but the the change only apply if
    /// the [multiRowsDisplay] is false, if [multiRowsDisplay] then the value
    /// will be [kDefaultIconSize] * 2
    double? toolbarSize,
  }) : _toolbarSize = toolbarSize;

  final double? _toolbarSize;

  /// The toolbar size, by default it will be `baseButtonOptions.iconSize * 2`
  double get toolbarSize {
    final alternativeToolbarSize = _toolbarSize;
    if (alternativeToolbarSize != null) {
      return alternativeToolbarSize;
    }
    return buttonOptions.baseButtonOptions.globalIconSize * 2;
  }

  /// If you want change spesefic buttons or all of them
  /// then you came to the right place
  final QuillToolbarButtonOptions buttonOptions;
  final bool multiRowsDisplay;

  /// By default will be final
  /// ```
  /// {
  ///   'Sans Serif': 'sans-serif',
  ///   'Serif': 'serif',
  ///   'Monospace': 'monospace',
  ///   'Ibarra Real Nova': 'ibarra-real-nova',
  ///   'SquarePeg': 'square-peg',
  ///   'Nunito': 'nunito',
  ///   'Pacifico': 'pacifico',
  ///   'Roboto Mono': 'roboto-mono',
  ///   'Clear'.i18n: 'Clear'
  /// };
  /// ```
  final Map<String, String>? fontFamilyValues;
}

/// The configurations for the buttons of the toolbar widget of flutter quill
@immutable
class QuillToolbarButtonOptions {
  const QuillToolbarButtonOptions({
    this.baseButtonOptions = const QuillToolbarBaseButtonOptions(),
    this.undoHistoryButtonOptions = const QuillToolbarHistoryButtonOptions(
      isUndo: true,
    ),
    this.redoHistoryButtonOptions = const QuillToolbarHistoryButtonOptions(
      isUndo: false,
    ),
    this.fontFamilyButtonOptions = const QuillToolbarFontFamilyButtonOptions(
      attribute: Attribute.font,
    ),
  });

  /// The base configurations for all the buttons
  final QuillToolbarBaseButtonOptions baseButtonOptions;
  final QuillToolbarHistoryButtonOptions undoHistoryButtonOptions;
  final QuillToolbarHistoryButtonOptions redoHistoryButtonOptions;
  final QuillToolbarFontFamilyButtonOptions fontFamilyButtonOptions;
}
