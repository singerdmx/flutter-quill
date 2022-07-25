import 'dart:collection';

import 'package:quiver/core.dart';

enum AttributeScope {
  INLINE, // refer to https://quilljs.com/docs/formats/#inline
  BLOCK, // refer to https://quilljs.com/docs/formats/#block
  EMBEDS, // refer to https://quilljs.com/docs/formats/#embeds
  IGNORE, // attributes that can be ignored
}

class Attribute<T> {
  const Attribute(this.key, this.scope, this.value);

  /// Unique key of this attribute.
  final String key;
  final AttributeScope scope;
  final T value;

  static final Map<String, Attribute> _registry = LinkedHashMap.of({
    Attribute.bold.key: Attribute.bold,
    Attribute.italic.key: Attribute.italic,
    Attribute.small.key: Attribute.small,
    Attribute.underline.key: Attribute.underline,
    Attribute.strikeThrough.key: Attribute.strikeThrough,
    Attribute.inlineCode.key: Attribute.inlineCode,
    Attribute.font.key: Attribute.font,
    Attribute.size.key: Attribute.size,
    Attribute.link.key: Attribute.link,
    Attribute.color.key: Attribute.color,
    Attribute.background.key: Attribute.background,
    Attribute.placeholder.key: Attribute.placeholder,
    Attribute.header.key: Attribute.header,
    Attribute.align.key: Attribute.align,
    Attribute.direction.key: Attribute.direction,
    Attribute.list.key: Attribute.list,
    Attribute.codeBlock.key: Attribute.codeBlock,
    Attribute.blockQuote.key: Attribute.blockQuote,
    Attribute.indent.key: Attribute.indent,
    Attribute.width.key: Attribute.width,
    Attribute.height.key: Attribute.height,
    Attribute.style.key: Attribute.style,
    Attribute.token.key: Attribute.token,
    Attribute.script.key: Attribute.script,
  });

  static const BoldAttribute bold = BoldAttribute();

  static const ItalicAttribute italic = ItalicAttribute();

  static const SmallAttribute small = SmallAttribute();

  static const UnderlineAttribute underline = UnderlineAttribute();

  static const StrikeThroughAttribute strikeThrough = StrikeThroughAttribute();

  static const InlineCodeAttribute inlineCode = InlineCodeAttribute();

  static const FontAttribute font = FontAttribute(null);

  static const SizeAttribute size = SizeAttribute(null);

  static const LinkAttribute link = LinkAttribute(null);

  static const ColorAttribute color = ColorAttribute(null);

  static const BackgroundAttribute background = BackgroundAttribute(null);

  static const PlaceholderAttribute placeholder = PlaceholderAttribute();

  static const HeaderAttribute header = HeaderAttribute();

  static const IndentAttribute indent = IndentAttribute();

  static const AlignAttribute align = AlignAttribute(null);

  static const ListAttribute list = ListAttribute(null);

  static const CodeBlockAttribute codeBlock = CodeBlockAttribute();

  static const BlockQuoteAttribute blockQuote = BlockQuoteAttribute();

  static const DirectionAttribute direction = DirectionAttribute(null);

  static const WidthAttribute width = WidthAttribute(null);

  static const HeightAttribute height = HeightAttribute(null);

  static const StyleAttribute style = StyleAttribute(null);

  static const TokenAttribute token = TokenAttribute('');

  static const ScriptAttribute script = ScriptAttribute('');

  static const String mobileWidth = 'mobileWidth';

  static const String mobileHeight = 'mobileHeight';

  static const String mobileMargin = 'mobileMargin';

  static const String mobileAlignment = 'mobileAlignment';

  static final Set<String> inlineKeys = {
    Attribute.bold.key,
    Attribute.italic.key,
    Attribute.small.key,
    Attribute.underline.key,
    Attribute.strikeThrough.key,
    Attribute.link.key,
    Attribute.color.key,
    Attribute.background.key,
    Attribute.placeholder.key,
  };

  static final Set<String> blockKeys = LinkedHashSet.of({
    Attribute.header.key,
    Attribute.align.key,
    Attribute.list.key,
    Attribute.codeBlock.key,
    Attribute.blockQuote.key,
    Attribute.indent.key,
    Attribute.direction.key,
  });

  static final Set<String> blockKeysExceptHeader = LinkedHashSet.of({
    Attribute.list.key,
    Attribute.align.key,
    Attribute.codeBlock.key,
    Attribute.blockQuote.key,
    Attribute.indent.key,
    Attribute.direction.key,
  });

  static final Set<String> exclusiveBlockKeys = LinkedHashSet.of({
    Attribute.header.key,
    Attribute.list.key,
    Attribute.codeBlock.key,
    Attribute.blockQuote.key,
  });

  static const Attribute<int?> h1 = HeaderAttribute(level: 1);

  static const Attribute<int?> h2 = HeaderAttribute(level: 2);

  static const Attribute<int?> h3 = HeaderAttribute(level: 3);

  // "attributes":{"align":"left"}
  static const Attribute<String?> leftAlignment = AlignAttribute('left');

  // "attributes":{"align":"center"}
  static const Attribute<String?> centerAlignment = AlignAttribute('center');

  // "attributes":{"align":"right"}
  static const Attribute<String?> rightAlignment = AlignAttribute('right');

  // "attributes":{"align":"justify"}
  static const Attribute<String?> justifyAlignment = AlignAttribute('justify');

  // "attributes":{"list":"bullet"}
  static const Attribute<String?> ul = ListAttribute('bullet');

  // "attributes":{"list":"ordered"}
  static const Attribute<String?> ol = ListAttribute('ordered');

  // "attributes":{"list":"checked"}
  static const Attribute<String?> checked = ListAttribute('checked');

  // "attributes":{"list":"unchecked"}
  static const Attribute<String?> unchecked = ListAttribute('unchecked');

  // "attributes":{"direction":"rtl"}
  static const Attribute<String?> rtl = DirectionAttribute('rtl');

  // "attributes":{"indent":1"}
  static const Attribute<int?> indentL1 = IndentAttribute(level: 1);

  // "attributes":{"indent":2"}
  static const Attribute<int?> indentL2 = IndentAttribute(level: 2);

  // "attributes":{"indent":3"}
  static const Attribute<int?> indentL3 = IndentAttribute(level: 3);

  static Attribute<int?> getIndentLevel(int? level) {
    if (level == 1) {
      return indentL1;
    }
    if (level == 2) {
      return indentL2;
    }
    if (level == 3) {
      return indentL3;
    }
    return IndentAttribute(level: level);
  }

  bool get isInline => scope == AttributeScope.INLINE;

  bool get isBlockExceptHeader => blockKeysExceptHeader.contains(key);

  Map<String, dynamic> toJson() => <String, dynamic>{key: value};

  static Attribute? fromKeyValue(String key, dynamic value) {
    final origin = _registry[key];
    if (origin == null) {
      return null;
    }
    final attribute = clone(origin, value);
    return attribute;
  }

  static int getRegistryOrder(Attribute attribute) {
    var order = 0;
    for (final attr in _registry.values) {
      if (attr.key == attribute.key) {
        break;
      }
      order++;
    }

    return order;
  }

  static Attribute clone(Attribute origin, dynamic value) {
    return Attribute(origin.key, origin.scope, value);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Attribute) return false;
    final typedOther = other;
    return key == typedOther.key &&
        scope == typedOther.scope &&
        value == typedOther.value;
  }

  @override
  int get hashCode => hash3(key, scope, value);

  @override
  String toString() {
    return 'Attribute{key: $key, scope: $scope, value: $value}';
  }
}

class BoldAttribute extends Attribute<bool> {
  const BoldAttribute() : super('bold', AttributeScope.INLINE, true);
}

class ItalicAttribute extends Attribute<bool> {
  const ItalicAttribute() : super('italic', AttributeScope.INLINE, true);
}

class SmallAttribute extends Attribute<bool> {
  const SmallAttribute() : super('small', AttributeScope.INLINE, true);
}

class UnderlineAttribute extends Attribute<bool> {
  const UnderlineAttribute() : super('underline', AttributeScope.INLINE, true);
}

class StrikeThroughAttribute extends Attribute<bool> {
  const StrikeThroughAttribute() : super('strike', AttributeScope.INLINE, true);
}

class InlineCodeAttribute extends Attribute<bool> {
  const InlineCodeAttribute() : super('code', AttributeScope.INLINE, true);
}

class FontAttribute extends Attribute<String?> {
  const FontAttribute(String? val) : super('font', AttributeScope.INLINE, val);
}

class SizeAttribute extends Attribute<String?> {
  const SizeAttribute(String? val) : super('size', AttributeScope.INLINE, val);
}

class LinkAttribute extends Attribute<String?> {
  const LinkAttribute(String? val) : super('link', AttributeScope.INLINE, val);
}

class ColorAttribute extends Attribute<String?> {
  const ColorAttribute(String? val)
      : super('color', AttributeScope.INLINE, val);
}

class BackgroundAttribute extends Attribute<String?> {
  const BackgroundAttribute(String? val)
      : super('background', AttributeScope.INLINE, val);
}

/// This is custom attribute for hint
class PlaceholderAttribute extends Attribute<bool> {
  const PlaceholderAttribute()
      : super('placeholder', AttributeScope.INLINE, true);
}

class HeaderAttribute extends Attribute<int?> {
  const HeaderAttribute({int? level})
      : super('header', AttributeScope.BLOCK, level);
}

class IndentAttribute extends Attribute<int?> {
  const IndentAttribute({int? level})
      : super('indent', AttributeScope.BLOCK, level);
}

class AlignAttribute extends Attribute<String?> {
  const AlignAttribute(String? val) : super('align', AttributeScope.BLOCK, val);
}

class ListAttribute extends Attribute<String?> {
  const ListAttribute(String? val) : super('list', AttributeScope.BLOCK, val);
}

class CodeBlockAttribute extends Attribute<bool> {
  const CodeBlockAttribute() : super('code-block', AttributeScope.BLOCK, true);
}

class BlockQuoteAttribute extends Attribute<bool> {
  const BlockQuoteAttribute() : super('blockquote', AttributeScope.BLOCK, true);
}

class DirectionAttribute extends Attribute<String?> {
  const DirectionAttribute(String? val)
      : super('direction', AttributeScope.BLOCK, val);
}

class WidthAttribute extends Attribute<String?> {
  const WidthAttribute(String? val)
      : super('width', AttributeScope.IGNORE, val);
}

class HeightAttribute extends Attribute<String?> {
  const HeightAttribute(String? val)
      : super('height', AttributeScope.IGNORE, val);
}

class StyleAttribute extends Attribute<String?> {
  const StyleAttribute(String? val)
      : super('style', AttributeScope.IGNORE, val);
}

class TokenAttribute extends Attribute<String> {
  const TokenAttribute(String val) : super('token', AttributeScope.IGNORE, val);
}

// `script` is supposed to be inline attribute but it is not supported yet
class ScriptAttribute extends Attribute<String> {
  const ScriptAttribute(String val)
      : super('script', AttributeScope.IGNORE, val);
}
