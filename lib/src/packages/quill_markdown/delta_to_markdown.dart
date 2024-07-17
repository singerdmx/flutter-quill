import 'dart:convert';
import 'dart:ui';

import 'package:collection/collection.dart' show IterableExtension;

import '../../../quill_delta.dart';
import '../../document/attribute.dart';
import '../../document/document.dart';
import '../../document/nodes/block.dart';
import '../../document/nodes/embeddable.dart';
import '../../document/nodes/leaf.dart';
import '../../document/nodes/line.dart';
import '../../document/nodes/node.dart';
import './custom_quill_attributes.dart';
import './utils.dart';

class _AttributeHandler {
  _AttributeHandler({
    this.beforeContent,
    this.afterContent,
  });

  final void Function(
    Attribute<Object?> attribute,
    Node node,
    StringSink output,
  )? beforeContent;

  final void Function(
    Attribute<Object?> attribute,
    Node node,
    StringSink output,
  )? afterContent;
}

/// Outputs [Embed] element as markdown.
typedef EmbedToMarkdown = void Function(Embed embed, StringSink out);

extension on Object? {
  T? asNullable<T>() {
    final self = this;
    return self == null ? null : self as T;
  }
}

/// Convertor from [Delta] to quill Markdown string.
class DeltaToMarkdown extends Converter<Delta, String>
    implements _NodeVisitor<StringSink> {
  ///
  DeltaToMarkdown({
    Map<String, EmbedToMarkdown>? customEmbedHandlers,
  }) {
    if (customEmbedHandlers != null) {
      _embedHandlers.addAll(customEmbedHandlers);
    }
  }

  @override
  String convert(Delta input) {
    final newDelta = transform(input);

    final quillDocument = Document.fromDelta(newDelta);

    final outBuffer = quillDocument.root.accept(this);

    return outBuffer.toString();
  }

  final Map<String, _AttributeHandler> _blockAttrsHandlers = {
    Attribute.codeBlock.key: _AttributeHandler(
      beforeContent: (attribute, node, output) {
        var infoString = '';
        if (node.containsAttr(CodeBlockLanguageAttribute.attrKey)) {
          infoString = node.getAttrValueOr(
            CodeBlockLanguageAttribute.attrKey,
            '',
          );
        }
        if (infoString.isEmpty) {
          final linesWithLang = (node as Block).children.where((child) =>
              child.containsAttr(CodeBlockLanguageAttribute.attrKey));
          if (linesWithLang.isNotEmpty) {
            infoString = linesWithLang.first.getAttrValueOr(
              CodeBlockLanguageAttribute.attrKey,
              'or',
            );
          }
        }

        output.writeln('```$infoString');
      },
      afterContent: (attribute, node, output) => output.writeln('```'),
    ),
  };

  final Map<String, _AttributeHandler> _lineAttrsHandlers = {
    Attribute.header.key: _AttributeHandler(
      beforeContent: (attribute, node, output) {
        output
          ..write('#' * (attribute.value.asNullable<int>() ?? 1))
          ..write(' ');
      },
    ),
    Attribute.blockQuote.key: _AttributeHandler(
      beforeContent: (attribute, node, output) => output.write('> '),
    ),
    Attribute.list.key: _AttributeHandler(
      beforeContent: (attribute, node, output) {
        final indentLevel = node.getAttrValueOr(Attribute.indent.key, 0);
        final isNumbered = attribute.value == 'ordered';
        output
          ..write((isNumbered ? '   ' : '  ') * indentLevel)
          ..write('${isNumbered ? '1.' : '-'} ');
      },
    ),
  };

  final Map<String, _AttributeHandler> _textAttrsHandlers = {
    Attribute.italic.key: _AttributeHandler(
      beforeContent: (attribute, node, output) {
        if (node.previous?.containsAttr(attribute.key) != true) {
          output.write('_');
        }
      },
      afterContent: (attribute, node, output) {
        if (node.next?.containsAttr(attribute.key) != true) {
          output.write('_');
        }
      },
    ),
    Attribute.bold.key: _AttributeHandler(
      beforeContent: (attribute, node, output) {
        if (node.previous?.containsAttr(attribute.key) != true) {
          output.write('**');
        }
      },
      afterContent: (attribute, node, output) {
        if (node.next?.containsAttr(attribute.key) != true) {
          output.write('**');
        }
      },
    ),
    Attribute.strikeThrough.key: _AttributeHandler(
      beforeContent: (attribute, node, output) {
        if (node.previous?.containsAttr(attribute.key) != true) {
          output.write('~~');
        }
      },
      afterContent: (attribute, node, output) {
        if (node.next?.containsAttr(attribute.key) != true) {
          output.write('~~');
        }
      },
    ),
    Attribute.inlineCode.key: _AttributeHandler(
      beforeContent: (attribute, node, output) {
        if (node.previous?.containsAttr(attribute.key) != true) {
          output.write('`');
        }
      },
      afterContent: (attribute, node, output) {
        if (node.next?.containsAttr(attribute.key) != true) {
          output.write('`');
        }
      },
    ),
    Attribute.link.key: _AttributeHandler(
      beforeContent: (attribute, node, output) {
        if (node.previous?.containsAttr(attribute.key, attribute.value) !=
            true) {
          output.write('[');
        }
      },
      afterContent: (attribute, node, output) {
        if (node.next?.containsAttr(attribute.key, attribute.value) != true) {
          output.write('](${attribute.value.asNullable<String>() ?? ''})');
        }
      },
    ),
  };

  final Map<String, EmbedToMarkdown> _embedHandlers = {
    BlockEmbed.imageType: (embed, out) => out.write('![](${embed.value.data})'),
    horizontalRuleType: (embed, out) {
      // adds new line after it
      // make --- separated so it doesn't get rendered as header
      out.writeln('- - -');
    },
  };

  @override
  StringSink visitRoot(Root root, [StringSink? output]) {
    final out = output ??= StringBuffer();
    for (final container in root.children) {
      container.accept(this, out);
    }
    return out;
  }

  @override
  StringSink visitBlock(Block block, [StringSink? output]) {
    final out = output ??= StringBuffer();
    _handleAttribute(_blockAttrsHandlers, block, output, () {
      for (final line in block.children) {
        line.accept(this, out);
      }
    });
    return out;
  }

  @override
  StringSink visitLine(Line line, [StringSink? output]) {
    final out = output ??= StringBuffer();
    final style = line.style;
    _handleAttribute(_lineAttrsHandlers, line, output, () {
      for (final leaf in line.children) {
        leaf.accept(this, out);
      }
    });
    if (style.isEmpty ||
        style.values.every((item) => item.scope != AttributeScope.block)) {
      out.writeln();
    }
    if (style.containsKey(Attribute.list.key) &&
        line.nextLine?.style.containsKey(Attribute.list.key) != true) {
      out.writeln();
    }
    out.writeln();
    return out;
  }

  @override
  StringSink visitText(QuillText text, [StringSink? output]) {
    final out = output ??= StringBuffer();
    final style = text.style;
    _handleAttribute(
      _textAttrsHandlers,
      text,
      output,
      () {
        var content = text.value;
        if (!(style.containsKey(Attribute.codeBlock.key) ||
            style.containsKey(Attribute.inlineCode.key) ||
            (text.parent?.style.containsKey(Attribute.codeBlock.key) ??
                false))) {
          content = content.replaceAllMapped(
              RegExp(r'[\\\`\*\_\{\}\[\]\(\)\#\+\-\.\!\>\<]'), (match) {
            return '\\${match[0]}';
          });
        }
        out.write(content);
      },
      sortedAttrsBySpan: true,
    );
    return out;
  }

  @override
  StringSink visitEmbed(Embed embed, [StringSink? output]) {
    final out = output ??= StringBuffer();

    final type = embed.value.type;

    _embedHandlers[type]!.call(embed, out);

    return out;
  }

  void _handleAttribute(
    Map<String, _AttributeHandler> handlers,
    Node node,
    StringSink output,
    VoidCallback contentHandler, {
    bool sortedAttrsBySpan = false,
  }) {
    final attrs = sortedAttrsBySpan
        ? node.attrsSortedByLongestSpan()
        : node.style.attributes.values.toList();
    final handlersToUse = attrs
        .where((attr) => handlers.containsKey(attr.key))
        .map((attr) => MapEntry(attr.key, handlers[attr.key]!))
        .toList();
    for (final handlerEntry in handlersToUse) {
      handlerEntry.value.beforeContent?.call(
        node.style.attributes[handlerEntry.key]!,
        node,
        output,
      );
    }
    contentHandler();
    for (final handlerEntry in handlersToUse.reversed) {
      handlerEntry.value.afterContent?.call(
        node.style.attributes[handlerEntry.key]!,
        node,
        output,
      );
    }
  }
}

//// AST with visitor

abstract class _NodeVisitor<T> {
  const _NodeVisitor._();

  T visitRoot(Root root, [T? context]);

  T visitBlock(Block block, [T? context]);

  T visitLine(Line line, [T? context]);

  T visitText(QuillText text, [T? context]);

  T visitEmbed(Embed embed, [T? context]);
}

extension _NodeX on Node {
  T accept<T>(_NodeVisitor<T> visitor, [T? context]) {
    switch (runtimeType) {
      case const (Root):
        return visitor.visitRoot(this as Root, context);
      case const (Block):
        return visitor.visitBlock(this as Block, context);
      case const (Line):
        return visitor.visitLine(this as Line, context);
      case const (QuillText):
        return visitor.visitText(this as QuillText, context);
      case const (Embed):
        return visitor.visitEmbed(this as Embed, context);
    }
    throw Exception('Container of type $runtimeType cannot be visited');
  }

  bool containsAttr(String attributeKey, [Object? value]) {
    if (!style.containsKey(attributeKey)) {
      return false;
    }
    if (value == null) {
      return true;
    }
    return style.attributes[attributeKey]!.value == value;
  }

  T getAttrValueOr<T>(String attributeKey, T or) {
    final attrs = style.attributes;
    final attrValue = attrs[attributeKey]?.value as T?;
    return attrValue ?? or;
  }

  List<Attribute<Object?>> attrsSortedByLongestSpan() {
    final attrCount = <Attribute<dynamic>, int>{};
    var node = this;
    // get the first node
    while (node.previous != null) {
      node = node.previous!;
      node.style.attributes.forEach((key, value) {
        attrCount[value] = (attrCount[value] ?? 0) + 1;
      });
      node = node.next!;
    }

    final attrs = style.attributes.values.sorted(
        (attr1, attr2) => attrCount[attr2]!.compareTo(attrCount[attr1]!));

    return attrs;
  }
}
