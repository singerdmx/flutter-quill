import 'package:meta/meta.dart';

@experimental
enum SearchEmbedMode {
  /// No search within Embed nodes.
  none,
  //  Searches within Embed nodes using the nodes raw data [Embeddable.data.toString()]
  rawData,

  /// Searches within Embed nodes using override to [EmbedBuilder.toPlainText]
  plainText,
}

/// The configurations for the quill editor widget of flutter quill
@immutable
@experimental
class QuillSearchConfig {
  const QuillSearchConfig({
    this.searchEmbedMode = SearchEmbedMode.none,
  });

  /// Search options for embed objects
  ///
  /// [SearchEmbedMode.none] disables searching within embed objects.
  /// [SearchEmbedMode.rawData] searches the Embed node using the raw data.
  /// [SearchEmbedMode.plainText] searches the Embed node using the [EmbedBuilder.toPlainText] override.
  final SearchEmbedMode searchEmbedMode;

  /// Future search options
  ///
  /// [rememberLastSearch] - would recall the last search text used.
  /// [enableSearchHistory] - would allow selection of previous searches.

  QuillSearchConfig copyWith({
    SearchEmbedMode? searchEmbedMode,
  }) {
    return QuillSearchConfig(
      searchEmbedMode: searchEmbedMode ?? this.searchEmbedMode,
    );
  }
}
