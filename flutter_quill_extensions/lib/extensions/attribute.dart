import 'package:flutter_quill/flutter_quill.dart'
    show Attribute, AttributeScope;

class MobileWidthAttribute extends Attribute<String?> {
  const MobileWidthAttribute(String? val)
      : super('mobileWidth', AttributeScope.ignore, val);
}

class MobileHeightAttribute extends Attribute<String?> {
  const MobileHeightAttribute(String? val)
      : super('mobileHeight', AttributeScope.ignore, val);
}

class MobileMarginAttribute extends Attribute<String?> {
  const MobileMarginAttribute(String? val)
      : super('mobileMargin', AttributeScope.ignore, val);
}

class MobileAlignmentAttribute extends Attribute<String?> {
  const MobileAlignmentAttribute(String? val)
      : super('mobileAlignment', AttributeScope.ignore, val);
}

extension AttributeExt on Attribute {
  static const MobileWidthAttribute mobileWidth = MobileWidthAttribute(null);
  static const MobileHeightAttribute mobileHeight = MobileHeightAttribute(null);
  static const MobileMarginAttribute mobileMargin = MobileMarginAttribute(null);
  static const MobileAlignmentAttribute mobileAlignment =
      MobileAlignmentAttribute(null);
}
