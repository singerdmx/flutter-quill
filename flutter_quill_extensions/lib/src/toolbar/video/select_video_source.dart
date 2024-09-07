import 'package:flutter/material.dart';
import 'package:flutter_quill/extensions.dart' show isDesktopApp;
import 'package:flutter_quill/translations.dart';

import 'models/video.dart';

class SelectVideoSourceDialog extends StatelessWidget {
  const SelectVideoSourceDialog({super.key});

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
                context.loc.pickAVideoFromYourGallery,
              ),
              leading: const Icon(Icons.photo_sharp),
              onTap: () => Navigator.of(context).pop(InsertVideoSource.gallery),
            ),
            ListTile(
              title: Text(context.loc.camera),
              subtitle: Text(context.loc.recordAVideoUsingYourCamera),
              leading: const Icon(Icons.camera),
              enabled: !isDesktopApp,
              onTap: () => Navigator.of(context).pop(InsertVideoSource.camera),
            ),
            ListTile(
              title: Text(context.loc.link),
              subtitle: Text(
                context.loc.pasteAVideoUsingALink,
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
    builder: (context) =>
        const FlutterQuillLocalizationsWidget(child: SelectVideoSourceDialog()),
  );
  return imageSource;
}
