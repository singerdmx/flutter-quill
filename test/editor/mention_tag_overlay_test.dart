import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('MentionTagOverlay ignores stale mention search results',
      (tester) async {
    final searches = <String, Completer<List<MentionItem>>>{};

    Future<List<MentionItem>> mentionSearch(String query) {
      final completer = Completer<List<MentionItem>>();
      searches[query] = completer;
      return completer.future;
    }

    Widget buildOverlay(String query) {
      return MaterialApp(
        home: Scaffold(
          body: MentionTagOverlay(
            query: query,
            isMention: true,
            onSelectMention: (_) {},
            onSelectTag: (_) {},
            mentionSearch: mentionSearch,
            tagSearch: (_) async => const [],
            dollarSearch: (_) async => const [],
          ),
        ),
      );
    }

    await tester.pumpWidget(buildOverlay('a'));
    expect(searches.containsKey('a'), isTrue);

    await tester.pumpWidget(buildOverlay('ab'));
    await tester.pump(const Duration(milliseconds: 200));
    expect(searches.containsKey('ab'), isTrue);

    searches['ab']!.complete(const [
      MentionItem(id: 'ab', name: 'AB'),
    ]);
    await tester.pump();
    await tester.pump();
    expect(find.text('@AB'), findsOneWidget);

    searches['a']!.complete(const [
      MentionItem(id: 'a', name: 'A'),
    ]);
    await tester.pump();
    await tester.pump();

    expect(find.text('@AB'), findsOneWidget);
    expect(find.text('@A'), findsNothing);
  });

  testWidgets('MentionTagOverlay hides when search returns no results',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MentionTagOverlay(
            query: 'missing',
            isMention: true,
            onSelectMention: (_) {},
            onSelectTag: (_) {},
            mentionSearch: (_) async => const [],
            tagSearch: (_) async => const [],
            dollarSearch: (_) async => const [],
          ),
        ),
      ),
    );

    await tester.pump();
    await tester.pump();

    expect(find.byType(ListView), findsNothing);
  });

  testWidgets('MentionTagOverlay does not refresh for callback identity only',
      (tester) async {
    var searchCount = 0;

    Widget buildOverlay(MentionSearchCallback mentionSearch) {
      return MaterialApp(
        home: Scaffold(
          body: MentionTagOverlay(
            query: 'user',
            isMention: true,
            onSelectMention: (_) {},
            onSelectTag: (_) {},
            mentionSearch: mentionSearch,
            tagSearch: (_) async => const [],
            dollarSearch: (_) async => const [],
          ),
        ),
      );
    }

    await tester.pumpWidget(
      buildOverlay((_) async {
        searchCount++;
        return const [MentionItem(id: '1', name: 'User 1')];
      }),
    );
    await tester.pump();
    await tester.pump();
    expect(searchCount, 1);
    expect(find.text('@User 1'), findsOneWidget);

    await tester.pumpWidget(
      buildOverlay((_) async {
        searchCount++;
        return const [MentionItem(id: '2', name: 'User 2')];
      }),
    );
    await tester.pump();
    await tester.pump();

    expect(searchCount, 1);
    expect(find.text('@User 1'), findsOneWidget);
    expect(find.text('@User 2'), findsNothing);
  });

  testWidgets('MentionTagOverlay selects mention items loaded by pagination',
      (tester) async {
    MentionItem? selectedMention;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MentionTagOverlay(
            query: 'nooh',
            isMention: true,
            maxHeight: 96,
            onSelectMention: (item) => selectedMention = item,
            onSelectTag: (_) {},
            mentionSearch: (_) async => const [
              MentionItem(id: '1', name: 'First One'),
              MentionItem(id: '2', name: 'First Two'),
              MentionItem(id: '3', name: 'First Three'),
              MentionItem(id: '4', name: 'First Four'),
              MentionItem(id: '6', name: 'First Six'),
              MentionItem(id: '7', name: 'First Seven'),
            ],
            tagSearch: (_) async => const [],
            dollarSearch: (_) async => const [],
            onLoadMoreMentions: (_, __, ___) async => const [
              MentionItem(id: '5', name: 'Nooh Davis'),
            ],
            mentionItemBuilder: (_, item, __, onTap, ___) {
              return SizedBox(
                height: 48,
                child: TextButton(
                  onPressed: onTap,
                  child: Text('@${item.name}'),
                ),
              );
            },
          ),
        ),
      ),
    );

    await tester.pump();
    await tester.pump();
    await tester.drag(find.byType(Scrollable), const Offset(0, -1000));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.drag(find.byType(Scrollable), const Offset(0, -1000));
    await tester.pump();

    expect(find.text('@Nooh Davis'), findsOneWidget);

    await tester.tap(find.text('@Nooh Davis'));

    expect(selectedMention?.id, '5');
    expect(selectedMention?.name, 'Nooh Davis');
  });

  testWidgets('MentionTagOverlay appends paginated mentions with empty ids',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MentionTagOverlay(
            query: 'user',
            isMention: true,
            maxHeight: 96,
            onSelectMention: (_) {},
            onSelectTag: (_) {},
            mentionSearch: (_) async => const [
              MentionItem(id: '', name: 'First User'),
              MentionItem(id: '', name: 'Second User'),
              MentionItem(id: '', name: 'Third User'),
              MentionItem(id: '', name: 'Fourth User'),
              MentionItem(id: '', name: 'Fifth User'),
              MentionItem(id: '', name: 'Sixth User'),
            ],
            tagSearch: (_) async => const [],
            dollarSearch: (_) async => const [],
            onLoadMoreMentions: (_, __, ___) async => const [
              MentionItem(id: '', name: 'Loaded User'),
            ],
            mentionItemBuilder: (_, item, __, ___, ____) {
              return SizedBox(
                height: 48,
                child: Text('@${item.name}'),
              );
            },
          ),
        ),
      ),
    );

    await tester.pump();
    await tester.pump();
    await tester.drag(find.byType(Scrollable), const Offset(0, -1000));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.drag(find.byType(Scrollable), const Offset(0, -1000));
    await tester.pump();

    expect(find.text('@Loaded User'), findsOneWidget);
  });

  testWidgets('MentionTagOverlay selects tag items loaded by pagination',
      (tester) async {
    TagItem? selectedTag;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MentionTagOverlay(
            query: 'demo',
            isMention: false,
            maxHeight: 96,
            onSelectMention: (_) {},
            onSelectTag: (item) => selectedTag = item,
            mentionSearch: (_) async => const [],
            tagSearch: (_) async => const [
              TagItem(id: '1', name: 'FirstOne'),
              TagItem(id: '2', name: 'FirstTwo'),
              TagItem(id: '3', name: 'FirstThree'),
              TagItem(id: '4', name: 'FirstFour'),
              TagItem(id: '6', name: 'FirstSix'),
              TagItem(id: '7', name: 'FirstSeven'),
            ],
            dollarSearch: (_) async => const [],
            onLoadMoreTags: (_, __, ___) async => const [
              TagItem(id: '5', name: 'DemoLoaded'),
            ],
            tagItemBuilder: (_, item, __, onTap, ___) {
              return SizedBox(
                height: 48,
                child: TextButton(
                  onPressed: onTap,
                  child: Text(item.name),
                ),
              );
            },
          ),
        ),
      ),
    );

    await tester.pump();
    await tester.pump();
    await tester.drag(find.byType(Scrollable), const Offset(0, -1000));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.drag(find.byType(Scrollable), const Offset(0, -1000));
    await tester.pump();

    expect(find.text('DemoLoaded'), findsOneWidget);

    await tester.tap(find.text('DemoLoaded'));

    expect(selectedTag?.id, '5');
    expect(selectedTag?.name, 'DemoLoaded');
  });

  testWidgets('MentionTagOverlay appends paginated tags with empty ids',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MentionTagOverlay(
            query: 'tag',
            isMention: false,
            maxHeight: 96,
            onSelectMention: (_) {},
            onSelectTag: (_) {},
            mentionSearch: (_) async => const [],
            tagSearch: (_) async => const [
              TagItem(id: '', name: 'FirstTag'),
              TagItem(id: '', name: 'SecondTag'),
              TagItem(id: '', name: 'ThirdTag'),
              TagItem(id: '', name: 'FourthTag'),
              TagItem(id: '', name: 'FifthTag'),
              TagItem(id: '', name: 'SixthTag'),
            ],
            dollarSearch: (_) async => const [],
            onLoadMoreTags: (_, __, ___) async => const [
              TagItem(id: '', name: 'LoadedTag'),
            ],
            tagItemBuilder: (_, item, __, ___, ____) {
              return SizedBox(
                height: 48,
                child: Text(item.name),
              );
            },
          ),
        ),
      ),
    );

    await tester.pump();
    await tester.pump();
    await tester.drag(find.byType(Scrollable), const Offset(0, -1000));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.drag(find.byType(Scrollable), const Offset(0, -1000));
    await tester.pump();

    expect(find.text('LoadedTag'), findsOneWidget);
  });

  testWidgets(
      'MentionTagOverlay re-searches when query returns to a prior value '
      '(load-more / refine / backspace path)',
      (tester) async {
    var holdSearchCount = 0;

    Future<List<TagItem>> tagSearch(String q) async {
      if (q == 'hold') {
        holdSearchCount++;
      }
      if (q == 'hol') {
        return const [TagItem(id: 'h', name: 'HolOnly')];
      }
      if (q == 'hold') {
        return const [
          TagItem(id: '1', name: 'HoldOne'),
          TagItem(id: '2', name: 'HoldTwo'),
        ];
      }
      return const [];
    }

    Future<List<TagItem>> dollarSearch(String _) async => const [];

    Widget build(String query) {
      return MaterialApp(
        home: Scaffold(
          body: MentionTagOverlay(
            query: query,
            isMention: false,
            onSelectMention: (_) {},
            onSelectTag: (_) {},
            mentionSearch: (_) async => const [],
            tagSearch: tagSearch,
            dollarSearch: dollarSearch,
          ),
        ),
      );
    }

    await tester.pumpWidget(build('hold'));
    await tester.pump();
    await tester.pump();

    expect(holdSearchCount, 1);
    expect(find.text('HoldOne'), findsOneWidget);

    await tester.pumpWidget(build('hol'));
    await tester.pump(const Duration(milliseconds: 50));

    await tester.pumpWidget(build('hold'));
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pump();
    await tester.pump();

    expect(holdSearchCount, 2);
    expect(find.text('HoldOne'), findsOneWidget);
    expect(find.text('HolOnly'), findsNothing);
  });

  testWidgets('MentionTagOverlay selects refreshed tag after pagination',
      (tester) async {
    TagItem? selectedTag;

    Widget buildOverlay(String query) {
      return MaterialApp(
        home: Scaffold(
          body: MentionTagOverlay(
            query: query,
            isMention: false,
            maxHeight: 96,
            onSelectMention: (_) {},
            onSelectTag: (item) => selectedTag = item,
            mentionSearch: (_) async => const [],
            tagSearch: (value) async {
              if (value == 'new') {
                return const [
                  TagItem(id: 'new-1', name: 'New Result'),
                ];
              }
              return const [
                TagItem(id: '1', name: 'FirstOne'),
                TagItem(id: '2', name: 'FirstTwo'),
                TagItem(id: '3', name: 'FirstThree'),
                TagItem(id: '4', name: 'FirstFour'),
                TagItem(id: '5', name: 'FirstFive'),
                TagItem(id: '6', name: 'FirstSix'),
              ];
            },
            dollarSearch: (_) async => const [],
            onLoadMoreTags: (_, __, ___) async => const [
              TagItem(id: 'loaded-1', name: 'LoadedBeforeSearch'),
            ],
            tagItemBuilder: (_, item, __, onTap, ____) {
              return SizedBox(
                height: 48,
                child: TextButton(
                  onPressed: onTap,
                  child: Text(item.name),
                ),
              );
            },
          ),
        ),
      );
    }

    await tester.pumpWidget(buildOverlay('old'));
    await tester.pump();
    await tester.pump();
    await tester.drag(find.byType(Scrollable), const Offset(0, -1000));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    await tester.pumpWidget(buildOverlay('new'));
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pump();

    expect(find.text('New Result'), findsOneWidget);

    await tester.tap(find.text('New Result'));

    expect(selectedTag?.id, 'new-1');
    expect(selectedTag?.name, 'New Result');
  });

  testWidgets(
      'MentionTagOverlay refreshes tag order after pagination then search',
      (tester) async {
    var loadMoreCalls = 0;

    Widget buildOverlay(String query) {
      return MaterialApp(
        home: Scaffold(
          body: MentionTagOverlay(
            query: query,
            isMention: false,
            maxHeight: 96,
            onSelectMention: (_) {},
            onSelectTag: (_) {},
            mentionSearch: (_) async => const [],
            tagSearch: (value) async {
              if (value == 're') {
                return const [
                  TagItem(id: '2', name: 'Second'),
                  TagItem(id: '1', name: 'First'),
                ];
              }
              return const [
                TagItem(id: '1', name: 'First'),
                TagItem(id: '2', name: 'Second'),
                TagItem(id: '3', name: 'Third'),
                TagItem(id: '4', name: 'Fourth'),
                TagItem(id: '5', name: 'Fifth'),
                TagItem(id: '6', name: 'Sixth'),
              ];
            },
            dollarSearch: (_) async => const [],
            onLoadMoreTags: (_, __, ___) async {
              loadMoreCalls++;
              return const [
                TagItem(id: '7', name: 'LoadedItem'),
              ];
            },
            tagItemBuilder: (_, item, __, ___, ____) {
              return SizedBox(
                height: 48,
                child: Text(item.name),
              );
            },
          ),
        ),
      );
    }

    await tester.pumpWidget(buildOverlay('all'));
    await tester.pump();
    await tester.pump();

    await tester.drag(find.byType(Scrollable), const Offset(0, -1000));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.drag(find.byType(Scrollable), const Offset(0, -1000));
    await tester.pump();
    expect(loadMoreCalls > 0, isTrue);

    await tester.pumpWidget(buildOverlay('re'));
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pump();

    final secondFinder = find.text('Second');
    final firstFinder = find.text('First');
    expect(secondFinder, findsOneWidget);
    expect(firstFinder, findsOneWidget);

    final secondTopLeft = tester.getTopLeft(secondFinder);
    final firstTopLeft = tester.getTopLeft(firstFinder);
    expect(secondTopLeft.dy < firstTopLeft.dy, isTrue);
  });
}
