import 'dart:async';

import 'package:flutter/material.dart';

/// Scrollable list with arrow indicators.
///
/// The arrow indicators are automatically hidden if the list is not
/// scrollable in the direction of the respective arrow.
class QuillToolbarArrowIndicatedButtonList extends StatefulWidget {
  const QuillToolbarArrowIndicatedButtonList({
    required this.axis,
    required this.buttons,
    super.key,
  });

  final Axis axis;
  final List<Widget> buttons;

  @override
  QuillToolbarArrowIndicatedButtonListState createState() =>
      QuillToolbarArrowIndicatedButtonListState();
}

class QuillToolbarArrowIndicatedButtonListState
    extends State<QuillToolbarArrowIndicatedButtonList>
    with WidgetsBindingObserver {
  final ScrollController _controller = ScrollController();
  bool _showBackwardArrow = false;
  bool _showForwardArrow = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_handleScroll);

    // Listening to the WidgetsBinding instance is necessary so that we can
    // hide the arrows when the window gets a new size and thus the toolbar
    // becomes scrollable/unscrollable.
    WidgetsBinding.instance.addObserver(this);

    // Workaround to allow the scroll controller attach to our ListView so that
    // we can detect if overflow arrows need to be shown on init.
    Timer.run(_handleScroll);
  }

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[
      _buildBackwardArrow(),
      _buildScrollableList(),
      _buildForwardArrow(),
    ];

    return widget.axis == Axis.horizontal
        ? Row(
            children: children,
          )
        : Column(
            children: children,
          );
  }

  @override
  void didChangeMetrics() => _handleScroll();

  @override
  void dispose() {
    _controller.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _handleScroll() {
    if (!mounted) return;

    setState(() {
      _showBackwardArrow =
          _controller.position.minScrollExtent != _controller.position.pixels;
      _showForwardArrow =
          _controller.position.maxScrollExtent != _controller.position.pixels;
    });
  }

  Widget _buildBackwardArrow() {
    IconData? icon;
    if (_showBackwardArrow) {
      if (widget.axis == Axis.horizontal) {
        icon = Icons.arrow_left;
      } else {
        icon = Icons.arrow_drop_up;
      }
    }

    return SizedBox(
      width: 8,
      child: Transform.translate(
        // Move the icon a few pixels to center it
        offset: const Offset(-5, 0),
        child: icon != null ? Icon(icon, size: 18) : null,
      ),
    );
  }

  Widget _buildScrollableList() {
    return Expanded(
      child: ScrollConfiguration(
        // Remove the glowing effect, as we already have the arrow indicators
        behavior: _NoGlowBehavior(),
        // The CustomScrollView is necessary so that the children are not
        // stretched to the height of the toolbar:
        // https://stackoverflow.com/a/65998731/7091839
        child: CustomScrollView(
          scrollDirection: widget.axis,
          controller: _controller,
          physics: const ClampingScrollPhysics(),
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: widget.axis == Axis.horizontal
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: widget.buttons,
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: widget.buttons,
                    ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildForwardArrow() {
    IconData? icon;
    if (_showForwardArrow) {
      if (widget.axis == Axis.horizontal) {
        icon = Icons.arrow_right;
      } else {
        icon = Icons.arrow_drop_down;
      }
    }

    return SizedBox(
      width: 8,
      child: Transform.translate(
        // Move the icon a few pixels to center it
        offset: const Offset(-5, 0),
        child: icon != null ? Icon(icon, size: 18) : null,
      ),
    );
  }
}

/// ScrollBehavior without the Material glow effect.
class _NoGlowBehavior extends ScrollBehavior {
  Widget buildViewportChrome(BuildContext _, Widget child, AxisDirection __) {
    return child;
  }
}
