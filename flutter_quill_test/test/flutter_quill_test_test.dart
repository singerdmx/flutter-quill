import 'package:flutter_quill_test/flutter_quill_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('placeholder test', (tester) async {
    await tester.quillUpdateEditingValueWithSelection(find.text(''));
  });
}
