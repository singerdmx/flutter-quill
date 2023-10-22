import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart' show immutable;

import '../../../utils/experimental.dart';

@immutable
@Experimental('This class might removed')
class QuillAnimationConfigurations extends Equatable {
  const QuillAnimationConfigurations({
    required this.checkBoxPointItem,
  });

  factory QuillAnimationConfigurations.disableAll() =>
      const QuillAnimationConfigurations(
        checkBoxPointItem: false,
      );

  factory QuillAnimationConfigurations.enableAll() =>
      const QuillAnimationConfigurations(
        checkBoxPointItem: true,
      );

  /// This currently has issue which the whole checkbox list will rebuilt
  /// and the animation will replay when some value changes
  /// which is why disabled by default
  final bool checkBoxPointItem;

  @override
  List<Object?> get props => [];
}
