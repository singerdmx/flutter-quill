import 'dart:convert';
import 'dart:io' as io;
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:string_validator/string_validator.dart';
import 'package:tuple/tuple.dart';

import '../../models/documents/attribute.dart';
import '../../models/documents/nodes/leaf.dart';
import '../../models/documents/style.dart';
import '../controller.dart';

const List<String> imageFileExtensions = [
  '.jpeg',
  '.png',
  '.jpg',
  '.gif',
  '.webp',
  '.tif',
  '.heic'
];

bool isImageBase64(String imageUrl) {
  return !imageUrl.startsWith('http') && isBase64(imageUrl);
}

Tuple2<int, Embed> getImageNode(QuillController controller, int offset) {
  var offset = controller.selection.start;
  var imageNode = controller.queryNode(offset);
  if (imageNode == null || !(imageNode is Embed)) {
    offset = max(0, offset - 1);
    imageNode = controller.queryNode(offset);
  }
  if (imageNode != null && imageNode is Embed) {
    return Tuple2(offset, imageNode);
  }

  return throw 'Image node not found by offset $offset';
}

String getImageStyleString(QuillController controller) {
  final String? s = controller
      .getAllSelectionStyles()
      .firstWhere((s) => s.attributes.containsKey(Attribute.style.key),
          orElse: () => Style())
      .attributes[Attribute.style.key]
      ?.value;
  return s ?? '';
}

Image imageByUrl(String imageUrl,
    {double? width,
    double? height,
    AlignmentGeometry alignment = Alignment.center}) {
  if (isImageBase64(imageUrl)) {
    return Image.memory(base64.decode(imageUrl),
        width: width, height: height, alignment: alignment);
  }

  if (imageUrl.startsWith('http')) {
    return Image.network(imageUrl,
        width: width, height: height, alignment: alignment);
  }
  return Image.file(io.File(imageUrl),
      width: width, height: height, alignment: alignment);
}

String standardizeImageUrl(String url) {
  if (url.contains('base64')) {
    return url.split(',')[1];
  }
  return url;
}

/// This is a bug of Gallery Saver Package.
/// It can not save image that's filename does not end with it's file extension
/// like below.
// "https://firebasestorage.googleapis.com/v0/b/eventat-4ba96.appspot.com/o/2019-Metrology-Events.jpg?alt=media&token=bfc47032-5173-4b3f-86bb-9659f46b362a"
/// If imageUrl does not end with it's file extension,
/// file extension is added to image url for saving.
String appendFileExtensionToImageUrl(String url) {
  final endsWithImageFileExtension = imageFileExtensions
      .firstWhere((s) => url.toLowerCase().endsWith(s), orElse: () => '');
  if (endsWithImageFileExtension.isNotEmpty) {
    return url;
  }

  final imageFileExtension = imageFileExtensions
      .firstWhere((s) => url.toLowerCase().contains(s), orElse: () => '');

  return url + imageFileExtension;
}

class ImageTapWrapper extends StatelessWidget {
  const ImageTapWrapper({
    required this.imageUrl,
  });

  final String imageUrl;

  ImageProvider _imageProviderByUrl(String imageUrl) {
    if (imageUrl.startsWith('http')) {
      return NetworkImage(imageUrl);
    }

    return FileImage(io.File(imageUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        constraints: BoxConstraints.expand(
          height: MediaQuery.of(context).size.height,
        ),
        child: Stack(
          children: [
            PhotoView(
              imageProvider: _imageProviderByUrl(imageUrl),
              loadingBuilder: (context, event) {
                return Container(
                  color: Colors.black,
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              },
            ),
            Positioned(
              right: 10,
              top: MediaQuery.of(context).padding.top + 10.0,
              child: InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Stack(
                  children: [
                    Opacity(
                      opacity: 0.2,
                      child: Container(
                        height: 30,
                        width: 30,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child:
                          Icon(Icons.close, color: Colors.grey[400], size: 28),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
