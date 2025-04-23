import 'package:flutter_quill/flutter_quill.dart';
import 'package:test/test.dart';

void main() {
  /// Attributes are assigned an AttributeScope to define how they are used.
  /// Collections of Attribute keys are used to allow quick iteration by type of scope.
  group('collections of keys', () {
    test('unmodifiable inlineKeys', () {
      expect(() => Attribute.inlineKeys.add('value'),
          throwsA(const TypeMatcher<UnsupportedError>()));
    });

    /// All registered attributes should be listed in collections of keys.
    test('collections of keys', () {
      final all = <String>{}..addAll(Attribute.registeredAttributeKeys);
      for (final key in Attribute.inlineKeys) {
        expect(all.remove(key), true);
      }
      for (final key in Attribute.blockKeys) {
        expect(all.remove(key), true);
      }
      for (final key in Attribute.embedKeys) {
        expect(all.remove(key), true);
      }
      for (final key in Attribute.ignoreKeys) {
        expect(all.remove(key), true);
      }
      expect(all, <String>{});
    });

    /// verify collections contain the correct AttributeScope.
    test('collections of scope', () {
      for (final key in Attribute.inlineKeys) {
        expect(Attribute.fromKeyValue(key, null)!.scope, AttributeScope.inline);
      }
      for (final key in Attribute.blockKeys) {
        expect(Attribute.fromKeyValue(key, null)!.scope, AttributeScope.block);
      }
      for (final key in Attribute.embedKeys) {
        expect(Attribute.fromKeyValue(key, null)!.scope, AttributeScope.embeds);
      }
      for (final key in Attribute.ignoreKeys) {
        expect(Attribute.fromKeyValue(key, null)!.scope, AttributeScope.ignore);
      }
    });
  });

  /// Tests for CommentHighlightAttribute
  group('CommentHighlightAttribute', () {
    test('creates attribute with correct key, scope, and value', () {
      final mapValue = {'id': '12345id', 'color': '#FFFFFF'};
      final attribute = CommentHighlightAttribute(val: mapValue);

      expect(attribute.key, 'comment-highlight');
      expect(attribute.scope, AttributeScope.inline);
      expect(attribute.value, mapValue);
    });

    test('is registered in inlineKeys', () {
      expect(Attribute.inlineKeys.contains('comment-highlight'), true);
    });

    test('fromKeyValue creates CommentHighlightAttribute with correct value', () {
      final mapValue = {'id': '12345id', 'color': '#FFFFFF'};
      final attribute = Attribute.fromKeyValue('comment-highlight', mapValue);

      expect(attribute, isA<CommentHighlightAttribute>());
      expect(attribute!.key, 'comment-highlight');
      expect(attribute.scope, AttributeScope.inline);
      expect(attribute.value, mapValue);
    });

    test('fromKeyValue handles null value', () {
      final attribute = Attribute.fromKeyValue('comment-highlight', null);

      expect(attribute, isA<CommentHighlightAttribute>());
      expect(attribute!.key, 'comment-highlight');
      expect(attribute.scope, AttributeScope.inline);
      expect(attribute.value, isNull);
    });
  });
}