import 'dart:io' show File;

import 'package:flutter/foundation.dart' show immutable;
import '../../logic/services/s_image_saver.dart';

// I would like to orgnize the project structure and the code more
// but here I don't want to change too much since that is a community project

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

bool isImageBase64(String imageUrl) {
  return !isHttpBasedUrl(imageUrl) && isBase64(imageUrl);
}

enum SaveImageResultMethod { network, localStorage }

@immutable
class SaveImageResult {
  const SaveImageResult({required this.isSuccess, required this.method});

  final bool isSuccess;
  final SaveImageResultMethod method;
}

Future<SaveImageResult> saveImage(String imageUrl) async {
  final imageSaverService = ImageSaverService.getInstance();
  final imageFile = File(imageUrl);
  final hasPermission = await imageSaverService.hasAccess();
  final imageExistsLocally = await imageFile.exists();
  if (!hasPermission) {
    await imageSaverService.requestAccess();
  }
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
