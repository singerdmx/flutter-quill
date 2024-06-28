import 'package:flutter_quill/quill_delta.dart';
import 'package:flutter_quill/src/models/documents/delta_x.dart';
import 'package:test/test.dart';

void main() {
  const htmlWithEmp =
      '<p>This is a normal sentence, and this section has greater emp<em>hasis.</em></p>';
  final expectedDeltaEmp = Delta.fromOperations([
    Operation.insert(
        'This is a normal sentence, and this section has greater emp'),
    Operation.insert('hasis.', {'italic': true}),
    Operation.insert('\n'),
  ]);

  test('should detect emphasis and parse correctly', () {
    final delta = DeltaX.fromHtml(
      htmlWithEmp,
      configs: const Html2MdConfigs(),
    );
    expect(delta, expectedDeltaEmp);
  });
}
