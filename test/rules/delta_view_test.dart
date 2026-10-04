import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:flutter_quill/src/rules/delete.dart';
import 'package:flutter_quill/src/rules/format.dart';
import 'package:flutter_quill/src/rules/insert.dart';
import 'package:test/test.dart';

class _CountingDocument extends Document {
  _CountingDocument(super.delta) : super.fromDelta();

  int copies = 0;
  int views = 0;

  @override
  Delta toDelta() {
    copies++;
    return super.toDelta();
  }

  @override
  Delta get deltaView {
    views++;
    return super.deltaView;
  }
}

void main() {
  void checkRule(
    Rule rule,
    Delta contents,
    int index,
    Delta? expected, {
    int? len,
    Object? data,
    Attribute? attribute,
    String suffix = '',
  }) {
    test('${rule.runtimeType}$suffix reads without copying or mutating', () {
      final document = _CountingDocument(contents);
      addTearDown(document.close);
      final before = document.deltaView.toJson();
      final view = document.deltaView;
      document.views = 0;

      expect(
        rule.apply(document, index, len: len, data: data, attribute: attribute),
        expected,
      );
      expect(document.copies, 0);
      expect(document.views, greaterThan(0));
      expect(identical(document.deltaView, view), isTrue);
      expect(document.deltaView.toJson(), before);
    });
  }

  final heading = Delta()
    ..insert('ab')
    ..insert('\n', {'header': 1})
    ..insert('cd\n');
  final bold = Delta()
    ..insert('ab', {'bold': true})
    ..insert('\n');

  checkRule(
    const PreserveLineStyleOnSplitRule(),
    heading,
    1,
    Delta()
      ..retain(1)
      ..insert('\n', {'header': 1}),
    data: '\n',
  );
  checkRule(
    const PreserveBlockStyleOnInsertRule(),
    Delta()
      ..insert('ab')
      ..insert('\n', {'list': 'bullet'}),
    1,
    Delta()
      ..retain(1)
      ..insert('\n', {'list': 'bullet'}),
    data: '\n',
  );
  checkRule(
    const AutoExitBlockRule(),
    Delta()
      ..insert('\n', {'list': 'bullet'})
      ..insert('\n'),
    0,
    Delta()..retain(1, {'list': null}),
    data: '\n',
  );
  checkRule(
    const ResetLineFormatOnNewLineRule(),
    heading,
    2,
    Delta()
      ..retain(2)
      ..insert('\n', {'header': 1})
      ..retain(1, {'header': null}),
    data: '\n',
  );
  checkRule(
    const InsertEmbedsRule(),
    Delta()..insert('ab\n'),
    1,
    Delta()
      ..retain(1)
      ..insert('\n')
      ..insert({'video': 'url'})
      ..insert('\n'),
    data: {'video': 'url'},
  );
  checkRule(
    const AutoFormatLinksRule(),
    Delta()
      ..insert('https://example.com', {'bold': true})
      ..insert('\n'),
    19,
    Delta()
      ..retain(19, {'bold': true, 'link': 'https://example.com'})
      ..insert(' ', {'bold': true}),
    data: ' ',
  );
  checkRule(
    const PreserveInlineStylesRule(),
    bold,
    1,
    Delta()
      ..retain(1)
      ..insert('x', {'bold': true}),
    data: 'x',
  );
  for (final rule in [
    const EnsureLastLineBreakDeleteRule(),
    const CatchAllDeleteRule(),
  ]) {
    checkRule(
      rule,
      Delta()..insert('ab\n'),
      1,
      Delta()
        ..retain(1)
        ..delete(1),
      len: 2,
    );
  }
  checkRule(
    const PreserveLineStyleOnMergeRule(),
    heading,
    2,
    Delta()
      ..retain(2)
      ..delete(1)
      ..retain(2)
      ..retain(1, {'header': 1}),
    len: 1,
  );
  checkRule(
    const PreserveLineStyleOnMergeRule(),
    Delta()
      ..insert('\n\n')
      ..insert('ab', {'bold': true})
      ..insert('\n'),
    1,
    Delta()
      ..retain(1)
      ..delete(1),
    len: 1,
    suffix: ' after an empty line',
  );
  checkRule(
    const EnsureEmbedLineRule(),
    Delta()
      ..insert({'image': 'url'})
      ..insert('\n'),
    1,
    null,
    len: 1,
  );
  checkRule(
    const ResolveLineFormatRule(),
    heading,
    0,
    Delta()
      ..retain(2)
      ..retain(1, {'header': null, 'list': 'bullet'}),
    len: 1,
    attribute: Attribute.ul,
  );
  checkRule(
    const FormatLinkAtCaretPositionRule(),
    Delta()
      ..insert('ab', {'link': 'old'})
      ..insert('\n'),
    1,
    Delta()..retain(2, {'link': 'new'}),
    len: 0,
    attribute: const LinkAttribute('new'),
  );
  checkRule(
    const ResolveInlineFormatRule(),
    Delta()..insert('a\nb\n'),
    0,
    Delta()
      ..retain(1, {'bold': true})
      ..retain(1)
      ..retain(1, {'bold': true}),
    len: 3,
    attribute: Attribute.bold,
  );

  test('long-document edits only copy for compose and survive undo/redo', () {
    final contents = Delta();
    for (var i = 0; i < 1000; i++) {
      contents.insert('ab', {'bold': i.isEven});
    }
    contents.insert('\n');
    final document = _CountingDocument(contents);
    addTearDown(document.close);
    final original = document.deltaView.toJson();

    void checkEdit(void Function() edit) {
      document
        ..copies = 0
        ..views = 0
        ..history.lastRecorded = 0;
      edit();
      expect(
        document.copies,
        1,
        reason: 'compose keeps its defensive snapshot',
      );
      expect(document.views, greaterThan(0));
      expect(document.deltaView, document.root.toDelta());
    }

    checkEdit(() => document.insert(1, 'x'));
    final inserted = document.deltaView.toJson();
    checkEdit(() => document.format(0, 2, Attribute.italic));
    final formatted = document.deltaView.toJson();
    checkEdit(() => document.delete(1, 1));
    final deleted = document.deltaView.toJson();

    document.undo();
    expect(document.deltaView.toJson(), formatted);
    document.undo();
    expect(document.deltaView.toJson(), inserted);
    document.undo();
    expect(document.deltaView.toJson(), original);
    document.redo();
    expect(document.deltaView.toJson(), inserted);
    document.redo();
    expect(document.deltaView.toJson(), formatted);
    document.redo();
    expect(document.deltaView.toJson(), deleted);
  });
}
