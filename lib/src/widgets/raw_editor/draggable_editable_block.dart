import 'dart:collection';

import 'package:flutter/material.dart';

import '../../../flutter_quill.dart';

class DraggableEditableBlock extends StatelessWidget {
  final Widget child;
  final dynamic node; // The type of 'node' should match your document node type
  final Function(dynamic) onDragCompleted; // Callback for when the drag is completed

  const DraggableEditableBlock({
    required this.child,
    required this.node,
    required this.onDragCompleted,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LongPressDraggable<Node>(
      data: node,
      feedback: Material(
        child: Opacity(
          opacity: 0.7,
          child: child, // Display the dragged widget with some transparency
        ),
      ),
      childWhenDragging: Container(), // Optionally, display a placeholder
      onDragCompleted: () => onDragCompleted(node),
      child: DragTarget<Node>(
        onAccept: (receivedNode) {
          // Logic to reorder nodes based on where the item is dropped
          _handleNodeDrop(context, receivedNode, node);
        },
        builder: (context, candidateData, rejectedData) {
          return child;
        },
      ),
    );
  }


  void _handleNodeDrop(BuildContext context, LinkedListEntry receivedNode, LinkedListEntry targetNode) {
    final editorState = context.findAncestorStateOfType<QuillRawEditorState>();

    if (editorState != null) {
      // Unlink the node from its current position
      receivedNode.unlink();

      // Insert the receivedNode before the targetNode
      targetNode.insertBefore(receivedNode);

      // Notify the editor that the document has changed
      editorState.controller.notifyListeners();
    }
  }

}