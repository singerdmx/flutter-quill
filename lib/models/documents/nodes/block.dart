import 'package:quill_delta/quill_delta.dart';

import 'container.dart';
import 'line.dart';

class Block extends Container<Line> {
  @override
  Line get defaultChild => Line();

  @override
  Delta toDelta() {
    return children
        .map((child) => child.toDelta())
        .fold(Delta(), (a, b) => a.concat(b));
  }
}
