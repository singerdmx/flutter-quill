import 'package:flutter_quill/flutter_quill.dart'
    show Attribute, AttributeScope;

// class FlutterWidthAttribute extends Attribute<String?> {
//   const FlutterWidthAttribute(String? val)
//       : super('flutterWidth', AttributeScope.ignore, val);
// }

// class FlutterHeightAttribute extends Attribute<String?> {
//   const FlutterHeightAttribute(String? val)
//       : super('flutterHeight', AttributeScope.ignore, val);
// }

// class FlutterMarginAttribute extends Attribute<String?> {
//   const FlutterMarginAttribute(String? val)
//       : super('flutterMargin', AttributeScope.ignore, val);
// }

class FlutterAlignmentAttribute extends Attribute<String?> {
  const FlutterAlignmentAttribute(String? val)
      : super('flutterAlignment', AttributeScope.ignore, val);
}

extension AttributeExt on Attribute {
  // static const FlutterWidthAttribute flutterWidth = FlutterWidthAttribute(null);
  // static const FlutterHeightAttribute flutterHeight =
  //     FlutterHeightAttribute(null);
  // static const FlutterMarginAttribute flutterMargin =
  //     FlutterMarginAttribute(null);
  static const FlutterAlignmentAttribute flutterAlignment =
      FlutterAlignmentAttribute(null);
}
