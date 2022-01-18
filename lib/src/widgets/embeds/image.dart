import 'dart:convert';
import 'dart:io' as io;

import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:string_validator/string_validator.dart';

bool isImageBase64(String imageUrl) {
  return !imageUrl.startsWith('http') && isBase64(imageUrl);
}

Widget imageByUrl(String imageUrl,
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
