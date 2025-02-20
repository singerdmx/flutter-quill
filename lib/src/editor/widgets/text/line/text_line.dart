import 'dart:collection';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../flutter_quill.dart';
import '../../../../common/utils/color.dart';
import '../../../../common/utils/font.dart';
import '../../../../common/utils/platform.dart';
import '../../../../document/nodes/leaf.dart' as leaf;
import '../../delegate.dart';
import '../../keyboard_listener.dart';
import '../../proxies/embed_proxy.dart';
import '../../proxies/rich_text_proxy.dart';

class TextLine extends StatefulWidget {
  const TextLine({
    required this.line,
    required this.embedBuilder,
    required this.textSpanBuilder,
    required this.styles,
    required this.readOnly,
    required this.controller,
    required this.onLaunchUrl,
    required this.linkActionPicker,
    required this.composingRange,
    this.textDirection,
    this.customStyleBuilder,
    this.customRecognizerBuilder,
    this.customLinkPrefixes = const <String>[],
    super.key,
  });

  final Line line;
  final TextDirection? textDirection;
  final EmbedsBuilder embedBuilder;
  final TextSpanBuilder textSpanBuilder;
  final DefaultStyles styles;
  final bool readOnly;
  final QuillController controller;
  final CustomStyleBuilder? customStyleBuilder;
  final CustomRecognizerBuilder? customRecognizerBuilder;
  final ValueChanged<String>? onLaunchUrl;
  final LinkActionPicker linkActionPicker;
  final List<String> customLinkPrefixes;
  final TextRange composingRange;

  @override
  State<TextLine> createState() => _TextLineState();
}

class _TextLineState extends State<TextLine> {
  bool _metaOrControlPressed = false;

  UniqueKey _richTextKey = UniqueKey();

  final _linkRecognizers = <Node, GestureRecognizer>{};

  QuillPressedKeys? _pressedKeys;

  void _pressedKeysChanged() {
    final newValue = _pressedKeys!.metaPressed || _pressedKeys!.controlPressed;
    if (_metaOrControlPressed != newValue) {
      setState(() {
        _metaOrControlPressed = newValue;
        _linkRecognizers
          ..forEach((key, value) {
            value.dispose();
          })
          ..clear();
      });
    }
  }

  bool get canLaunchLinks {
    // In readOnly mode users can launch links
    // by simply tapping (clicking) on them
    if (widget.readOnly) return true;

    // In editing mode it depends on the platform:

    // Desktop platforms (macOS, Linux, Windows):
    // only allow Meta (Control) + Click combinations
    if (isDesktopApp) {
      return _metaOrControlPressed;
    }
    // Mobile platforms (ios, android): always allow but we install a
    // long-press handler instead of a tap one. LongPress is followed by a
    // context menu with actions.
    return true;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_pressedKeys == null) {
      _pressedKeys = QuillPressedKeys.of(context);
      _pressedKeys!.addListener(_pressedKeysChanged);
    } else {
      _pressedKeys!.removeListener(_pressedKeysChanged);
      _pressedKeys = QuillPressedKeys.of(context);
      _pressedKeys!.addListener(_pressedKeysChanged);
    }
  }

  @override
  void didUpdateWidget(covariant TextLine oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.readOnly != widget.readOnly) {
      _richTextKey = UniqueKey();
      _linkRecognizers
        ..forEach((key, value) {
          value.dispose();
        })
        ..clear();
    }
  }

  @override
  void dispose() {
    _pressedKeys?.removeListener(_pressedKeysChanged);
    _linkRecognizers
      ..forEach((key, value) => value.dispose())
      ..clear();
    super.dispose();
  }

  /// Check if this line contains the placeholder attribute
  bool get isPlaceholderLine =>
      widget.line.toDelta().first.attributes?.containsKey('placeholder') ??
      false;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMediaQuery(context));

    if (widget.line.hasEmbed && widget.line.childCount == 1) {
      // Single child embeds can be expanded
      var embed = widget.line.children.single as Embed;
      // Creates correct node for custom embed
      if (embed.value.type == BlockEmbed.customType) {
        embed = Embed(
          CustomBlockEmbed.fromJsonString(embed.value.data),
        );
      }
      final embedBuilder = widget.embedBuilder(embed);
      if (embedBuilder.expanded) {
        // Creates correct node for custom embed
        final lineStyle = _getLineStyle(widget.styles);
        return EmbedProxy(
          embedBuilder.build(
            context,
            EmbedContext(
              controller: widget.controller,
              node: embed,
              readOnly: widget.readOnly,
              inline: false,
              textStyle: lineStyle,
            ),
          ),
        );
      }
    }
    final textSpan = _getTextSpanForWholeLine();
    final strutStyle =
        StrutStyle.fromTextStyle(textSpan.style ?? const TextStyle());
    final textAlign = _getTextAlign();
    final child = RichText(
      key: _richTextKey,
      text: textSpan,
      textAlign: textAlign,
      textDirection: widget.textDirection,
      strutStyle: strutStyle,
      textScaler: MediaQuery.textScalerOf(context),
    );
    return RichTextProxy(
      textStyle: textSpan.style ?? const TextStyle(),
      textAlign: textAlign,
      textDirection: widget.textDirection!,
      strutStyle: strutStyle,
      locale: Localizations.localeOf(context),
      textScaler: MediaQuery.textScalerOf(context),
      child: child,
    );
  }

  InlineSpan _getTextSpanForWholeLine() {
    var lineStyle = _getLineStyle(widget.styles);
    if (!widget.line.hasEmbed) {
      return _buildTextSpan(
        widget.styles,
        widget.line.children,
        lineStyle,
        widget.textSpanBuilder,
      );
    }

    // The line could contain more than one Embed & more than one Text
    final textSpanChildren = <InlineSpan>[];
    var textNodes = LinkedList<Node>();
    for (var child in widget.line.children) {
      if (child is Embed) {
        if (textNodes.isNotEmpty) {
          textSpanChildren.add(_buildTextSpan(
            widget.styles,
            textNodes,
            lineStyle,
            widget.textSpanBuilder,
          ));
          textNodes = LinkedList<Node>();
        }
        // Creates correct node for custom embed
        if (child.value.type == BlockEmbed.customType) {
          child = Embed(CustomBlockEmbed.fromJsonString(child.value.data))
            ..applyStyle(child.style);
        }

        if (child.value.type == BlockEmbed.formulaType) {
          lineStyle = lineStyle.merge(_getInlineTextStyle(
            child.style,
            widget.styles,
            widget.line.style,
            false,
          ));
        }

        final embedBuilder = widget.embedBuilder(child);
        final embedWidget = EmbedProxy(
          embedBuilder.build(
            context,
            EmbedContext(
              controller: widget.controller,
              node: child,
              readOnly: widget.readOnly,
              inline: true,
              textStyle: lineStyle,
            ),
          ),
        );
        final embed = embedBuilder.buildWidgetSpan(embedWidget);
        textSpanChildren.add(embed);
        continue;
      }

      // here child is Text node and its value is cloned
      textNodes.add(child.clone());
    }

    if (textNodes.isNotEmpty) {
      textSpanChildren.add(_buildTextSpan(
        widget.styles,
        textNodes,
        lineStyle,
        widget.textSpanBuilder,
      ));
    }

    return TextSpan(style: lineStyle, children: textSpanChildren);
  }

  TextAlign _getTextAlign() {
    final alignment = widget.line.style.attributes[Attribute.align.key];
    if (alignment == Attribute.leftAlignment) {
      return TextAlign.start;
    } else if (alignment == Attribute.centerAlignment) {
      return TextAlign.center;
    } else if (alignment == Attribute.rightAlignment) {
      return TextAlign.end;
    } else if (alignment == Attribute.justifyAlignment) {
      return TextAlign.justify;
    }
    return TextAlign.start;
  }

  InlineSpan _buildTextSpan(
    DefaultStyles defaultStyles,
    LinkedList<Node> nodes,
    TextStyle lineStyle,
    TextSpanBuilder textSpanBuilder,
  ) {
    if (nodes.isEmpty && kIsWeb) {
      nodes = LinkedList<Node>()..add(leaf.QuillText());
    }

    final isComposingRangeOutOfLine = !widget.composingRange.isValid ||
        widget.composingRange.isCollapsed ||
        (widget.composingRange.start < widget.line.documentOffset ||
            widget.composingRange.end >
                widget.line.documentOffset + widget.line.length);

    if (isComposingRangeOutOfLine) {
      final children = nodes
          .map((node) => _getTextSpanFromNode(
                defaultStyles,
                node,
                widget.line.style,
                textSpanBuilder,
              ))
          .toList(growable: false);
      return TextSpan(children: children, style: lineStyle);
    }

    final children = nodes.expand((node) {
      final child = _getTextSpanFromNode(
        defaultStyles,
        node,
        widget.line.style,
        textSpanBuilder,
      );
      final isNodeInComposingRange =
          node.documentOffset <= widget.composingRange.start &&
              widget.composingRange.end <= node.documentOffset + node.length;
      if (isNodeInComposingRange) {
        return _splitAndApplyComposingStyle(node, child, textSpanBuilder);
      } else {
        return [child];
      }
    }).toList(growable: false);

    return TextSpan(children: children, style: lineStyle);
  }

  // split the text nodes into composing and non-composing nodes
  // and apply the composing style to the composing nodes
  List<InlineSpan> _splitAndApplyComposingStyle(
    Node node,
    InlineSpan child,
    TextSpanBuilder textSpanBuilder,
  ) {
    assert(widget.composingRange.isValid && !widget.composingRange.isCollapsed);

    final composingStart = widget.composingRange.start - node.documentOffset;
    final composingEnd = widget.composingRange.end - node.documentOffset;
    final text = child.toPlainText();

    final textBefore = text.substring(0, composingStart);
    final textComposing = text.substring(composingStart, composingEnd);
    final textAfter = text.substring(composingEnd);

    final composingStyle = child.style
            ?.merge(const TextStyle(decoration: TextDecoration.underline)) ??
        const TextStyle(decoration: TextDecoration.underline);

    final isLink = node.style.attributes[Attribute.link.key]?.value != null;
    final recognizer = _getRecognizer(node, isLink);

    return [
      textSpanBuilder(
        context,
        node,
        0,
        textBefore,
        child.style,
        recognizer,
      ),
      textSpanBuilder(
        context,
        node,
        composingStart,
        textComposing,
        composingStyle,
        recognizer,
      ),
      textSpanBuilder(
        context,
        node,
        composingEnd,
        textAfter,
        child.style,
        recognizer,
      ),
    ];
  }

  TextStyle _getLineStyle(DefaultStyles defaultStyles) {
    var textStyle = const TextStyle();

    if (widget.line.style.containsKey(Attribute.placeholder.key)) {
      return defaultStyles.placeHolder!.style;
    }

    final header = widget.line.style.attributes[Attribute.header.key];
    final m = <Attribute, TextStyle>{
      Attribute.h1: defaultStyles.h1!.style,
      Attribute.h2: defaultStyles.h2!.style,
      Attribute.h3: defaultStyles.h3!.style,
      Attribute.h4: defaultStyles.h4!.style,
      Attribute.h5: defaultStyles.h5!.style,
      Attribute.h6: defaultStyles.h6!.style,
    };

    textStyle = textStyle.merge(m[header] ?? defaultStyles.paragraph!.style);

    // Only retrieve exclusive block format for the line style purpose
    Attribute? block;
    widget.line.style.getBlocksExceptHeader().forEach((key, value) {
      if (Attribute.exclusiveBlockKeys.contains(key)) {
        block = value;
      }
    });

    TextStyle? toMerge;
    if (block == Attribute.blockQuote) {
      toMerge = defaultStyles.quote!.style;
    } else if (block == Attribute.codeBlock) {
      toMerge = defaultStyles.code!.style;
    } else if (block?.key == Attribute.list.key) {
      toMerge = defaultStyles.lists!.style;
    }

    textStyle = textStyle.merge(toMerge);

    final lineHeight = widget.line.style.attributes[Attribute.lineHeight.key];
    final x = <Attribute, TextStyle>{
      LineHeightAttribute.lineHeightNormal:
          defaultStyles.lineHeightNormal!.style,
      LineHeightAttribute.lineHeightTight: defaultStyles.lineHeightTight!.style,
      LineHeightAttribute.lineHeightOneAndHalf:
          defaultStyles.lineHeightOneAndHalf!.style,
      LineHeightAttribute.lineHeightDouble:
          defaultStyles.lineHeightDouble!.style,
    };

    // If the lineHeight attribute isn't null, then get just the height param instead whole TextStyle
    // to avoid modify the current style of the text line
    textStyle =
        textStyle.merge(textStyle.copyWith(height: x[lineHeight]?.height));

    textStyle = _applyCustomAttributes(textStyle, widget.line.style.attributes);

    if (isPlaceholderLine) {
      final oldStyle = textStyle;
      textStyle = defaultStyles.placeHolder!.style;
      textStyle = textStyle.merge(oldStyle.copyWith(
        color: textStyle.color,
        backgroundColor: textStyle.backgroundColor,
        background: textStyle.background,
      ));
    }

    return textStyle;
  }

  TextStyle _applyCustomAttributes(
      TextStyle textStyle, Map<String, Attribute> attributes) {
    if (widget.customStyleBuilder == null) {
      return textStyle;
    }
    for (final key in attributes.keys) {
      final attr = attributes[key];
      if (attr != null) {
        /// Custom Attribute
        final customAttr = widget.customStyleBuilder!.call(attr);
        textStyle = textStyle.merge(customAttr);
      }
    }
    return textStyle;
  }

  /// Processes subscript and superscript attributed text.
  ///
  /// Reduces text fontSize and shifts down or up. Increases fontWeight to maintain balance with normal text.
  /// Outputs characters individually to allow correct caret positioning and text selection.
  InlineSpan _scriptSpan(String text, bool superScript, TextStyle style,
      DefaultStyles defaultStyles) {
    assert(text.isNotEmpty);
    //
    final lineStyle = style.fontSize == null || style.fontWeight == null
        ? _getLineStyle(defaultStyles)
        : null;
    final fontWeight = FontWeight.lerp(
        style.fontWeight ?? lineStyle?.fontWeight ?? FontWeight.normal,
        FontWeight.w900,
        0.25);
    final fontSize = style.fontSize ?? lineStyle?.fontSize ?? 16;
    final y = (superScript ? -0.4 : 0.14) * fontSize;
    final charStyle = style.copyWith(
        fontFeatures: <FontFeature>[],
        fontWeight: fontWeight,
        fontSize: fontSize * 0.7);
    //
    final offset = Offset(0, y);
    final children = <WidgetSpan>[];
    for (final c in text.characters) {
      children.add(WidgetSpan(
          child: Transform.translate(
              offset: offset,
              child: Text(
                c,
                style: charStyle,
              ))));
    }
    //
    if (children.length > 1) {
      return TextSpan(children: children);
    }
    return children[0];
  }

  InlineSpan _getTextSpanFromNode(
    DefaultStyles defaultStyles,
    Node node,
    Style lineStyle,
    TextSpanBuilder textSpanBuilder,
  ) {
    final textNode = node as leaf.QuillText;
    final nodeStyle = textNode.style;
    final isLink = nodeStyle.containsKey(Attribute.link.key) &&
        nodeStyle.attributes[Attribute.link.key]!.value != null;
    final style =
        _getInlineTextStyle(nodeStyle, defaultStyles, lineStyle, isLink);
    if (widget.controller.config.requireScriptFontFeatures == false &&
        textNode.value.isNotEmpty) {
      if (nodeStyle.containsKey(Attribute.script.key)) {
        final attr = nodeStyle.attributes[Attribute.script.key];
        if (attr == Attribute.superscript || attr == Attribute.subscript) {
          return _scriptSpan(textNode.value, attr == Attribute.superscript,
              style, defaultStyles);
        }
      }
    }

    final recognizer = _getRecognizer(node, isLink);
    return textSpanBuilder(
      context,
      textNode,
      0,
      textNode.value,
      style,
      recognizer,
    );
  }

  TextStyle _getInlineTextStyle(Style nodeStyle, DefaultStyles defaultStyles,
      Style lineStyle, bool isLink) {
    var res = const TextStyle(); // This is inline text style
    final color = nodeStyle.attributes[Attribute.color.key];

    <String, TextStyle?>{
      Attribute.bold.key: defaultStyles.bold,
      Attribute.italic.key: defaultStyles.italic,
      Attribute.small.key: defaultStyles.small,
      Attribute.link.key: defaultStyles.link,
      Attribute.underline.key: defaultStyles.underline,
      Attribute.strikeThrough.key: defaultStyles.strikeThrough,
    }.forEach((k, s) {
      if (nodeStyle.values.any((v) => v.key == k)) {
        if (k == Attribute.underline.key || k == Attribute.strikeThrough.key) {
          var textColor = defaultStyles.color;
          if (color?.value is String) {
            textColor = stringToColor(color?.value, textColor, defaultStyles);
          }
          res = _merge(res.copyWith(decorationColor: textColor),
              s!.copyWith(decorationColor: textColor));
        } else if (k == Attribute.link.key && !isLink) {
          // null value for link should be ignored
          // i.e. nodeStyle.attributes[Attribute.link.key]!.value == null
        } else {
          res = _merge(res, s!);
        }
      }
    });

    if (nodeStyle.containsKey(Attribute.script.key)) {
      if (nodeStyle.attributes.values.contains(Attribute.subscript)) {
        res = _merge(res, defaultStyles.subscript!);
      } else if (nodeStyle.attributes.values.contains(Attribute.superscript)) {
        res = _merge(res, defaultStyles.superscript!);
      }
    }

    if (nodeStyle.containsKey(Attribute.inlineCode.key)) {
      res = _merge(res, defaultStyles.inlineCode!.styleFor(lineStyle));
    }

    final font = nodeStyle.attributes[Attribute.font.key];
    if (font != null && font.value != null) {
      res = res.merge(TextStyle(fontFamily: font.value));
    }

    final size = nodeStyle.attributes[Attribute.size.key];
    if (size != null && size.value != null) {
      switch (size.value) {
        case 'small':
          res = res.merge(defaultStyles.sizeSmall);
          break;
        case 'large':
          res = res.merge(defaultStyles.sizeLarge);
          break;
        case 'huge':
          res = res.merge(defaultStyles.sizeHuge);
          break;
        default:
          res = res.merge(TextStyle(
            fontSize: getFontSize(
              size.value,
            ),
          ));
      }
    }

    if (color != null && color.value != null) {
      var textColor = defaultStyles.color;
      if (color.value is String) {
        textColor = stringToColor(color.value, null, defaultStyles);
      }
      if (textColor != null) {
        res = res.merge(TextStyle(color: textColor));
      }
    }

    final background = nodeStyle.attributes[Attribute.background.key];
    if (background != null && background.value != null) {
      final backgroundColor =
          stringToColor(background.value, null, defaultStyles);
      res = res.merge(TextStyle(backgroundColor: backgroundColor));
    }

    res = _applyCustomAttributes(res, nodeStyle.attributes);
    return res;
  }

  GestureRecognizer? _getRecognizer(Node segment, bool isLink) {
    if (_linkRecognizers.containsKey(segment)) {
      return _linkRecognizers[segment]!;
    }

    if (widget.customRecognizerBuilder != null) {
      final textNode = segment as leaf.QuillText;
      final nodeStyle = textNode.style;

      nodeStyle.attributes.forEach((key, value) {
        final recognizer = widget.customRecognizerBuilder!.call(value, segment);
        if (recognizer != null) {
          _linkRecognizers[segment] = recognizer;
          return;
        }
      });
    }

    if (_linkRecognizers.containsKey(segment)) {
      return _linkRecognizers[segment]!;
    }

    if (isLink && canLaunchLinks) {
      if (isDesktop || widget.readOnly) {
        _linkRecognizers[segment] = TapGestureRecognizer()
          ..onTap = () => _tapNodeLink(segment);
      } else {
        _linkRecognizers[segment] = LongPressGestureRecognizer()
          ..onLongPress = () => _longPressLink(segment);
      }
    }
    return _linkRecognizers[segment];
  }

  Future<void> _launchUrl(String url) async {
    await launchUrl(Uri.parse(url));
  }

  void _tapNodeLink(Node node) {
    final link = node.style.attributes[Attribute.link.key]!.value;

    _tapLink(link);
  }

  void _tapLink(String? link) {
    if (link == null) {
      return;
    }

    var launchUrl = widget.onLaunchUrl;
    launchUrl ??= _launchUrl;

    link = link.trim();
    if (!(widget.customLinkPrefixes + linkPrefixes)
        .any((linkPrefix) => link!.toLowerCase().startsWith(linkPrefix))) {
      link = 'https://$link';
    }
    launchUrl(link);
  }

  Future<void> _longPressLink(Node node) async {
    final link = node.style.attributes[Attribute.link.key]!.value!;
    final action = await widget.linkActionPicker(node);
    switch (action) {
      case LinkMenuAction.launch:
        _tapLink(link);
        break;
      case LinkMenuAction.copy:
        Clipboard.setData(ClipboardData(text: link));
        break;
      case LinkMenuAction.remove:
        final range = getLinkRange(node);
        widget.controller
            .formatText(range.start, range.end - range.start, Attribute.link);
        break;
      case LinkMenuAction.none:
        break;
    }
  }

  TextStyle _merge(TextStyle a, TextStyle b) {
    final decorations = <TextDecoration?>[];
    if (a.decoration != null) {
      decorations.add(a.decoration);
    }
    if (b.decoration != null) {
      decorations.add(b.decoration);
    }
    return a.merge(b).apply(
        decoration: TextDecoration.combine(
            List.castFrom<dynamic, TextDecoration>(decorations)));
  }
}
