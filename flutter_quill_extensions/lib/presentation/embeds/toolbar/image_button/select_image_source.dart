import 'package:flutter/material.dart';
import 'package:flutter_quill/extensions.dart' show isDesktop;

import '../../embed_types/image.dart';

class SelectImageSourceDialog extends StatelessWidget {
  const SelectImageSourceDialog({super.key});

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
                'Pick a photo from your gallery',
              ),
              leading: const Icon(Icons.photo_sharp),
              onTap: () => Navigator.of(context).pop(InsertImageSource.gallery),
            ),
            ListTile(
              title: const Text('Camera'),
              subtitle: const Text(
                'Take a photo using your phone camera',
              ),
              leading: const Icon(Icons.camera),
              enabled: !isDesktop(supportWeb: false),
              onTap: () => Navigator.of(context).pop(InsertImageSource.camera),
            ),
            ListTile(
              title: const Text('Link'),
              subtitle: const Text(
                'Paste a photo using a link',
              ),
              leading: const Icon(Icons.link),
              onTap: () => Navigator.of(context).pop(InsertImageSource.link),
            ),
          ],
        ),
      ),
    );
  }
}

Future<InsertImageSource?> showSelectImageSourceDialog({
  required BuildContext context,
}) async {
  final imageSource = await showModalBottomSheet<InsertImageSource>(
    showDragHandle: true,
    context: context,
    constraints: const BoxConstraints(maxWidth: 640),
    builder: (_) => const SelectImageSourceDialog(),
  );
  return imageSource;
}
