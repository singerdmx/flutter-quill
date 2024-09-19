import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

// TODO: See the difference between Flutter MagnifierController and QuillMagnifierController
//    and document it.
@internal
@experimental
abstract class QuillMagnifierController {
  void showMagnifier(Offset positionToShow);

  void updateMagnifier(Offset positionToShow);

  void hideMagnifier();
}
