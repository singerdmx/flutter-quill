library delta_markdown;

import 'dart:convert';

import 'delta_markdown_decoder.dart';
import 'delta_markdown_encoder.dart';

/// Codec used to convert between Markdown and Quill deltas.
const DeltaMarkdownCodec _kCodec = DeltaMarkdownCodec();

String markdownToDelta(String markdown) {
  return _kCodec.decode(markdown);
}

String deltaToMarkdown(String delta) {
  return _kCodec.encode(delta);
}

class DeltaMarkdownCodec extends Codec<String, String> {
  const DeltaMarkdownCodec();

  @override
  Converter<String, String> get decoder => DeltaMarkdownDecoder();

  @override
  Converter<String, String> get encoder => DeltaMarkdownEncoder();
}
