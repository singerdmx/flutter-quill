import 'dart:convert';
import 'dart:io' show File;

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:photo_view/photo_view.dart';

import '../embed_types.dart';
import '../utils.dart';

const List<String> imageFileExtensions = [
  '.jpeg',
  '.png',
  '.jpg',
  '.gif',
  '.webp',
  '.tif',
  '.heic'
];

String getImageStyleString(QuillController controller) {
  final String? s = controller
      .getAllSelectionStyles()
      .firstWhere((s) => s.attributes.containsKey(Attribute.style.key),
          orElse: Style.new)
      .attributes[Attribute.style.key]
      ?.value;
  return s ?? '';
}

Image getQuillImageByUrl(
  String imageUrl, {
  required ImageEmbedBuilderProviderBuilder? imageProviderBuilder,
  required ImageErrorWidgetBuilder? imageErrorWidgetBuilder,
  double? width,
  double? height,
  AlignmentGeometry alignment = Alignment.center,
}) {
  if (isImageBase64(imageUrl)) {
    return Image.memory(base64.decode(imageUrl),
        width: width, height: height, alignment: alignment);
  }

  if (imageProviderBuilder != null) {
    return Image(
      image: imageProviderBuilder(imageUrl),
      width: width,
      height: height,
      alignment: alignment,
      errorBuilder: imageErrorWidgetBuilder,
    );
  }
  if (isHttpBasedUrl(imageUrl)) {
    return Image.network(
      imageUrl,
      width: width,
      height: height,
      alignment: alignment,
      errorBuilder: imageErrorWidgetBuilder,
    );
  }
  return Image.file(
    File(imageUrl),
    width: width,
    height: height,
    alignment: alignment,
    errorBuilder: imageErrorWidgetBuilder,
  );
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
    required this.imageProviderBuilder,
    required this.imageErrorWidgetBuilder,
  });

  final String imageUrl;
  final ImageEmbedBuilderProviderBuilder? imageProviderBuilder;
  final ImageEmbedBuilderErrorWidgetBuilder? imageErrorWidgetBuilder;

  ImageProvider _imageProviderByUrl(
    String imageUrl, {
    required ImageEmbedBuilderProviderBuilder? customImageProviderBuilder,
  }) {
    if (customImageProviderBuilder != null) {
      return customImageProviderBuilder(imageUrl);
    }
    if (isHttpBasedUrl(imageUrl)) {
      return NetworkImage(imageUrl);
    }

    return FileImage(File(imageUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        constraints: BoxConstraints.expand(
          height: MediaQuery.sizeOf(context).height,
        ),
        child: Stack(
          children: [
            PhotoView(
              imageProvider: _imageProviderByUrl(
                imageUrl,
                customImageProviderBuilder: imageProviderBuilder,
              ),
              errorBuilder: imageErrorWidgetBuilder,
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
              top: MediaQuery.paddingOf(context).top + 10.0,
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
