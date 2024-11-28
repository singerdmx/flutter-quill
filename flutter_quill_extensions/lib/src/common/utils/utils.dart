import 'dart:io' show File;

import 'package:flutter/foundation.dart' show immutable;
import 'package:gal/gal.dart';
import 'package:http/http.dart' as http;

import '../../editor/image/widgets/image.dart';
import 'patterns.dart';

bool isBase64(String str) {
  return base64RegExp.hasMatch(str);
}

bool isHttpUrl(String url) {
  try {
    final uri = Uri.parse(url.trim());
    return uri.isScheme('HTTP') || uri.isScheme('HTTPS');
  } catch (_) {
    return false;
  }
}

bool isImageBase64(String imageUrl) {
  return !isHttpUrl(imageUrl) && isBase64(imageUrl);
}

bool isYouTubeUrl(String videoUrl) {
  try {
    final uri = Uri.parse(videoUrl);
    return uri.host == 'www.youtube.com' ||
        uri.host == 'youtube.com' ||
        uri.host == 'youtu.be' ||
        uri.host == 'www.youtu.be';
  } catch (_) {
    return false;
  }
}

enum SaveImageResultMethod { network, localStorage }

@immutable
class SaveImageResult {
  const SaveImageResult({required this.error, required this.method});

  final String? error;
  final SaveImageResultMethod method;
}

Future<SaveImageResult> saveImage({
  required String imageUrl,
}) async {
  final imageFile = File(imageUrl);
  final hasPermission = await Gal.hasAccess();
  if (!hasPermission) {
    await Gal.requestAccess();
  }
  final imageExistsLocally = await imageFile.exists();
  if (!imageExistsLocally) {
    try {
      await _saveImageFromNetwork(
        Uri.parse(appendFileExtensionToImageUrl(imageUrl)),
      );
      return const SaveImageResult(
        error: null,
        method: SaveImageResultMethod.network,
      );
    } catch (e) {
      return SaveImageResult(
        error: e.toString(),
        method: SaveImageResultMethod.network,
      );
    }
  } else {
    try {
      await _saveLocalImage(Uri.parse(imageUrl));
      return const SaveImageResult(
        error: null,
        method: SaveImageResultMethod.localStorage,
      );
    } catch (e) {
      return SaveImageResult(
        error: e.toString(),
        method: SaveImageResultMethod.localStorage,
      );
    }
  }
}

Future<void> _saveImageFromNetwork(Uri imageUrl) async {
  final response = await http.get(
    imageUrl,
  );
  if (response.statusCode != 200) {
    throw Exception('Response to $imageUrl is not successful.');
  }
  final imageBytes = response.bodyBytes;
  await Gal.putImageBytes(imageBytes,
      name: imageUrl.pathSegments.isNotEmpty
          ? imageUrl.pathSegments.last
          : 'image');
}

Future<void> _saveLocalImage(Uri imageUrl) async {
  await Gal.putImage(imageUrl.toString());
}
