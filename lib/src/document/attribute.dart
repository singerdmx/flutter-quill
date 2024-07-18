import 'dart:collection' show LinkedHashSet, LinkedHashMap;

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart' show immutable;
import 'package:quiver/core.dart';

import 'custom_attributes.dart';
export 'custom_attributes.dart';

enum AttributeScope {
  inline, // refer to https://quilljs.com/docs/formats/#inline
  block, // refer to https://quilljs.com/docs/formats/#block
  embeds, // refer to https://quilljs.com/docs/formats/#embeds
  ignore, // attributes that can be ignored
}

@immutable
class Attribute<T> extends Equatable {
  const Attribute(
    this.key,
    this.scope,
    this.value,
  );

  /// Unique key of this attribute.
  final String key;
  final AttributeScope scope;
  final T value;

  static final Map<String, Attribute> _registry = LinkedHashMap.of({
    Attribute.bold.key: Attribute.bold,
    Attribute.subscript.key: Attribute.subscript,
    Attribute.superscript.key: Attribute.superscript,
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
    Attribute.lineHeight.key: Attribute.lineHeight,
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
    Attribute.image.key: Attribute.image,
    Attribute.video.key: Attribute.video,
  });

  static const BoldAttribute bold = BoldAttribute();

  static final ScriptAttribute subscript =
      ScriptAttribute(ScriptAttributes.sub);

  static final ScriptAttribute superscript =
      ScriptAttribute(ScriptAttributes.sup);

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

  static const LineHeightAttribute lineHeight = LineHeightAttribute();

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

  static final ScriptAttribute script = ScriptAttribute(null);

  static const ImageAttribute image = ImageAttribute(null);

  static const VideoAttribute video = VideoAttribute(null);

  static final registeredAttributeKeys = Set.unmodifiable(_registry.keys);

  static final inlineKeys = Set.unmodifiable(<String>{
    Attribute.bold.key,
    Attribute.subscript.key,
    Attribute.superscript.key,
    Attribute.italic.key,
    Attribute.small.key,
    Attribute.underline.key,
    Attribute.strikeThrough.key,
    Attribute.link.key,
    Attribute.color.key,
    Attribute.background.key,
    Attribute.placeholder.key,
    Attribute.font.key,
    Attribute.size.key,
    Attribute.inlineCode.key,
  });

  static final ignoreKeys = Set.unmodifiable(<String>{
    Attribute.width.key,
    Attribute.height.key,
    Attribute.style.key,
    Attribute.token.key,
  });

  static final Set<String> blockKeys = LinkedHashSet.of({
    Attribute.header.key,
    Attribute.align.key,
    Attribute.list.key,
    Attribute.codeBlock.key,
    Attribute.blockQuote.key,
    Attribute.indent.key,
    Attribute.direction.key,
    Attribute.lineHeight.key,
  });

  static final Set<String> blockKeysExceptHeader = LinkedHashSet.of({
    Attribute.list.key,
    Attribute.align.key,
    Attribute.codeBlock.key,
    Attribute.blockQuote.key,
    Attribute.lineHeight.key,
    Attribute.indent.key,
    Attribute.direction.key,
  });

  static final Set<String> exclusiveBlockKeys = LinkedHashSet.of({
    Attribute.header.key,
    Attribute.list.key,
    Attribute.codeBlock.key,
    Attribute.blockQuote.key,
  });

  static final Set<String> embedKeys = {
    Attribute.image.key,
    Attribute.video.key,
  };

  /// "attributes":{"header": 1 }
  static const Attribute<int?> h1 = HeaderAttribute(level: 1);

  /// "attributes":{"header": 2 }
  static const Attribute<int?> h2 = HeaderAttribute(level: 2);

  /// "attributes":{"header": 3 }
  static const Attribute<int?> h3 = HeaderAttribute(level: 3);

  /// "attributes":{"header": 4 }
  static const Attribute<int?> h4 = HeaderAttribute(level: 4);

  /// "attributes":{"header": 5 }
  static const Attribute<int?> h5 = HeaderAttribute(level: 5);

  /// "attributes":{"header": 6 }
  static const Attribute<int?> h6 = HeaderAttribute(level: 6);

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

  bool get isInline => scope == AttributeScope.inline;

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

  // This might not needed anymore because of equatable
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Attribute) return false;
    final typedOther = other;
    return key == typedOther.key &&
        scope == typedOther.scope &&
        value == typedOther.value;
  }

  // This might not needed anymore because of equatable
  @override
  int get hashCode => hash3(key, scope, value);

  @override
  String toString() {
    return 'Attribute{key: $key, scope: $scope, value: $value}';
  }

  @override
  List<Object?> get props => [key, scope, value];
}

class BoldAttribute extends Attribute<bool> {
  const BoldAttribute() : super('bold', AttributeScope.inline, true);
}

class ItalicAttribute extends Attribute<bool> {
  const ItalicAttribute() : super('italic', AttributeScope.inline, true);
}

class SmallAttribute extends Attribute<bool> {
  const SmallAttribute() : super('small', AttributeScope.inline, true);
}

class UnderlineAttribute extends Attribute<bool> {
  const UnderlineAttribute() : super('underline', AttributeScope.inline, true);
}

class StrikeThroughAttribute extends Attribute<bool> {
  const StrikeThroughAttribute() : super('strike', AttributeScope.inline, true);
}

class InlineCodeAttribute extends Attribute<bool> {
  const InlineCodeAttribute() : super('code', AttributeScope.inline, true);
}

class FontAttribute extends Attribute<String?> {
  const FontAttribute(String? val) : super('font', AttributeScope.inline, val);
}

class SizeAttribute extends Attribute<String?> {
  const SizeAttribute(String? val) : super('size', AttributeScope.inline, val);
}

class LinkAttribute extends Attribute<String?> {
  const LinkAttribute(String? val) : super('link', AttributeScope.inline, val);
}

class ColorAttribute extends Attribute<String?> {
  const ColorAttribute(String? val)
      : super('color', AttributeScope.inline, val);
}

class BackgroundAttribute extends Attribute<String?> {
  const BackgroundAttribute(String? val)
      : super('background', AttributeScope.inline, val);
}

/// This is custom attribute for hint
class PlaceholderAttribute extends Attribute<bool> {
  const PlaceholderAttribute()
      : super('placeholder', AttributeScope.inline, true);
}

class HeaderAttribute extends Attribute<int?> {
  const HeaderAttribute({int? level})
      : super('header', AttributeScope.block, level);
}

class IndentAttribute extends Attribute<int?> {
  const IndentAttribute({int? level})
      : super('indent', AttributeScope.block, level);
}

class AlignAttribute extends Attribute<String?> {
  const AlignAttribute(String? val) : super('align', AttributeScope.block, val);
}

class ListAttribute extends Attribute<String?> {
  const ListAttribute(String? val) : super('list', AttributeScope.block, val);
}

class CodeBlockAttribute extends Attribute<bool> {
  const CodeBlockAttribute() : super('code-block', AttributeScope.block, true);
}

class BlockQuoteAttribute extends Attribute<bool> {
  const BlockQuoteAttribute() : super('blockquote', AttributeScope.block, true);
}

class DirectionAttribute extends Attribute<String?> {
  const DirectionAttribute(String? val)
      : super('direction', AttributeScope.block, val);
}

class WidthAttribute extends Attribute<String?> {
  const WidthAttribute(String? val)
      : super('width', AttributeScope.ignore, val);
}

class HeightAttribute extends Attribute<String?> {
  const HeightAttribute(String? val)
      : super('height', AttributeScope.ignore, val);
}

class StyleAttribute extends Attribute<String?> {
  const StyleAttribute(String? val)
      : super('style', AttributeScope.ignore, val);
}

class TokenAttribute extends Attribute<String> {
  const TokenAttribute(String val) : super('token', AttributeScope.ignore, val);
}

class ScriptAttribute extends Attribute<String?> {
  ScriptAttribute(ScriptAttributes? val)
      : super('script', AttributeScope.inline, val?.value);
}

enum ScriptAttributes {
  sup('super'),
  sub('sub');

  const ScriptAttributes(this.value);

  final String value;
}

class ImageAttribute extends Attribute<String?> {
  const ImageAttribute(String? url)
      : super('image', AttributeScope.embeds, url);
}

class VideoAttribute extends Attribute<String?> {
  const VideoAttribute(String? url)
      : super('video', AttributeScope.embeds, url);
}
