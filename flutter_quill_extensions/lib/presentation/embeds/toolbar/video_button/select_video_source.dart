import 'package:flutter/material.dart';
import 'package:flutter_quill/extensions.dart' show isDesktop;

import '../../embed_types/video.dart';

class SelectVideoSourceDialog extends StatelessWidget {
  const SelectVideoSourceDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 230,
      width: double.infinity,
      child: SingleChildScrollView(
        child: Column(
          children: [
            // TODO: Needs to be translated
            ListTile(
              title: const Text('Gallery'),
              subtitle: const Text(
                'Pick a video from your gallery',
              ),
              leading: const Icon(Icons.photo_sharp),
              onTap: () => Navigator.of(context).pop(InsertVideoSource.gallery),
            ),
            ListTile(
              title: const Text('Camera'),
              subtitle: const Text(
                'Record a video using your phone camera',
              ),
              leading: const Icon(Icons.camera),
              enabled: !isDesktop(supportWeb: false),
              onTap: () => Navigator.of(context).pop(InsertVideoSource.camera),
            ),
            ListTile(
              title: const Text('Link'),
              subtitle: const Text(
                'Paste a video using a link',
              ),
              leading: const Icon(Icons.link),
              onTap: () => Navigator.of(context).pop(InsertVideoSource.link),
            ),
          ],
        ),
      ),
    );
  }
}

Future<InsertVideoSource?> showSelectVideoSourceDialog({
  required BuildContext context,
}) async {
  final imageSource = await showModalBottomSheet<InsertVideoSource>(
    showDragHandle: true,
    context: context,
    constraints: const BoxConstraints(maxWidth: 640),
    builder: (context) => const SelectVideoSourceDialog(),
  );
  return imageSource;
}
