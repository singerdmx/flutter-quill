import 'dart:io' show File;

import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter/widgets.dart' show Alignment;
import 'package:flutter_quill/extensions.dart' as base;
import 'package:flutter_quill/flutter_quill.dart' show Attribute, Node;
import '../../logic/extensions/attribute.dart';
import '../../logic/services/image_saver/s_image_saver.dart';
import '../embeds/widgets/image.dart';

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
  required ImageSaverService imageSaverService,
}) async {
  final imageFile = File(imageUrl);
  final hasPermission = await imageSaverService.hasAccess();
  if (!hasPermission) {
    await imageSaverService.requestAccess();
  }
  final imageExistsLocally = await imageFile.exists();
  if (!imageExistsLocally) {
    try {
      await imageSaverService.saveImageFromNetwork(
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
  }
  try {
    await imageSaverService.saveLocalImage(imageUrl);
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

(
  OptionalSize elementSize,
  double? margin,
  Alignment alignment,
) getElementAttributes(
  Node node,
) {
  var elementSize = const OptionalSize(null, null);
  var elementAlignment = Alignment.center;
  double? elementMargin;

  // Usually double value
  final heightValue = double.tryParse(
      node.style.attributes[Attribute.height.key]?.value.toString() ?? '');
  final widthValue = double.tryParse(
      node.style.attributes[Attribute.width.key]?.value.toString() ?? '');

  if (heightValue != null) {
    elementSize = elementSize.copyWith(
      height: heightValue,
    );
  }
  if (widthValue != null) {
    elementSize = elementSize.copyWith(
      width: widthValue,
    );
  }

  final cssStyle = node.style.attributes['style'];

  if (cssStyle != null) {
    final attrs = base.isMobile(supportWeb: false)
        ? base.parseKeyValuePairs(cssStyle.value.toString(), {
            AttributeExt.mobileWidth.key,
            AttributeExt.mobileHeight.key,
            AttributeExt.mobileMargin.key,
            AttributeExt.mobileAlignment.key,
          })
        : base.parseKeyValuePairs(cssStyle.value.toString(), {
            Attribute.width.key,
            Attribute.height.key,
            'margin',
            'alignment',
          });
    if (attrs.isEmpty) {
      return (elementSize, elementMargin, elementAlignment);
    }

    // It css value as string but we will try to support it anyway

    // TODO: This could be improved much better
    final cssHeightValue = double.tryParse(((base.isMobile(supportWeb: false)
                ? attrs[AttributeExt.mobileHeight.key]
                : attrs[Attribute.height.key]) ??
            '')
        .replaceFirst('px', ''));
    final cssWidthValue = double.tryParse(((!base.isMobile(supportWeb: false)
                ? attrs[Attribute.width.key]
                : attrs[AttributeExt.mobileWidth.key]) ??
            '')
        .replaceFirst('px', ''));

    if (cssHeightValue != null) {
      elementSize = elementSize.copyWith(height: cssHeightValue);
    }
    if (cssWidthValue != null) {
      elementSize = elementSize.copyWith(width: cssWidthValue);
    }

    elementAlignment = base.getAlignment(base.isMobile(supportWeb: false)
        ? attrs[AttributeExt.mobileAlignment.key]
        : attrs['alignment']);
    final margin = (base.isMobile(supportWeb: false)
        ? double.tryParse(AttributeExt.mobileMargin.key)
        : double.tryParse('margin'));
    if (margin != null) {
      elementMargin = margin;
    }
  }

  return (elementSize, elementMargin, elementAlignment);
}

@immutable
class OptionalSize {
  const OptionalSize(
    this.width,
    this.height,
  );

  /// If non-null, requires the child to have exactly this width.
  /// If null, the child is free to choose its own width.
  final double? width;

  /// If non-null, requires the child to have exactly this height.
  /// If null, the child is free to choose its own height.
  final double? height;

  OptionalSize copyWith({
    double? width,
    double? height,
  }) {
    return OptionalSize(
      width ?? this.width,
      height ?? this.height,
    );
  }
}
