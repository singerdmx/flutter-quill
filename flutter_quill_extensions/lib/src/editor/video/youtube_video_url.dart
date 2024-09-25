import 'package:meta/meta.dart';

/// Function copied from https://github.com/sarbagyastha/youtube_player_flutter/blob/f8e1e79991066bcc70f0a7c93941ca0d54b7370e/packages/youtube_player_flutter/lib/src/player/youtube_player.dart#L154
/// and is not written as part of this project.
///
/// Used as quick response for https://github.com/singerdmx/flutter-quill/issues/2284
@experimental
@internal
@Deprecated(
  'Will be removed in future releases, for now included as quick response to https://github.com/singerdmx/flutter-quill/issues/2284',
)
String? convertVideoUrlToId(String url, {bool trimWhitespaces = true}) {
  if (!url.contains('http') && (url.length == 11)) return url;
  if (trimWhitespaces) url = url.trim();

  for (final exp in [
    RegExp(
        r'^https:\/\/(?:www\.|m\.)?youtube\.com\/watch\?v=([_\-a-zA-Z0-9]{11}).*$'),
    RegExp(
        r'^https:\/\/(?:music\.)?youtube\.com\/watch\?v=([_\-a-zA-Z0-9]{11}).*$'),
    RegExp(
        r'^https:\/\/(?:www\.|m\.)?youtube\.com\/shorts\/([_\-a-zA-Z0-9]{11}).*$'),
    RegExp(
        r'^https:\/\/(?:www\.|m\.)?youtube(?:-nocookie)?\.com\/embed\/([_\-a-zA-Z0-9]{11}).*$'),
    RegExp(r'^https:\/\/youtu\.be\/([_\-a-zA-Z0-9]{11}).*$')
  ]) {
    final Match? match = exp.firstMatch(url);
    if (match != null && match.groupCount >= 1) return match.group(1);
  }

  return null;
}
