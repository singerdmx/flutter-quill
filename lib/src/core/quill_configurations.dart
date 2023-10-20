import 'package:flutter/foundation.dart' show immutable;

import '../../flutter_quill.dart';

@immutable
class QuillConfigurations {
  const QuillConfigurations({
    required this.controller,
  });

  final QuillController controller;
}
