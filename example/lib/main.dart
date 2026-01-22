import 'dart:convert';
import 'dart:io' as io show Directory, File;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
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
      home: HomePage(),
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

class _HomePageState extends State<HomePage> {
  final QuillController _controller = () {
    return QuillController.basic(
        config: QuillControllerConfig(
      clipboardConfig: QuillClipboardConfig(
        enableExternalRichPaste: true,
        onImagePaste: (imageBytes) async {
          if (kIsWeb) {
            // Dart IO is unsupported on the web.
            return null;
          }
          // Save the image somewhere and return the image URL that will be
          // stored in the Quill Delta JSON (the document).
          final newFileName =
              'image-file-${DateTime.now().toIso8601String()}.png';
          final newPath = path.join(
            io.Directory.systemTemp.path,
            newFileName,
          );
          final file = await io.File(
            newPath,
          ).writeAsBytes(imageBytes, flush: true);
          return file.path;
        },
      ),
    ));
  }();
  final FocusNode _editorFocusNode = FocusNode();
  final ScrollController _editorScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Load document
    _controller.document = Document.fromJson([
      {
        'insert':
            'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry\'s standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.'
      },
      {'insert': '\n'}
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter Quill Example'),
        actions: [
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
                  decoration: BoxDecoration(
                    color: Colors.white,
                  ),
                  mentionSearch: (query) async {
                    // Example: Search for users
                    await Future.delayed(const Duration(milliseconds: 300));
                    final allUsers = [
                      MentionItem(
                        id: '1',
                        name: 'John Doe',
                        avatarUrl: null,
                        color: '#FF5733',
                      ),
                      MentionItem(
                        id: '2',
                        name: 'Jane Smith',
                        avatarUrl: null,
                        color: '#33C3F0',
                      ),
                      MentionItem(
                        id: '3',
                        name: 'Bob Johnson',
                        avatarUrl: null,
                        color: '#4CAF50',
                      ),
                      MentionItem(
                        id: '4',
                        name: 'Alice Williams',
                        avatarUrl: null,
                        color: '#FF9800',
                      ),
                    ];
                    if (query.isEmpty) return allUsers;
                    return allUsers
                        .where(
                          (user) => user.name.toLowerCase().contains(
                                query.toLowerCase(),
                              ),
                        )
                        .toList();
                  },
                  itemHeight: 20,
                  tagSearch: (query) async {
                    // Example: Search for tags (#)
                    await Future.delayed(const Duration(milliseconds: 300));
                    final allTags = [
                      TagItem(
                        id: '1',
                        name: 'flutter',
                        count: 123,
                        color: '#2196F3',
                      ),
                      // Blue
                      TagItem(
                        id: '2',
                        name: 'dart',
                        count: 89,
                        color: '#00BCD4',
                      ),
                      // Cyan
                      TagItem(
                        id: '3',
                        name: 'mobile',
                        count: 45,
                        color: '#4CAF50',
                      ),
                      // Green
                      TagItem(
                        id: '4',
                        name: 'development',
                        count: 67,
                        color: '#FF9800',
                      ),
                      // Orange
                      TagItem(
                        id: '5',
                        name: 'develop',
                        count: 69,
                        color: '#000000',
                      ),
                      TagItem(
                        id: '6',
                        name: 'develop',
                        count: 69,
                        color: '#000000',
                      ),
                      TagItem(
                        id: '7',
                        name: 'develop',
                        count: 69,
                        color: '#000000',
                      ),
                      TagItem(
                        id: '8',
                        name: 'develop',
                        count: 69,
                        color: '#000000',
                      ),
                      TagItem(
                        id: '9',
                        name: 'develop',
                        count: 69,
                        color: '#000000',
                      ),
                      TagItem(
                        id: '10',
                        name: 'develop',
                        count: 69,
                        color: '#000000',
                      ),
                      TagItem(
                        id: '11',
                        name: 'develop',
                        count: 69,
                        color: '#000000',
                      ),
                      TagItem(
                        id: '12',
                        name: 'develop',
                        count: 69,
                        color: '#000000',
                      ),
                      TagItem(
                        id: '13',
                        name: 'develop',
                        count: 69,
                        color: '#000000',
                      ),
                      TagItem(
                        id: '14',
                        name: 'develop',
                        count: 69,
                        color: '#000000',
                      ),
                      TagItem(
                        id: '15',
                        name: 'develop',
                        count: 69,
                        color: '#000000',
                      ),
                      TagItem(
                        id: '16',
                        name: 'develop',
                        count: 69,
                        color: '#000000',
                      ),
                      TagItem(
                        id: '17',
                        name: 'develop',
                        count: 69,
                        color: '#000000',
                      ),
                      TagItem(
                        id: '18',
                        name: 'develop',
                        count: 69,
                        color: '#000000',
                      ),
                      TagItem(
                        id: '19',
                        name: 'develop',
                        count: 69,
                        color: '#000000',
                      ),
                      TagItem(
                        id: '20',
                        name: 'develop',
                        count: 69,
                        color: '#000000',
                      ),
                      TagItem(
                        id: '21',
                        name: 'develop',
                        count: 69,
                        color: '#000000',
                      ),
                      TagItem(
                        id: '22',
                        name: 'develop',
                        count: 69,
                        color: '#000000',
                      ),
                      TagItem(
                        id: '23',
                        name: 'develop',
                        count: 69,
                        color: '#000000',
                      ),
                      TagItem(
                        id: '24',
                        name: 'develop',
                        count: 69,
                        color: '#000000',
                      ),
                      // Orange
                    ];
                    if (query.isEmpty) return allTags;
                    return allTags
                        .where(
                          (tag) => tag.name.toLowerCase().contains(
                                query.toLowerCase(),
                              ),
                        )
                        .toList();
                  },
                  dollarSearch: (query) async {
                    // Example: Search for currency tags ($)
                    await Future.delayed(const Duration(milliseconds: 300));
                    final allCurrencyTags = [
                      TagItem(
                        id: '1',
                        name: '1000',
                        count: null,
                        color: '#4CAF50',
                      ),
                      // Green
                      TagItem(
                        id: '2',
                        name: '100',
                        count: null,
                        color: '#FF9800',
                      ),
                      // Orange
                      TagItem(
                        id: '3',
                        name: '5000',
                        count: null,
                        color: '#2196F3',
                      ),
                      // Blue
                      TagItem(
                        id: '4',
                        name: '250',
                        count: null,
                        color: '#9C27B0',
                      ),
                      // Purple
                      TagItem(
                        id: '5',
                        name: '1000000',
                        count: null,
                        color: '#9C27B0',
                      ),
                      TagItem(
                        id: '5',
                        name: '1000000',
                        count: null,
                        color: '#9C27B0',
                      ),
                      TagItem(
                        id: '5',
                        name: '1000000',
                        count: null,
                        color: '#9C27B0',
                      ),
                      TagItem(
                        id: '5',
                        name: '1000000',
                        count: null,
                        color: '#9C27B0',
                      ),
                      TagItem(
                        id: '5',
                        name: '1000000',
                        count: null,
                        color: '#9C27B0',
                      ),
                      TagItem(
                        id: '5',
                        name: '1000000',
                        count: null,
                        color: '#9C27B0',
                      ),
                      TagItem(
                        id: '5',
                        name: '1000000',
                        count: null,
                        color: '#9C27B0',
                      ),
                      TagItem(
                        id: '5',
                        name: '1000000',
                        count: null,
                        color: '#9C27B0',
                      ),
                      TagItem(
                        id: '5',
                        name: '1000000',
                        count: null,
                        color: '#9C27B0',
                      ),
                      TagItem(
                        id: '5',
                        name: '1000000',
                        count: null,
                        color: '#9C27B0',
                      ),
                      TagItem(
                        id: '5',
                        name: '1000000',
                        count: null,
                        color: '#9C27B0',
                      ),
                      TagItem(
                        id: '5',
                        name: '1000000',
                        count: null,
                        color: '#9C27B0',
                      ),
                      TagItem(
                        id: '5',
                        name: '1000000',
                        count: null,
                        color: '#9C27B0',
                      ),
                      TagItem(
                        id: '5',
                        name: '1000000',
                        count: null,
                        color: '#9C27B0',
                      ),
                      TagItem(
                        id: '5',
                        name: '1000000',
                        count: null,
                        color: '#9C27B0',
                      ),
                      TagItem(
                        id: '5',
                        name: '1000000',
                        count: null,
                        color: '#9C27B0',
                      ),
                      TagItem(
                        id: '5',
                        name: '1000000',
                        count: null,
                        color: '#9C27B0',
                      ),
                      // Purple
                    ];
                    if (query.isEmpty) return allCurrencyTags;
                    return allCurrencyTags
                        .where(
                          (tag) => tag.name.toLowerCase().contains(
                                query.toLowerCase(),
                              ),
                        )
                        .toList();
                  },
                  onMentionSelected: (mention) {
                    debugPrint('Mention selected: ${mention.name}');
                  },
                  onTagSelected: (tag) {
                    debugPrint('Tag selected: ${tag.name}');
                  },
                  tagItemBuilder: (context, item, isSelected, onTap, _) {
                    // return Container(
                    //     color: Colors.red, child: Text(item.name));
                    return ListTile(
                        //leading: Icon(Icons.tag),
                        title: Text(item.name),
                        trailing:
                            item.count != null ? Text('${item.count}') : null,
                        selected: isSelected,
                        onTap: onTap);
                  },
                  mentionItemBuilder: (context, item, isSelected, onTap, _) {
                    // return Container(
                    //     color: Colors.red, child: Text('@${item.name}'));
                    return ListTile(
                        //leading: CircleAvatar(child: Text(item.name[0])),
                        title: Text('@${item.name}'),
                        selected: isSelected,
                        onTap: onTap);
                  }),
              child: QuillEditor(
                focusNode: _editorFocusNode,
                scrollController: _editorScrollController,
                controller: _controller,
                config: QuillEditorConfig(
                  placeholder:
                      'Start writing your notes...\nTry typing @ for mentions or # for tags',
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
    return Row(
      children: [
        const Icon(Icons.access_time_rounded),
        Text(embedContext.node.value.data as String),
      ],
    );
  }
}
