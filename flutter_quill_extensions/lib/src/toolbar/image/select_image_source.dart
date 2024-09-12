import 'package:flutter/material.dart';
import 'package:flutter_quill/extensions.dart' show isDesktopApp;
import 'package:flutter_quill/translations.dart';

import '../../editor/image/image_embed_types.dart';

class SelectImageSourceDialog extends StatelessWidget {
  const SelectImageSourceDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 200),
      width: double.infinity,
      child: SingleChildScrollView(
        child: Column(
          children: [
            ListTile(
              title: Text(context.loc.gallery),
              subtitle: Text(
                context.loc.pickAPhotoFromYourGallery,
              ),
              leading: const Icon(Icons.photo_sharp),
              onTap: () => Navigator.of(context).pop(InsertImageSource.gallery),
            ),
            ListTile(
              title: Text(context.loc.camera),
              subtitle: Text(
                context.loc.takeAPhotoUsingYourCamera,
              ),
              leading: const Icon(Icons.camera),
              enabled: !isDesktopApp,
              onTap: () => Navigator.of(context).pop(InsertImageSource.camera),
            ),
            ListTile(
              title: Text(context.loc.link),
              subtitle: Text(
                context.loc.pasteAPhotoUsingALink,
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
    builder: (_) => const FlutterQuillLocalizationsWidget(
      child: SelectImageSourceDialog(),
    ),
  );
  return imageSource;
}
