import 'package:meta/meta.dart' show immutable;

import '../documents/document.dart';
import '../quill_delta.dart';

@immutable
class DocChange {
  const DocChange(
    this.before,
    this.change,
    this.source,
  );

  /// Document state before [change].
  final Delta before;

  /// Change delta applied to the document.
  final Delta change;

  /// The source of this change.
  final ChangeSource source;
}
