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

extension AttributeExt on Attribute {}
