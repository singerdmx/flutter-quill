import 'dart:convert' show jsonDecode;

import 'package:cross_file/cross_file.dart';
import 'package:file_picker/file_picker.dart' show FilePicker, FileType;
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

import '../../../extensions/scaffold_messenger.dart';
import '../../quill/quill_screen.dart';
import '../../quill/samples/quill_default_sample.dart';
import '../../quill/samples/quill_images_sample.dart';
import '../../quill/samples/quill_text_sample.dart';
import '../../quill/samples/quill_videos_sample.dart';

import '../../settings/widgets/settings_screen.dart';
import 'example_item.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static const routeName = '/home';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void dispose() {
    // ignore: deprecated_member_use
    SpellCheckerServiceProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Quill Demo'),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              child: Text(
                'Flutter Quill Demo',
              ),
            ),
            ListTile(
              title: const Text('Settings'),
              leading: const Icon(Icons.settings),
              onTap: () {
                Navigator.of(context)
                  ..pop()
                  ..pushNamed(SettingsScreen.routeName);
              },
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: Text(
                'Welcome to Flutter Quill Demo!',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  HomeScreenExampleItem(
                    title: 'Default',
                    icon: const Icon(
                      Icons.home,
                      size: 50,
                    ),
                    text:
                        'If you want to see how the editor work with default content, '
                        'see any samples or you are working on it',
                    onPressed: () => Navigator.of(context).pushNamed(
                      QuillScreen.routeName,
                      arguments: QuillScreenArgs(
                        document: Document.fromJson(quillDefaultSample),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  HomeScreenExampleItem(
                    title: 'Images',
                    icon: const Icon(
                      Icons.image,
                      size: 50,
                    ),
                    text: 'If you want to see how the editor work with images, '
                        'see any samples or you are working on it',
                    onPressed: () => Navigator.of(context).pushNamed(
                      QuillScreen.routeName,
                      arguments: QuillScreenArgs(
                        document: Document.fromJson(quillImagesSample),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  HomeScreenExampleItem(
                    title: 'Videos',
                    icon: const Icon(
                      Icons.video_chat,
                      size: 50,
                    ),
                    text: 'If you want to see how the editor work with videos, '
                        'see any samples or you are working on it',
                    onPressed: () => Navigator.of(context).pushNamed(
                      QuillScreen.routeName,
                      arguments: QuillScreenArgs(
                        document: Document.fromJson(quillVideosSample),
                      ),
                    ),
                  ),
                  HomeScreenExampleItem(
                    title: 'Text',
                    icon: const Icon(
                      Icons.edit_document,
                      size: 50,
                    ),
                    text: 'If you want to see how the editor work with text, '
                        'see any samples or you are working on it',
                    onPressed: () => Navigator.of(context).pushNamed(
                      QuillScreen.routeName,
                      arguments: QuillScreenArgs(
                        document: Document.fromJson(quillTextSample),
                      ),
                    ),
                  ),
                  HomeScreenExampleItem(
                    title: 'Open a document by delta json',
                    icon: const Icon(
                      Icons.file_copy,
                      size: 50,
                    ),
                    text: 'If you want to load a document by delta json file',
                    onPressed: () async {
                      final scaffoldMessenger = ScaffoldMessenger.of(context);
                      final navigator = Navigator.of(context);
                      try {
                        final result = await FilePicker.platform.pickFiles(
                          dialogTitle: 'Pick json delta',
                          type: FileType.custom,
                          allowedExtensions: ['json'],
                          allowMultiple: false,
                        );
                        final file = result?.files.firstOrNull;
                        final filePath = file?.path;
                        if (file == null || filePath == null) {
                          return;
                        }
                        final jsonString = await XFile(filePath).readAsString();

                        navigator.pushNamed(
                          QuillScreen.routeName,
                          arguments: QuillScreenArgs(
                            document: Document.fromJson(jsonDecode(jsonString)),
                          ),
                        );
                      } catch (e) {
                        debugPrint(
                          'Error while loading json delta file: ${e.toString()}',
                        );
                        scaffoldMessenger.showText(
                          'Error while loading json delta file: ${e.toString()}',
                        );
                      }
                    },
                  ),
                  HomeScreenExampleItem(
                    title: 'Empty',
                    icon: const Icon(
                      Icons.insert_drive_file,
                      size: 50,
                    ),
                    text: 'Want start clean? be my guest',
                    onPressed: () => Navigator.of(context).pushNamed(
                      QuillScreen.routeName,
                      arguments: QuillScreenArgs(
                        document: Document(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
