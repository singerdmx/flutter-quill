// ignore_for_file: deprecated_member_use_from_same_package

import 'package:flutter_quill/quill_delta.dart';
import 'package:flutter_quill/src/models/documents/delta_x.dart';
import 'package:test/test.dart';

void main() {
  const htmlWithEmp =
      '<p>This is a normal sentence, and this section has greater emp<em>hasis.</em></p>';

  const htmlWithUnderline =
      '<p>This is a normal sentence, and this section has greater <u>underline</u>';

  const htmlWithVideoTag =
      '<video src="https://www.youtube.com/embed/dQw4w9WgXcQ">Your browser does not support the video tag.</video>';

  const htmlWithNormalLinkAndVideo =
      '<a href="https://www.macrumors.com/" type="text/html">fdsfsd</a><br><video src="https://www.youtube.com/embed/dQw4w9WgXcQ">Your browser does not support the video tag.</video>';

  final expectedDeltaEmp = Delta.fromOperations([
    Operation.insert(
        'This is a normal sentence, and this section has greater emp'),
    Operation.insert('hasis.', {'italic': true}),
    Operation.insert('\n'),
  ]);

  final expectedDeltaUnderline = Delta.fromOperations([
    Operation.insert(
        'This is a normal sentence, and this section has greater '),
    Operation.insert('underline', {'underline': true}),
    Operation.insert('\n'),
  ]);

  final expectedDeltaVideo = Delta.fromOperations([
    Operation.insert({'video': 'https://www.youtube.com/embed/dQw4w9WgXcQ'}),
    Operation.insert('\n'),
  ]);

  final expectedDeltaLinkAndVideoLink = Delta.fromOperations([
    Operation.insert('fdsfsd', {'link': 'https://www.macrumors.com/'}),
    Operation.insert('\n'),
    Operation.insert({'video': 'https://www.youtube.com/embed/dQw4w9WgXcQ'}),
    Operation.insert('\n'),
  ]);

  test('should detect emphasis and parse correctly', () {
    final delta = DeltaX.fromHtml(htmlWithEmp);
    expect(delta, expectedDeltaEmp);
  });

  test('should detect underline and parse correctly', () {
    final delta = DeltaX.fromHtml(htmlWithUnderline);
    expect(delta, expectedDeltaUnderline);
  });

  test('should detect video and parse correctly', () {
    final delta = DeltaX.fromHtml(htmlWithVideoTag);
    expect(delta, expectedDeltaVideo);
  });

  test('should detect by different way normal link and video link', () {
    final delta = DeltaX.fromHtml(htmlWithNormalLinkAndVideo);
    expect(delta, expectedDeltaLinkAndVideoLink);
  });
}
