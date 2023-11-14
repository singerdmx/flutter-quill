import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

import '../../quill/quill_images_screen.dart';
import '../../quill/quill_screen.dart';
import '../../settings/widgets/settings_screen.dart';
import 'example_item.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

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
                    title: 'Images',
                    icon: const Icon(
                      Icons.image,
                      size: 50,
                    ),
                    text: 'If you want to see how the editor work with images, '
                        'see any samples or you are working on it',
                    onPressed: () {
                      Navigator.of(context)
                          .pushNamed(QuillImagesScreen.routeName);
                    },
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
                    onPressed: () {},
                  ),
                  HomeScreenExampleItem(
                    title: 'Text',
                    icon: const Icon(
                      Icons.edit_document,
                      size: 50,
                    ),
                    text: 'If you want to see how the editor work with text, '
                        'see any samples or you are working on it',
                    onPressed: () {},
                  ),
                  HomeScreenExampleItem(
                    title: 'Empty',
                    icon: const Icon(
                      Icons.insert_drive_file,
                      size: 50,
                    ),
                    text: 'Want start clean? be my guest',
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) {
                            return QuillScreen(
                              document: Document(),
                            );
                          },
                        ),
                      );
                    },
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
