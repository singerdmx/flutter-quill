import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill_internal.dart';
import 'package:flutter_quill/translations.dart';

import 'camera_types.dart';

class SelectCameraActionDialog extends StatelessWidget {
  const SelectCameraActionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      width: double.infinity,
      child: SingleChildScrollView(
        child: Column(
          children: [
            ListTile(
              title: Text(context.loc.photo),
              subtitle: Text(
                context.loc.takeAPhotoUsingYourCamera,
              ),
              leading: const Icon(Icons.photo_sharp),
              enabled: !isDesktopApp,
              onTap: () => Navigator.of(context).pop(CameraAction.image),
            ),
            ListTile(
              title: Text(context.loc.video),
              subtitle: Text(
                context.loc.recordAVideoUsingYourCamera,
              ),
              leading: const Icon(Icons.camera),
              enabled: !isDesktopApp,
              onTap: () => Navigator.of(context).pop(CameraAction.video),
            ),
          ],
        ),
      ),
    );
  }
}

Future<CameraAction?> showSelectCameraActionDialog({
  required BuildContext context,
}) async {
  final imageSource = await showModalBottomSheet<CameraAction>(
    showDragHandle: true,
    context: context,
    constraints: const BoxConstraints(maxWidth: 640),
    builder: (context) => const FlutterQuillLocalizationsWidget(
        child: SelectCameraActionDialog()),
  );
  return imageSource;
}
