import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_quill/models/documents/attribute.dart';
import 'package:flutter_quill/models/documents/nodes/embed.dart';
import 'package:flutter_quill/models/documents/style.dart';

import 'controller.dart';

const double kToolbarHeight = 56.0;

class InsertEmbedButton extends StatelessWidget {
  final QuillController controller;
  final IconData icon;

  const InsertEmbedButton({
    Key key,
    @required this.controller,
    @required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return QuillIconButton(
      highlightElevation: 0,
      hoverElevation: 0,
      size: 32,
      icon: Icon(
        icon,
        size: 18,
        color: Theme.of(context).iconTheme.color,
      ),
      fillColor: Theme.of(context).canvasColor,
      onPressed: () {
        final index = controller.selection.baseOffset;
        final length = controller.selection.extentOffset - index;
        controller.replaceText(index, length, BlockEmbed.horizontalRule, null);
      },
    );
  }
}

class LinkStyleButton extends StatefulWidget {
  final QuillController controller;
  final IconData icon;

  const LinkStyleButton({
    Key key,
    @required this.controller,
    this.icon,
  }) : super(key: key);

  @override
  _LinkStyleButtonState createState() => _LinkStyleButtonState();
}

class _LinkStyleButtonState extends State<LinkStyleButton> {
  void _didChangeSelection() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_didChangeSelection);
  }

  @override
  void didUpdateWidget(covariant LinkStyleButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_didChangeSelection);
      widget.controller.addListener(_didChangeSelection);
    }
  }

  @override
  void dispose() {
    super.dispose();
    widget.controller.removeListener(_didChangeSelection);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEnabled = !widget.controller.selection.isCollapsed;
    final pressedHandler = isEnabled ? () => _openLinkDialog(context) : null;
    return QuillIconButton(
      highlightElevation: 0,
      hoverElevation: 0,
      size: 32,
      icon: Icon(
        widget.icon ?? Icons.link,
        size: 18,
        color: isEnabled ? theme.iconTheme.color : theme.disabledColor,
      ),
      fillColor: Theme.of(context).canvasColor,
      onPressed: pressedHandler,
    );
  }

  void _openLinkDialog(BuildContext context) {
    showDialog<String>(
      context: context,
      builder: (ctx) {
        return _LinkDialog();
      },
    ).then(_linkSubmitted);
  }

  void _linkSubmitted(String value) {
    if (value == null || value.isEmpty) {
      return;
    }
    widget.controller.formatSelection(LinkAttribute(value));
  }
}

class _LinkDialog extends StatefulWidget {
  const _LinkDialog({Key key}) : super(key: key);

  @override
  _LinkDialogState createState() => _LinkDialogState();
}

class _LinkDialogState extends State<_LinkDialog> {
  String _link = '';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: TextField(
        decoration: InputDecoration(labelText: 'Paste a link'),
        autofocus: true,
        onChanged: _linkChanged,
      ),
      actions: [
        FlatButton(
          onPressed: _link.isNotEmpty ? _applyLink : null,
          child: Text('Apply'),
        ),
      ],
    );
  }

  void _linkChanged(String value) {
    setState(() {
      _link = value;
    });
  }

  void _applyLink() {
    Navigator.pop(context, _link);
  }
}

typedef ToggleStyleButtonBuilder = Widget Function(
  BuildContext context,
  Attribute attribute,
  IconData icon,
  bool isToggled,
  VoidCallback onPressed,
);

class ToggleStyleButton extends StatefulWidget {
  final Attribute attribute;

  final IconData icon;

  final QuillController controller;

  final ToggleStyleButtonBuilder childBuilder;

  ToggleStyleButton({
    Key key,
    @required this.attribute,
    @required this.icon,
    @required this.controller,
    this.childBuilder = defaultToggleStyleButtonBuilder,
  })  : assert(attribute.value != null),
        assert(icon != null),
        assert(controller != null),
        assert(childBuilder != null),
        super(key: key);

  @override
  _ToggleStyleButtonState createState() => _ToggleStyleButtonState();
}

class _ToggleStyleButtonState extends State<ToggleStyleButton> {
  bool _isToggled;

  Style get _selectionStyle => widget.controller.getSelectionStyle();

  void _didChangeEditingValue() {
    setState(() {
      _isToggled = widget.controller
          .getSelectionStyle()
          .attributes
          .containsKey(widget.attribute.key);
    });
  }

  @override
  void initState() {
    super.initState();
    _isToggled = _selectionStyle.attributes.containsKey(widget.attribute.key);
    widget.controller.addListener(_didChangeEditingValue);
  }

  @override
  void didUpdateWidget(covariant ToggleStyleButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_didChangeEditingValue);
      widget.controller.addListener(_didChangeEditingValue);
      _isToggled = _selectionStyle.attributes.containsKey(widget.attribute.key);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_didChangeEditingValue);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isInCodeBlock =
        _selectionStyle.attributes.containsKey(Attribute.codeBlock.key);
    final isEnabled =
        !isInCodeBlock || widget.attribute.key == Attribute.codeBlock.key;
    return widget.childBuilder(context, widget.attribute, widget.icon,
        _isToggled, isEnabled ? _toggleAttribute : null);
  }

  _toggleAttribute() {
    widget.controller.formatSelection(_isToggled
        ? Attribute.clone(widget.attribute, null)
        : widget.attribute);
  }
}

Widget defaultToggleStyleButtonBuilder(
  BuildContext context,
  Attribute attribute,
  IconData icon,
  bool isToggled,
  VoidCallback onPressed,
) {
  final theme = Theme.of(context);
  final isEnabled = onPressed != null;
  final iconColor = isEnabled
      ? isToggled
          ? theme.primaryIconTheme.color
          : theme.iconTheme.color
      : theme.disabledColor;
  final fillColor = isToggled ? theme.toggleableActiveColor : theme.canvasColor;
  return QuillIconButton(
    highlightElevation: 0,
    hoverElevation: 0,
    size: 32,
    icon: Icon(icon, size: 18, color: iconColor),
    fillColor: fillColor,
    onPressed: onPressed,
  );
}

class SelectHeaderStyleButton extends StatefulWidget {
  final QuillController controller;

  const SelectHeaderStyleButton({Key key, @required this.controller})
      : super(key: key);

  @override
  _SelectHeaderStyleButtonState createState() =>
      _SelectHeaderStyleButtonState();
}

class _SelectHeaderStyleButtonState extends State<SelectHeaderStyleButton> {
  Attribute _value;

  Style get _selectionStyle => widget.controller.getSelectionStyle();

  void _didChangeEditingValue() {
    setState(() {
      _value =
          _selectionStyle.attributes[Attribute.header.key] ?? Attribute.header;
    });
  }

  void _selectAttribute(value) {
    widget.controller.formatSelection(value);
  }

  @override
  void initState() {
    super.initState();
    _value =
        _selectionStyle.attributes[Attribute.header.key] ?? Attribute.header;
    widget.controller.addListener(_didChangeEditingValue);
  }

  @override
  void didUpdateWidget(covariant SelectHeaderStyleButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_didChangeEditingValue);
      widget.controller.addListener(_didChangeEditingValue);
      _value =
          _selectionStyle.attributes[Attribute.header.key] ?? Attribute.header;
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_didChangeEditingValue);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _selectHeadingStyleButtonBuilder(context, _value, _selectAttribute);
  }
}

Widget _selectHeadingStyleButtonBuilder(
    BuildContext context, Attribute value, ValueChanged<Attribute> onSelected) {
  final style = TextStyle(fontSize: 12);

  final Map<Attribute, String> _valueToText = {
    Attribute.header: 'Normal text',
    Attribute.h1: 'Heading 1',
    Attribute.h2: 'Heading 2',
    Attribute.h3: 'Heading 3',
  };

  return QuillDropdownButton<Attribute>(
    highlightElevation: 0,
    hoverElevation: 0,
    height: 32,
    child: Text(
      _valueToText[value],
      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
    ),
    initialValue: value,
    items: [
      PopupMenuItem(
        child: Text(_valueToText[Attribute.header], style: style),
        value: Attribute.header,
        height: 32,
      ),
      PopupMenuItem(
        child: Text(_valueToText[Attribute.h1], style: style),
        value: Attribute.h1,
        height: 32,
      ),
      PopupMenuItem(
        child: Text(_valueToText[Attribute.h2], style: style),
        value: Attribute.h2,
        height: 32,
      ),
      PopupMenuItem(
        child: Text(_valueToText[Attribute.h3], style: style),
        value: Attribute.h3,
        height: 32,
      ),
    ],
    onSelected: onSelected,
  );
}

/// Controls color styles.
///
/// When pressed, this button displays overlay toolbar with
/// buttons for each color.
class ColorButton extends StatefulWidget {
  final Attribute attribute;

  final IconData icon;

  final QuillController controller;

  ColorButton(
      {Key key,
      @required this.attribute,
      @required this.icon,
      @required this.controller})
      : assert(attribute.value != null),
        assert(icon != null),
        assert(controller != null),
        super(key: key);

  @override
  _ColorButtonState createState() => _ColorButtonState();
}

class _ColorButtonState extends State<ColorButton> {

  @override
  Widget build(BuildContext context) {
    return _defaultToggleStyleButtonBuilder(
        context, widget.attribute, widget.icon, _showColorPicker);
  }

  Widget _defaultToggleStyleButtonBuilder(
    BuildContext context,
    Attribute attribute,
    IconData icon,
    VoidCallback onPressed,
  ) {
    final theme = Theme.of(context);
    final iconColor = theme.iconTheme.color;
    final fillColor = theme.canvasColor;
    return QuillIconButton(
      highlightElevation: 0,
      hoverElevation: 0,
      size: 32,
      icon: Icon(icon, size: 18, color: iconColor),
      fillColor: fillColor,
      onPressed: onPressed,
    );
  }

  void _changeColor(Color color) {
    widget.controller
        .formatSelection(ColorAttribute('#${color.value.toRadixString(16)}'));
    Navigator.of(context).pop();
  }

  _showColorPicker() {
    showDialog(
      context: context,
      child: AlertDialog(
          title: const Text('Select Color'),
          content: SingleChildScrollView(
            child: MaterialPicker(
              pickerColor: Color(0),
              onColorChanged: _changeColor,
            ),
          )),
    );
  }
}

class QuillToolbar extends StatefulWidget implements PreferredSizeWidget {
  final List<Widget> children;

  const QuillToolbar({Key key, @required this.children}) : super(key: key);

  factory QuillToolbar.basic(
      {Key key,
      @required QuillController controller,
      bool showBoldButton = true,
      bool showItalicButton = true,
      bool showUnderLineButton = true,
      bool showStrikeThrough = true,
      bool showColorButton = true,
      bool showBackgroundColorButton = true,
      bool showHeaderStyle = true,
      bool showListNumbers = true,
      bool showListBullets = true,
      bool showCodeBlock = true,
      bool showQuote = true,
      bool showLink = true,
      bool showHorizontalRule = true}) {
    return QuillToolbar(key: key, children: [
      Visibility(
        visible: showBoldButton,
        child: ToggleStyleButton(
          attribute: Attribute.bold,
          icon: Icons.format_bold,
          controller: controller,
        ),
      ),
      SizedBox(width: 1),
      Visibility(
        visible: showItalicButton,
        child: ToggleStyleButton(
          attribute: Attribute.italic,
          icon: Icons.format_italic,
          controller: controller,
        ),
      ),
      SizedBox(width: 1),
      Visibility(
        visible: showUnderLineButton,
        child: ToggleStyleButton(
          attribute: Attribute.underline,
          icon: Icons.format_underline,
          controller: controller,
        ),
      ),
      SizedBox(width: 1),
      Visibility(
        visible: showStrikeThrough,
        child: ToggleStyleButton(
          attribute: Attribute.strikeThrough,
          icon: Icons.format_strikethrough,
          controller: controller,
        ),
      ),
      SizedBox(width: 1),
      Visibility(
        visible: showColorButton,
        child: ColorButton(
          attribute: ColorAttribute('#000000'),
          icon: Icons.format_color_text,
          controller: controller,
        ),
      ),
      SizedBox(width: 1),
      Visibility(
        visible: showBackgroundColorButton,
        child: ToggleStyleButton(
          attribute: BackgroundAttribute('#ffffff'),
          icon: Icons.format_color_fill,
          controller: controller,
        ),
      ),
      Visibility(
          visible: showHeaderStyle,
          child: VerticalDivider(
              indent: 16, endIndent: 16, color: Colors.grey.shade400)),
      Visibility(
          visible: showHeaderStyle,
          child: SelectHeaderStyleButton(controller: controller)),
      VerticalDivider(indent: 16, endIndent: 16, color: Colors.grey.shade400),
      Visibility(
        visible: showListNumbers,
        child: ToggleStyleButton(
          attribute: Attribute.ol,
          controller: controller,
          icon: Icons.format_list_numbered,
        ),
      ),
      Visibility(
        visible: showListBullets,
        child: ToggleStyleButton(
          attribute: Attribute.ul,
          controller: controller,
          icon: Icons.format_list_bulleted,
        ),
      ),
      Visibility(
        visible: showCodeBlock,
        child: ToggleStyleButton(
          attribute: Attribute.codeBlock,
          controller: controller,
          icon: Icons.code,
        ),
      ),
      Visibility(
          visible: !showListNumbers && !showListBullets && !showCodeBlock,
          child: VerticalDivider(
              indent: 16, endIndent: 16, color: Colors.grey.shade400)),
      Visibility(
        visible: showQuote,
        child: ToggleStyleButton(
          attribute: Attribute.blockQuote,
          controller: controller,
          icon: Icons.format_quote,
        ),
      ),
      Visibility(
          visible: showQuote,
          child: VerticalDivider(
              indent: 16, endIndent: 16, color: Colors.grey.shade400)),
      Visibility(
          visible: showLink, child: LinkStyleButton(controller: controller)),
      Visibility(
        visible: showHorizontalRule,
        child: InsertEmbedButton(
          controller: controller,
          icon: Icons.horizontal_rule,
        ),
      ),
    ]);
  }

  @override
  _QuillToolbarState createState() => _QuillToolbarState();

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

class _QuillToolbarState extends State<QuillToolbar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8),
      constraints: BoxConstraints.tightFor(height: widget.preferredSize.height),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: widget.children,
        ),
      ),
    );
  }
}

class QuillIconButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget icon;
  final double size;
  final Color fillColor;
  final double hoverElevation;
  final double highlightElevation;

  const QuillIconButton({
    Key key,
    @required this.onPressed,
    this.icon,
    this.size = 40,
    this.fillColor,
    this.hoverElevation = 1,
    this.highlightElevation = 1,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints.tightFor(width: size, height: size),
      child: RawMaterialButton(
        child: icon,
        visualDensity: VisualDensity.compact,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
        padding: EdgeInsets.zero,
        fillColor: fillColor,
        elevation: 0,
        hoverElevation: hoverElevation,
        highlightElevation: hoverElevation,
        onPressed: onPressed,
      ),
    );
  }
}

class QuillDropdownButton<T> extends StatefulWidget {
  final double height;
  final Color fillColor;
  final double hoverElevation;
  final double highlightElevation;
  final Widget child;
  final T initialValue;
  final List<PopupMenuEntry<T>> items;
  final ValueChanged<T> onSelected;

  const QuillDropdownButton({
    Key key,
    this.height = 40,
    this.fillColor,
    this.hoverElevation = 1,
    this.highlightElevation = 1,
    @required this.child,
    @required this.initialValue,
    @required this.items,
    @required this.onSelected,
  }) : super(key: key);

  @override
  _QuillDropdownButtonState<T> createState() => _QuillDropdownButtonState<T>();
}

class _QuillDropdownButtonState<T> extends State<QuillDropdownButton<T>> {
  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints.tightFor(height: widget.height),
      child: RawMaterialButton(
        child: _buildContent(context),
        visualDensity: VisualDensity.compact,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
        padding: EdgeInsets.zero,
        fillColor: widget.fillColor,
        elevation: 0,
        hoverElevation: widget.hoverElevation,
        highlightElevation: widget.hoverElevation,
        onPressed: _showMenu,
      ),
    );
  }

  void _showMenu() {
    final popupMenuTheme = PopupMenuTheme.of(context);
    final button = context.findRenderObject() as RenderBox;
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(button.size.bottomLeft(Offset.zero),
            ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );
    showMenu<T>(
      context: context,
      elevation: 4,
      // widget.elevation ?? popupMenuTheme.elevation,
      initialValue: widget.initialValue,
      items: widget.items,
      position: position,
      shape: popupMenuTheme.shape,
      // widget.shape ?? popupMenuTheme.shape,
      color: popupMenuTheme.color, // widget.color ?? popupMenuTheme.color,
      // captureInheritedThemes: widget.captureInheritedThemes,
    ).then((T newValue) {
      if (!mounted) return null;
      if (newValue == null) {
        // if (widget.onCanceled != null) widget.onCanceled();
        return null;
      }
      if (widget.onSelected != null) {
        widget.onSelected(newValue);
      }
    });
  }

  Widget _buildContent(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints.tightFor(width: 110),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: [
            widget.child,
            Expanded(child: Container()),
            Icon(Icons.arrow_drop_down, size: 14)
          ],
        ),
      ),
    );
  }
}
