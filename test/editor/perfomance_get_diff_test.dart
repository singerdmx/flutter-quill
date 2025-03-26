import 'package:flutter/services.dart' show TextSelection;
import 'package:flutter_quill/src/delta/delta_diff.dart';
import 'package:test/test.dart';

void main() {
  group('Performance Tests', () {
    late Stopwatch stopwatch;
    const loremIpsum =
        'Lorem ipsum dolor sit amet, consectetur adipiscing elit. '
        'Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. ';

    setUp(() => stopwatch = Stopwatch());

    test('Simple insert (should complete <10ms)', () {
      // Small text (50 chars)
      final text = loremIpsum.substring(0, 50);
      const selection = TextSelection.collapsed(offset: 10);

      stopwatch.start();
      final diff = getDiff(
        text,
        text.replaceRange(10, 10, 'X'), // Insert 'X' at position 10
        selection,
        const TextSelection.collapsed(offset: 11),
      );
      stopwatch.stop();

      expect(diff.isInsert, isTrue);
      expect(stopwatch.elapsedMilliseconds, lessThan(10));
    });

    test('Medium replace (should complete <50ms)', () {
      // Medium text (1,000 chars)
      final text = List.generate(20, (_) => loremIpsum).join();
      const selection = TextSelection(baseOffset: 100, extentOffset: 105);

      stopwatch.start();
      final diff = getDiff(
        text,
        text.replaceRange(100, 105, 'NEW'), // Replace 5 chars with "NEW"
        selection,
        const TextSelection.collapsed(offset: 103),
      );
      stopwatch.stop();

      expect(diff.isReplace, isTrue);
      expect(stopwatch.elapsedMilliseconds, lessThan(50));
    });

    test('Large document edit (should complete <500ms)', () {
      // Large text (100,000 chars)
      final text = List.generate(2000, (_) => loremIpsum).join();
      const selection = TextSelection.collapsed(offset: 50000);

      stopwatch.start();
      final diff = getDiff(
        text,
        text.replaceRange(50000, 50000, 'INSERTION'), // Insert at position 50k
        selection,
        const TextSelection.collapsed(offset: 50008),
      );
      stopwatch.stop();

      expect(diff.isInsert, isTrue);
      expect(stopwatch.elapsedMilliseconds, lessThan(500));
    });

    test('Complex multi-edit fallback (should complete <1000ms)', () {
      final text = List.generate(1000, (_) => loremIpsum).join();
      const selection = TextSelection(baseOffset: 1000, extentOffset: 1005);

      // Simulate paste with multiple changes
      stopwatch.start();
      getDiff(
        text,
        text
            .replaceRange(1000, 1005, 'ABC')
            .replaceRange(2000, 2001, 'X') // Second unrelated change
            .replaceRange(3000, 3002, 'YZ'), // Third change
        selection,
        const TextSelection.collapsed(offset: 1003),
      );
      stopwatch.stop();

      expect(stopwatch.elapsedMilliseconds, lessThan(1000));
    });

    test('Worst-case full diff (should complete <2000ms)', () {
      // Two completely different large texts
      final text1 = List.generate(5000, (i) => 'Line $i: $loremIpsum\n').join();
      final text2 =
          List.generate(5000, (i) => 'Modified ${i * 2}: $loremIpsum\n').join();

      stopwatch.start();
      getDiff(
        text1,
        text2,
        const TextSelection.collapsed(offset: 0),
        const TextSelection.collapsed(offset: 0),
      );
      stopwatch.stop();

      expect(stopwatch.elapsedMilliseconds, lessThan(2000));
    });

    test('Simulates forward deletion (should complete <10ms)', () {
      // A simple but large text
      final text1 = List.generate(5000, (i) => 'Line $i: $loremIpsum\n').join();

      stopwatch.start();
      getDiff(
        text1,
        text1.replaceRange(4500, 4501, ''),
        const TextSelection.collapsed(offset: 4500),
        const TextSelection.collapsed(offset: 4500),
      );
      stopwatch.stop();

      expect(stopwatch.elapsedMilliseconds, lessThan(10));
    });
  });
}
