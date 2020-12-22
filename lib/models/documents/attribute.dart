import 'package:quiver_hashcode/hashcode.dart';

enum AttributeScope {
  INLINE, // refer to https://quilljs.com/docs/formats/#inline
  BLOCK, // refer to https://quilljs.com/docs/formats/#block
  EMBEDS, // refer to https://quilljs.com/docs/formats/#embeds
}

class Attribute<T> {
  final String key;
  final AttributeScope scope;
  T _value;

  Attribute(this.key, this.scope, this._value);

  T getValue() => _value;
  setValue(T val) => _value = val;

  static final Map<String, Attribute> _registry = {
    Attribute.bold.key: Attribute.bold,
    Attribute.italic.key: Attribute.italic,
    Attribute.underline.key: Attribute.underline,
    Attribute.strikeThrough.key: Attribute.strikeThrough,
    Attribute.link.key: Attribute.link,
    Attribute.header.key: Attribute.header,
    Attribute.list.key: Attribute.list,
    Attribute.codeBlock.key: Attribute.codeBlock,
    Attribute.blockQuote.key: Attribute.blockQuote,
  };

  static final BoldAttribute bold = BoldAttribute();

  static final ItalicAttribute italic = ItalicAttribute();

  static final UnderlineAttribute underline = UnderlineAttribute();

  static final StrikeThroughAttribute strikeThrough = StrikeThroughAttribute();

  static final LinkAttribute link = LinkAttribute(null);

  static final HeaderAttribute header = HeaderAttribute();

  static final ListAttribute list = ListAttribute(null);

  static final CodeBlockAttribute codeBlock = CodeBlockAttribute();

  static final BlockQuoteAttribute blockQuote = BlockQuoteAttribute();

  static Attribute<int> get h1 => HeaderAttribute(level: 1);

  static Attribute<int> get h2 => HeaderAttribute(level: 2);

  static Attribute<int> get h3 => HeaderAttribute(level: 3);

  // "attributes":{"list":"bullet"}
  static Attribute<String> get ul => ListAttribute('bullet');

  // "attributes":{"list":"ordered"}
  static Attribute<String> get ol => ListAttribute('ordered');

  bool get isInline => scope == AttributeScope.INLINE;

  bool get isBlockExceptHeader =>
      scope == AttributeScope.BLOCK && key != Attribute.header.key;

  Map<String, dynamic> toJson() => <String, dynamic>{key: _value};

  static Attribute fromKeyValue(String key, dynamic value) {
    if (!_registry.containsKey(key)) {
      throw ArgumentError.value(key, 'key "$key" not found.');
    }
    Attribute origin = _registry[key];
    Attribute attribute = clone(origin);
    if (value != null) {
      attribute.setValue(value);
    }
    return attribute;
  }
  
  static Attribute clone(Attribute origin) {
    return Attribute(origin.key, origin.scope, origin.getValue());
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Attribute<T>) return false;
    Attribute<T> typedOther = other;
    return key == typedOther.key &&
        scope == typedOther.scope &&
        _value == typedOther._value;
  }

  @override
  int get hashCode => hash3(key, scope, _value);

  @override
  String toString() {
    return 'Attribute{key: $key, scope: $scope, value: $_value}';
  }
}

class BoldAttribute extends Attribute<bool> {
  BoldAttribute() : super('bold', AttributeScope.INLINE, true);
}

class ItalicAttribute extends Attribute<bool> {
  ItalicAttribute() : super('italic', AttributeScope.INLINE, true);
}

class UnderlineAttribute extends Attribute<bool> {
  UnderlineAttribute() : super('underline', AttributeScope.INLINE, true);
}

class StrikeThroughAttribute extends Attribute<bool> {
  StrikeThroughAttribute() : super('strike', AttributeScope.INLINE, true);
}

class LinkAttribute extends Attribute<String> {
  LinkAttribute(String val) : super('link', AttributeScope.INLINE, val);
}

class HeaderAttribute extends Attribute<int> {
  HeaderAttribute({int level}) : super('header', AttributeScope.BLOCK, level);
}

class ListAttribute extends Attribute<String> {
  ListAttribute(String val) : super('list', AttributeScope.BLOCK, val);
}

class CodeBlockAttribute extends Attribute<bool> {
  CodeBlockAttribute() : super('code-block', AttributeScope.BLOCK, true);
}

class BlockQuoteAttribute extends Attribute<bool> {
  BlockQuoteAttribute() : super('blockquote', AttributeScope.BLOCK, true);
}
