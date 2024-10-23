import 'package:flutter_quill/flutter_quill.dart'
    show Attribute, AttributeScope;

class FlutterAlignmentAttribute extends Attribute<String?> {
  const FlutterAlignmentAttribute(String? val)
      : super('flutterAlignment', AttributeScope.ignore, val);
}

extension AttributeExt on Attribute {
  static const FlutterAlignmentAttribute flutterAlignment =
      FlutterAlignmentAttribute(null);
}
