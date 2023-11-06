import 'dart:io' show File;

import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter/widgets.dart' show BuildContext;
import '../../logic/models/config/shared_configurations.dart';

RegExp _base64 = RegExp(
  r'^(?:[A-Za-z0-9+\/]{4})*(?:[A-Za-z0-9+\/]{2}==|[A-Za-z0-9+\/]{3}=|[A-Za-z0-9+\/]{4})$',
);

bool isBase64(String str) {
  return _base64.hasMatch(str);
}

bool isHttpBasedUrl(String url) {
  try {
    final uri = Uri.parse(url.trim());
    return uri.isScheme('HTTP') || uri.isScheme('HTTPS');
  } catch (_) {
    return false;
  }
}

bool isImageBase64(String imageUrl) {
  return !isHttpBasedUrl(imageUrl) && isBase64(imageUrl);
}

bool isYouTubeUrl(String videoUrl) {
  try {
    final uri = Uri.parse(videoUrl);
    return uri.host == 'www.youtube.com' ||
        uri.host == 'youtube.com' ||
        uri.host == 'youtu.be';
  } catch (_) {
    return false;
  }
}

enum SaveImageResultMethod { network, localStorage }

@immutable
class SaveImageResult {
  const SaveImageResult({required this.isSuccess, required this.method});

  final bool isSuccess;
  final SaveImageResultMethod method;
}

Future<SaveImageResult> saveImage({
  required String imageUrl,
  required BuildContext context,
}) async {
  final imageSaverService =
      QuillSharedExtensionsConfigurations.get(context: context)
          .imageSaverService;
  final imageFile = File(imageUrl);
  final hasPermission = await imageSaverService.hasAccess();
  if (!hasPermission) {
    await imageSaverService.requestAccess();
  }
  final imageExistsLocally = await imageFile.exists();
  if (!imageExistsLocally) {
    try {
      await imageSaverService.saveImageFromNetwork(
        Uri.parse(imageUrl),
      );
      return const SaveImageResult(
        isSuccess: true,
        method: SaveImageResultMethod.network,
      );
    } catch (e) {
      return const SaveImageResult(
        isSuccess: false,
        method: SaveImageResultMethod.network,
      );
    }
  }
  try {
    await imageSaverService.saveLocalImage(imageUrl);
    return const SaveImageResult(
      isSuccess: true,
      method: SaveImageResultMethod.localStorage,
    );
  } catch (e) {
    return const SaveImageResult(
      isSuccess: false,
      method: SaveImageResultMethod.localStorage,
    );
  }
}
