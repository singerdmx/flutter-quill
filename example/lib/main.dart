import 'dart:convert';
import 'dart:io' as io show Directory, File;
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:path/path.dart' as path;

void main() => runApp(const MainApp());

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(useMaterial3: true),
      darkTheme: ThemeData.dark(useMaterial3: true),
      themeMode: ThemeMode.system,
      home: const HomePage(),
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        FlutterQuillLocalizations.delegate,
      ],
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

// ---------------------------------------------------------------------------
// Demo data & pagination (type @ # $ in editor to see lists; scroll to load more)
// ---------------------------------------------------------------------------

const int _pageSize = 5;
const int _searchDelayMs = 200;
const int _loadMoreDelayMs = 400;

/// Returns a page of items from [list], filtered by [query]; [page] is 0-based.
List<T> _paginatedSearch<T>(
  List<T> list,
  String query,
  int page,
  String Function(T) getName,
) {
  final filtered = query.isEmpty
      ? list
      : list
          .where((x) => getName(x).toLowerCase().contains(query.toLowerCase()))
          .toList();
  final start = page * _pageSize;
  if (start >= filtered.length) return [];
  return filtered.sublist(start, (start + _pageSize).clamp(0, filtered.length));
}

List<MentionItem> _mentionPage(String query, int page) {
  return _paginatedSearch(_mainMentionList, query, page, (u) => u.name)
      .map(
        (item) => MentionItem(
          id: item.id,
          name: item.name,
          avatarUrl: item.avatarUrl,
          customData: item.customData,
        ),
      )
      .toList(growable: false);
}

List<TagItem> _tagPage(List<TagItem> source, String query, int page) {
  return _paginatedSearch(source, query, page, (t) => t.name)
      .map(
        (item) => TagItem(
          id: item.id,
          name: item.name,
          count: item.count,
          customData: item.customData,
          color: item.color,
        ),
      )
      .toList(growable: false);
}

String _hexColor(int i, {int a = 37, int b = 17, int c = 7}) {
  final r = ((i * a % 155) + 100).toRadixString(16).padLeft(2, '0');
  final g = ((i * b % 155) + 100).toRadixString(16).padLeft(2, '0');
  final bl = ((i * c % 155) + 100).toRadixString(16).padLeft(2, '0');
  return '#$r$g$bl';
}

const Widget _loadMoreIndicator = Padding(
  padding: EdgeInsets.all(12),
  child: Center(
    child: SizedBox(
      width: 24,
      height: 24,
      child: CircularProgressIndicator(strokeWidth: 2),
    ),
  ),
);

final List<TagItem> _mainTagList = [
  for (var i = 0; i < _mainTagSeeds.length; i++)
    TagItem(
      id: _mainTagSeeds[i].$1,
      name: _mainTagSeeds[i].$2,
      count: _mainTagSeeds[i].$3,
      color: _hexColor(i),
    ),
];

const _mainTagSeeds = <(String, String, int)>[
  ('1', 'flutter', 123),
  ('2', 'dart', 89),
  ('3', 'mobile', 45),
  ('4', 'development', 67),
  ('5', 'widgets', 56),
  ('6', 'state', 78),
  ('7', 'async', 34),
  ('8', 'testing', 91),
  ('9', 'ui', 112),
  ('10', 'api', 44),
  ('11', 'database', 33),
  ('12', 'navigation', 28),
  ('13', 'forms', 65),
  ('14', 'theme', 41),
  ('15', 'responsive', 19),
  ('16', 'performance', 52),
  ('17', 'plugins', 88),
  ('18', 'packages', 77),
  ('19', 'layout', 36),
  ('20', 'animations', 61),
  ('21', 'gestures', 24),
  ('22', 'platform', 43),
  ('23', 'web', 95),
  ('24', 'desktop', 31),
];

final List<MentionItem> _mainMentionList = List.generate(
  50,
  (i) => MentionItem(
    id: '${i + 1}',
    name: 'User ${i + 1}',
    avatarUrl: null,
    customData: {"asset":"crypto"}
  ),
);

final List<TagItem> _mainDollarList = List.generate(
  50,
  (i) => TagItem(
    id: '${i + 1}',
    name: 'Amount ${i + 1}',
    count: (i + 1) * 100,
    color: _hexColor(i + 7),
  ),
);

Future<String?> _savePastedImageToTemp(Uint8List imageBytes) async {
  if (kIsWeb) return null;
  final name = 'image-file-${DateTime.now().toIso8601String()}.png';
  final file = await io.File(path.join(io.Directory.systemTemp.path, name))
      .writeAsBytes(imageBytes, flush: true);
  return file.path;
}

class _HomePageState extends State<HomePage> {
  late final QuillController _controller = QuillController.basic(
    config: QuillControllerConfig(
      clipboardConfig: QuillClipboardConfig(
        enableExternalRichPaste: true,
        onImagePaste: _savePastedImageToTemp,
      ),
    ),
  );
  final FocusNode _editorFocusNode = FocusNode();
  final ScrollController _editorScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller.document = Document();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Quill Example'),
        actions: [
          IconButton(
            icon: const Icon(Icons.visibility),
            tooltip: 'Read-only mention tags',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const ReadOnlyMentionTagExample(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.output),
            tooltip: 'Print Delta JSON to log',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content:
                      Text('The JSON Delta has been printed to the console.')));
              debugPrint(jsonEncode(_controller.document.toDelta().toJson()));
            },
          ),
        ],
      ),
      body: Column(
        children: [
          /*QuillSimpleToolbar(
            controller: _controller,
            config: QuillSimpleToolbarConfig(
              embedButtons: FlutterQuillEmbeds.toolbarButtons(),
              showClipboardPaste: true,
              customButtons: [
                QuillToolbarCustomButtonOptions(
                  icon: const Icon(Icons.add_alarm_rounded),
                  onPressed: () {
                    _controller.document.insert(
                      _controller.selection.extentOffset,
                      TimeStampEmbed(
                        DateTime.now().toString(),
                      ),
                    );

                    _controller.updateSelection(
                      TextSelection.collapsed(
                        offset: _controller.selection.extentOffset + 1,
                      ),
                      ChangeSource.local,
                    );
                  },
                ),
              ],
              buttonOptions: QuillSimpleToolbarButtonOptions(
                base: QuillToolbarBaseButtonOptions(
                  afterButtonPressed: () {
                    final isDesktop = {
                      TargetPlatform.linux,
                      TargetPlatform.windows,
                      TargetPlatform.macOS
                    }.contains(defaultTargetPlatform);
                    if (isDesktop) {
                      _editorFocusNode.requestFocus();
                    }
                  },
                ),
                linkStyle: QuillToolbarLinkStyleButtonOptions(
                  validateLink: (link) {
                    // Treats all links as valid. When launching the URL,
                    // `https://` is prefixed if the link is incomplete (e.g., `google.com` → `https://google.com`)
                    // however this happens only within the editor.
                    return true;
                  },
                ),
              ),
            ),
          ),*/
          Expanded(
            child: MentionTagWrapper(
              controller: _controller,
              config: MentionTagConfig(
                  defaultMentionColor: '#0000FF',
                  defaultHashTagColor: '#0000FF',
                  defaultDollarTagColor: '#0000FF',
                  tagStyle: Style.attr({
                    Attribute.fontWeight.key: const FontWeightAttribute('800'),
                  }),
                  decoration: BoxDecoration(color: Colors.white),
                  suggestionListPadding: EdgeInsets.symmetric(vertical: 30),
                  mentionSearch: (query) async {
                    print("mentionSearch : $query");
                    await Future.delayed(
                        const Duration(milliseconds: _searchDelayMs));
                    return _mentionPage(query, 0);
                  },
                  dollarSearch: (query) async {
                    print("dollarSearch : $query");
                    await Future.delayed(
                        const Duration(milliseconds: _searchDelayMs));
                    return _tagPage(_mainDollarList, query, 0);
                  },
                  tagSearch: (query) async {
                    print("tagSearch : $query");
                    await Future.delayed(
                        const Duration(milliseconds: _searchDelayMs));
                    return _tagPage(_mainTagList, query, 0);
                  },
                  onLoadMoreMentions: (query, currentItems, currentPage) async {
                    print("onLoadMoreMentions : $query");
                    await Future.delayed(
                        const Duration(milliseconds: _loadMoreDelayMs));
                    return _mentionPage('', currentPage);
                  },
                  onLoadMoreTags: (query, currentItems, currentPage) async {
                    await Future.delayed(
                        const Duration(milliseconds: _loadMoreDelayMs));
                    print("onLoadMoreTags : $query");
                    return _tagPage(_mainTagList, query, currentPage);
                  },
                  onLoadMoreDollarTags:
                      (query, currentItems, currentPage) async {
                        print("onLoadMoreDollarTags : $query");
                    await Future.delayed(
                        const Duration(milliseconds: _loadMoreDelayMs));
                    return _tagPage(_mainDollarList, query, currentPage);
                  },
                  loadMoreIndicatorBuilder: (context, isMention, tagTrigger) =>
                      _loadMoreIndicator,

                  onMentionSelected: (mention) {},
                  onTagTypingChanged: (bool isTypingTag) {},
                  onTagSelected: (tag) {},
                  mentionItemBuilder: (context, item, isSelected, onTap, _) {
                    // return Container(
                    //     color: Colors.red, child: Text('@${item.name}'));
                    return ListTile(
                        //leading: CircleAvatar(child: Text(item.name[0])),
                        title: Text('@${item.name}'),
                        selected: isSelected,
                        onTap: onTap);
                  }),
              child: QuillEditor.basic(
                focusNode: _editorFocusNode,
                scrollController: _editorScrollController,
                controller: _controller,
                config: QuillEditorConfig(
                  placeholder: 'Start writing your notes...',
                  hidePlaceholderOnFormat: true,
                  padding: const EdgeInsets.all(16),
                  embedBuilders: [
                    ...FlutterQuillEmbeds.editorBuilders(
                      imageEmbedConfig: QuillEditorImageEmbedConfig(
                        imageProviderBuilder: (context, imageUrl) {
                          // https://pub.dev/packages/flutter_quill_extensions#-image-assets
                          if (imageUrl.startsWith('assets/')) {
                            return AssetImage(imageUrl);
                          }
                          return null;
                        },
                      ),
                      videoEmbedConfig: QuillEditorVideoEmbedConfig(
                        customVideoBuilder: (videoUrl, readOnly) {
                          // To load YouTube videos https://github.com/singerdmx/flutter-quill/releases/tag/v10.8.0
                          return null;
                        },
                      ),
                    ),
                    TimeStampEmbedBuilder(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _editorScrollController.dispose();
    _editorFocusNode.dispose();
    super.dispose();
  }
}

class ReadOnlyMentionTagExample extends StatefulWidget {
  const ReadOnlyMentionTagExample({super.key});

  @override
  State<ReadOnlyMentionTagExample> createState() =>
      _ReadOnlyMentionTagExampleState();
}

class _ReadOnlyMentionTagExampleState extends State<ReadOnlyMentionTagExample> {
  late final QuillController _controller;
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final document = Document.fromDelta(
      Delta()
        ..insert('Read-only note with ')
        ..insert('@User 2', {
          Attribute.mention.key: {
            'id': '2',
            'name': 'User 2',
            'color': '#0000FF',
          },
          Attribute.fontWeight.key: '600',
        })
        ..insert(', ')
        ..insert('#flutter', {
          Attribute.tag.key: {
            'id': '1',
            'name': 'flutter',
            'color': '#0000FF',
          },
          Attribute.fontWeight.key: '600',
        })
        ..insert(', and ')
        ..insert('\$Amount 1', {
          Attribute.currency.key: {
            'id': '1',
            'name': 'Amount 1',
            'color': '#0000FF',
          },
          Attribute.fontWeight.key: '600',
        })
        ..insert(' content.\n\nTyping and suggestions are disabled here.\n'),
    );
    _controller = QuillController(
      document: document,
      selection: const TextSelection.collapsed(offset: 0),
      readOnly: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Read-only Mention Tags'),
      ),
      body: ListView(
        children: [
          MentionTagWrapper(
            controller: _controller,
            config: MentionTagConfig(
              mentionSearch: (value) async => [],
              tagSearch: (value) async => [],
              dollarSearch: (value) async => [],
              defaultMentionColor: '#0000FF',
              defaultHashTagColor: '#0000FF',
              defaultDollarTagColor: '#0000FF',
              tagStyle: Style.attr({
                Attribute.fontWeight.key: const FontWeightAttribute('800'),
              }),
            ),
            child: QuillEditor.basic(
              focusNode: _focusNode,
              scrollController: _scrollController,
              controller: _controller,
              config: QuillEditorConfig(
                scrollable: false,
                showCursor: false,
                padding: const EdgeInsets.all(16),
                customRecognizerBuilder: (attribute, leaf) {
                  final tokenDetails = _tokenDetailsFromAttribute(attribute);
                  if (tokenDetails == null) return null;

                  return TapGestureRecognizer()
                    ..onTap = () {
                      _showTokenDetails(
                        tokenDetails.type,
                        tokenDetails.details,
                      );
                    };
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  _ReadOnlyTokenDetails? _tokenDetailsFromAttribute(Attribute attribute) {
    if (attribute.value is! Map) return null;

    final type = switch (attribute.key) {
      String key when key == Attribute.mention.key => 'Mention',
      String key when key == Attribute.tag.key => 'Hashtag',
      String key when key == Attribute.currency.key => 'Currency',
      _ => null,
    };
    if (type == null) return null;

    return _ReadOnlyTokenDetails(
      type,
      Map<String, dynamic>.from(attribute.value as Map),
    );
  }

  void _showTokenDetails(String type, Map<String, dynamic> details) {
    final message = details.entries
        .map((entry) => '${entry.key}: ${entry.value}')
        .join('\n');

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(type),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}

class _ReadOnlyTokenDetails {
  const _ReadOnlyTokenDetails(this.type, this.details);

  final String type;
  final Map<String, dynamic> details;
}

class TimeStampEmbed extends Embeddable {
  const TimeStampEmbed(
    String value,
  ) : super(timeStampType, value);

  static const String timeStampType = 'timeStamp';

  static TimeStampEmbed fromDocument(Document document) =>
      TimeStampEmbed(jsonEncode(document.toDelta().toJson()));

  Document get document => Document.fromJson(jsonDecode(data));
}

class TimeStampEmbedBuilder extends EmbedBuilder {
  @override
  String get key => 'timeStamp';

  @override
  String toPlainText(Embed node) {
    return node.value.data;
  }

  @override
  Widget build(
    BuildContext context,
    EmbedContext embedContext,
  ) {
    return Row(children: [
      const Icon(Icons.access_time_rounded),
      Text(embedContext.node.value.data as String)
    ]);
  }
}
