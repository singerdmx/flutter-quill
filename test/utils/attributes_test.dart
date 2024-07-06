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
}
