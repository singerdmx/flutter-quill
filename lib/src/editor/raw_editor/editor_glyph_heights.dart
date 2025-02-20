import 'package:meta/meta.dart';

@immutable
class QuillEditorGlyphHeights {
  const QuillEditorGlyphHeights(
    this.startGlyphHeight,
    this.endGlyphHeight,
  );

  final double startGlyphHeight;
  final double endGlyphHeight;
}
