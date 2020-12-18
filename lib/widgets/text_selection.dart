import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';

import 'editor.dart';

class EditorTextSelectionOverlay {
  TextEditingValue value;
  bool handlesVisible = false;
  final BuildContext context;
  final Widget debugRequiredFor;
  final LayerLink toolbarLayerLink;
  final LayerLink startHandleLayerLink;
  final LayerLink endHandleLayerLink;
  final RenderEditor renderObject;
  final TextSelectionControls selectionCtrls;
  final TextSelectionDelegate selectionDelegate;
  final DragStartBehavior dragStartBehavior;
  final VoidCallback onSelectionHandleTapped;
  final ClipboardStatusNotifier clipboardStatus;
  AnimationController _toolbarController;
  List<OverlayEntry> _handles;
  OverlayEntry toolbar;

  EditorTextSelectionOverlay(
      this.value,
      this.handlesVisible,
      this.context,
      this.debugRequiredFor,
      this.toolbarLayerLink,
      this.startHandleLayerLink,
      this.endHandleLayerLink,
      this.renderObject,
      this.selectionCtrls,
      this.selectionDelegate,
      this.dragStartBehavior,
      this.onSelectionHandleTapped,
      this.clipboardStatus)
      : assert(value != null),
        assert(context != null),
        assert(handlesVisible != null) {
    OverlayState overlay = Overlay.of(context, rootOverlay: true);
    assert(
      overlay != null,
    );
    _toolbarController = AnimationController(
        duration: Duration(milliseconds: 150), vsync: overlay);
  }

  setHandlesVisible(bool visible) {}

  hideHandles() {
    if (_handles == null) {
      return;
    }
    _handles[0].remove();
    _handles[1].remove();
    _handles = null;
  }

  hideToolbar() {
    assert(toolbar != null);
    _toolbarController.stop();
    toolbar.remove();
    toolbar = null;
  }

  /// Shows the toolbar by inserting it into the [context]'s overlay.
  showToolbar() {
    assert(toolbar == null);
    toolbar = OverlayEntry(builder: _buildToolbar);
    Overlay.of(context, rootOverlay: true, debugRequiredFor: debugRequiredFor)
        .insert(toolbar);
    _toolbarController.forward(from: 0.0);
  }

  Widget _buildToolbar(BuildContext context) {
    if (selectionCtrls == null) {
      return Container();
    }
  }

  _markNeedsBuild() {
    if (_handles != null) {
      _handles[0].markNeedsBuild();
      _handles[1].markNeedsBuild();
    }
    toolbar?.markNeedsBuild();
  }
}
