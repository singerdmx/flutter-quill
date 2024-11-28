import '../../document/nodes/node.dart';

extension NodesCheckingExtension on Node {
  bool isNodeInline(){
    for (final attr in style.attributes.values) {
      if (!attr.isInline) return false;
    }
    return true;
  }
}
