import 'package:flutter/material.dart';

import '../../controller/quill_controller.dart';
import '../../document/document.dart';
import '../../document/nodes/block.dart';
import '../../document/nodes/embeddable.dart';
import '../../document/nodes/leaf.dart';
import '../../document/nodes/line.dart';
import '../../document/nodes/node.dart';
import '../config/editor_config.dart';
import '../editor.dart';
import '../embed/embed_context.dart';
import '../embed/embed_editor_builder.dart';

/// A read-only Quill editor that can be collapsed to [maxLines] with
/// [maxLinesOverflow], optionally shows a wrapped first image, and has
/// "See more" / "See less" to expand and collapse.
///
/// Use for previews, cards, or lists where you want to limit initial
/// content and let the user expand to see full content.
class ExpandableQuillEditor extends StatefulWidget {
  const ExpandableQuillEditor({
    required this.controller,
    super.key,
    this.maxLines = 3,
    this.maxLinesOverflow = TextOverflow.ellipsis,
    this.showFirstImageWrapped = true,
    this.firstImageMaxHeight = 200,
    this.firstImageMaxWidth = double.infinity,
    this.seeMoreLabel = 'See more',
    this.seeLessLabel = 'See less',
    this.config = const QuillEditorConfig(),
    this.embedBuilders,
  });

  final QuillController controller;

  /// Maximum number of lines when collapsed.
  final int maxLines;

  /// Overflow behavior when collapsed.
  final TextOverflow maxLinesOverflow;

  /// If true and the document starts with an image embed, show that image
  /// above the text (wrapped in [firstImageMaxWidth] x [firstImageMaxHeight]).
  final bool showFirstImageWrapped;

  /// Max height for the first image when [showFirstImageWrapped] is true.
  final double firstImageMaxHeight;

  /// Max width for the first image when [showFirstImageWrapped] is true.
  final double firstImageMaxWidth;

  /// Label for the expand button.
  final String seeMoreLabel;

  /// Label for the collapse button.
  final String seeLessLabel;

  /// Base editor config (scrollable, padding, etc.). [maxLines] and
  /// [maxLinesOverflow] are applied on top when collapsed.
  final QuillEditorConfig config;

  /// Embed builders for the editor (and for building the first image if any).
  final List<EmbedBuilder>? embedBuilders;

  @override
  State<ExpandableQuillEditor> createState() => _ExpandableQuillEditorState();
}

class _ExpandableQuillEditorState extends State<ExpandableQuillEditor> {
  bool _expanded = false;

  double _effectiveMaxHeight(BuildContext context) {
    final textStyle =
        Theme.of(context).textTheme.bodyLarge ?? const TextStyle(fontSize: 16);
    final lineHeight = (textStyle.fontSize ?? 16) * (textStyle.height ?? 1.25);
    final padding = widget.config.padding.resolve(Directionality.of(context));
    return padding.top +
        padding.bottom +
        (lineHeight.clamp(18.0, 200.0) * widget.maxLines) +
        (widget.maxLines * 6);
  }

  @override
  Widget build(BuildContext context) {
    final doc = widget.controller.document;
    final config = widget.config;

    Widget? firstImageWidget;
    if (widget.showFirstImageWrapped &&
        !_expanded &&
        doc != null &&
        widget.embedBuilders != null) {
      firstImageWidget = _buildFirstImageIfAny(
        context,
        doc,
        widget.embedBuilders!,
      );
    }

    QuillEditorConfig effectiveConfig = _expanded
        ? config.copyWith(scrollable: true, maxHeight: null)
        : config.copyWith(
            scrollable: false,
            maxHeight: _effectiveMaxHeight(context),
          );
    if (widget.embedBuilders != null) {
      effectiveConfig = effectiveConfig.copyWith(
        embedBuilders: widget.embedBuilders,
      );
    }

    Widget editor = QuillEditor.basic(
      controller: widget.controller,
      config: effectiveConfig,
    );

    if (_expanded) {
      final maxExpandedHeight = MediaQuery.sizeOf(context).height * 0.6;
      editor = ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxExpandedHeight),
        child: editor,
      );
    } else {
      const bottomFadeHeight = 10.0;
      final maxH = _effectiveMaxHeight(context);
      final backgroundColor = Theme.of(context).scaffoldBackgroundColor;
      editor = SizedBox(
        height: maxH,
        child: ClipRect(
          child: Stack(
            children: [
              editor,
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: bottomFadeHeight,
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.white,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (firstImageWidget != null) ...[
          firstImageWidget,
          const SizedBox(height: 12),
        ],
        editor,
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton(
            onPressed: () {
              setState(() => _expanded = !_expanded);
            },
            child: Text(_expanded ? widget.seeLessLabel : widget.seeMoreLabel),
          ),
        ),
      ],
    );
  }

  Widget? _buildFirstImageIfAny(
    BuildContext context,
    Document document,
    List<EmbedBuilder> embedBuilders,
  ) {
    final embed = _getFirstImageEmbed(document);
    if (embed == null) return null;

    EmbedBuilder? builder;
    for (final b in embedBuilders) {
      if (b.key == embed.value.type) {
        builder = b;
        break;
      }
    }
    if (builder == null) return null;

    final textStyle =
        Theme.of(context).textTheme.bodyMedium ?? const TextStyle();
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: widget.firstImageMaxWidth,
        maxHeight: widget.firstImageMaxHeight,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: builder.build(
          context,
          EmbedContext(
            controller: widget.controller,
            node: embed,
            readOnly: true,
            inline: false,
            textStyle: textStyle,
          ),
        ),
      ),
    );
  }

  /// Returns the first [Embed] node in [document] that is an image, or null.
  static Embed? _getFirstImageEmbed(Document document) {
    for (final node in document.root.children) {
      if (node is! Block) continue;
      for (final line in node.children) {
        if (line is! Line) continue;
        for (final leaf in line.children) {
          if (leaf is Embed &&
              leaf.value.type == BlockEmbed.imageType &&
              leaf.value.data is String) {
            return leaf;
          }
        }
      }
    }
    return null;
  }
}
