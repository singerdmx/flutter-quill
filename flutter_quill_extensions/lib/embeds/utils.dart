import 'dart:io' show File;

import 'package:flutter/foundation.dart' show Uint8List, immutable;
import 'package:gal/gal.dart';
import 'package:http/http.dart' as http;

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
class _SaveImageResult {
  const _SaveImageResult({required this.isSuccess, required this.method});

  final bool isSuccess;
  final SaveImageResultMethod method;
}

Future<_SaveImageResult> saveImage(String imageUrl) async {
  final imageFile = File(imageUrl);
  final hasPermission = await Gal.hasAccess();
  final imageExistsLocally = await imageFile.exists();
  if (!hasPermission) {
    await Gal.requestAccess();
  }
  if (!imageExistsLocally) {
    final success = await _saveNetworkImageToLocal(imageUrl);
    return _SaveImageResult(
      isSuccess: success,
      method: SaveImageResultMethod.network,
    );
  }
  final success = await _saveImageLocally(imageFile);
  return _SaveImageResult(
    isSuccess: success,
    method: SaveImageResultMethod.localStorage,
  );
}

Future<bool> _saveNetworkImageToLocal(String imageUrl) async {
  try {
    final response = await http.get(
      Uri.parse(imageUrl),
    );
    if (response.statusCode != 200) {
      return false;
    }
    final imageBytes = response.bodyBytes;
    await Gal.putImageBytes(imageBytes);
    return true;
  } catch (e) {
    return false;
  }
}

Future<Uint8List> _convertFileToUint8List(File file) async {
  try {
    final uint8list = await file.readAsBytes();
    return uint8list;
  } catch (e) {
    return Uint8List(0);
  }
}

Future<bool> _saveImageLocally(File imageFile) async {
  try {
    final imageBytes = await _convertFileToUint8List(imageFile);
    await Gal.putImageBytes(imageBytes);
    return true;
  } catch (e) {
    return false;
  }
}
