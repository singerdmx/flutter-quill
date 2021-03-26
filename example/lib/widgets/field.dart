import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/widgets/controller.dart';
import 'package:flutter_quill/widgets/delegate.dart';
import 'package:flutter_quill/widgets/editor.dart';

class QuillField extends StatefulWidget {
  final QuillController controller;
  final FocusNode? focusNode;
  final ScrollController? scrollController;
  final bool scrollable;
  final EdgeInsetsGeometry padding;
  final bool autofocus;
  final bool showCursor;
  final bool readOnly;
  final bool enableInteractiveSelection;
  final double? minHeight;
  final double? maxHeight;
  final bool expands;
  final TextCapitalization textCapitalization;
  final Brightness keyboardAppearance;
  final ScrollPhysics? scrollPhysics;
  final ValueChanged<String>? onLaunchUrl;
  final InputDecoration? decoration;
  final Widget? toolbar;
  final EmbedBuilder? embedBuilder;

  QuillField({
    Key? key,
    required this.controller,
    this.focusNode,
    this.scrollController,
    this.scrollable = true,
    this.padding = EdgeInsets.zero,
    this.autofocus = false,
    this.showCursor = true,
    this.readOnly = false,
    this.enableInteractiveSelection = true,
    this.minHeight,
    this.maxHeight,
    this.expands = false,
    this.textCapitalization = TextCapitalization.sentences,
    this.keyboardAppearance = Brightness.light,
    this.scrollPhysics,
    this.onLaunchUrl,
    this.decoration,
    this.toolbar,
    this.embedBuilder,
  }) : super(key: key);

  @override
  _QuillFieldState createState() => _QuillFieldState();
}

class _QuillFieldState extends State<QuillField> {
  late bool _focused;

  void _editorFocusChanged() {
    setState(() {
      _focused = widget.focusNode!.hasFocus;
    });
  }

  @override
  void initState() {
    super.initState();
    _focused = widget.focusNode!.hasFocus;
    widget.focusNode!.addListener(_editorFocusChanged);
  }

  @override
  void didUpdateWidget(covariant QuillField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.focusNode != oldWidget.focusNode) {
      oldWidget.focusNode!.removeListener(_editorFocusChanged);
      widget.focusNode!.addListener(_editorFocusChanged);
      _focused = widget.focusNode!.hasFocus;
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget child = QuillEditor(
      controller: widget.controller,
      focusNode: widget.focusNode!,
      scrollController: widget.scrollController!,
      scrollable: widget.scrollable,
      padding: widget.padding,
      autoFocus: widget.autofocus,
      showCursor: widget.showCursor,
      readOnly: widget.readOnly,
      enableInteractiveSelection: widget.enableInteractiveSelection,
      minHeight: widget.minHeight,
      maxHeight: widget.maxHeight,
      expands: widget.expands,
      textCapitalization: widget.textCapitalization,
      keyboardAppearance: widget.keyboardAppearance,
      scrollPhysics: widget.scrollPhysics,
      onLaunchUrl: widget.onLaunchUrl,
      embedBuilder: widget.embedBuilder!,
    );

    if (widget.toolbar != null) {
      child = Column(
        children: [
          child,
          Visibility(
            child: widget.toolbar!,
            visible: _focused,
            maintainSize: true,
            maintainAnimation: true,
            maintainState: true,
          ),
        ],
      );
    }

    return AnimatedBuilder(
      animation:
          Listenable.merge(<Listenable?>[widget.focusNode, widget.controller]),
      builder: (BuildContext context, Widget? child) {
        return InputDecorator(
          decoration: _getEffectiveDecoration(),
          isFocused: widget.focusNode!.hasFocus,
          // TODO: Document should be considered empty of it has single empty line with no styles applied
          isEmpty: widget.controller.document.length == 1,
          child: child,
        );
      },
      child: child,
    );
  }

  InputDecoration _getEffectiveDecoration() {
    return (widget.decoration ?? const InputDecoration())
        .applyDefaults(Theme.of(context).inputDecorationTheme)
        .copyWith(
          enabled: !widget.readOnly,
          hintMaxLines: widget.decoration?.hintMaxLines,
        );
  }
}
