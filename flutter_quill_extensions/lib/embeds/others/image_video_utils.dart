import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' show QuillDialogTheme;
import 'package:flutter_quill/translations.dart';

import '../../utils/patterns.dart';

enum LinkType {
  video,
  image,
}

class TypeLinkDialog extends StatefulWidget {
  const TypeLinkDialog({
    required this.linkType,
    this.dialogTheme,
    this.link,
    this.linkRegExp,
    super.key,
  });

  final QuillDialogTheme? dialogTheme;
  final String? link;
  final RegExp? linkRegExp;
  final LinkType linkType;

  @override
  TypeLinkDialogState createState() => TypeLinkDialogState();
}

class TypeLinkDialogState extends State<TypeLinkDialog> {
  late String _link;
  late TextEditingController _controller;
  RegExp? _linkRegExp;

  @override
  void initState() {
    super.initState();
    _link = widget.link ?? '';
    _controller = TextEditingController(text: _link);

    _linkRegExp = widget.linkRegExp;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: widget.dialogTheme?.dialogBackgroundColor,
      content: TextField(
        keyboardType: TextInputType.url,
        textInputAction: TextInputAction.done,
        maxLines: null,
        style: widget.dialogTheme?.inputTextStyle,
        decoration: InputDecoration(
          labelText: context.loc.pasteLink,
          hintText: widget.linkType == LinkType.image
              ? context.loc.pleaseEnterAValidImageURL
              : context.loc.pleaseEnterAValidVideoURL,
          labelStyle: widget.dialogTheme?.labelTextStyle,
          floatingLabelStyle: widget.dialogTheme?.labelTextStyle,
        ),
        autofocus: true,
        onChanged: _linkChanged,
        controller: _controller,
        onEditingComplete: () {
          if (!_canPress()) {
            return;
          }
          _applyLink();
        },
      ),
      actions: [
        TextButton(
          onPressed: _canPress() ? _applyLink : null,
          child: Text(
            context.loc.ok,
            style: widget.dialogTheme?.labelTextStyle,
          ),
        ),
      ],
    );
  }

  void _linkChanged(String value) {
    setState(() {
      _link = value;
    });
  }

  void _applyLink() {
    Navigator.pop(context, _link.trim());
  }

  RegExp get linkRegExp {
    final customRegExp = _linkRegExp;
    if (customRegExp != null) {
      return customRegExp;
    }
    switch (widget.linkType) {
      case LinkType.video:
        if (youtubeRegExp.hasMatch(_link)) {
          return youtubeRegExp;
        }
        return videoRegExp;
      case LinkType.image:
        return imageRegExp;
    }
  }

  bool _canPress() {
    if (_link.isEmpty) {
      return false;
    }
    if (widget.linkType == LinkType.image) {}
    return _link.isNotEmpty && linkRegExp.hasMatch(_link);
  }
}

// @immutable
// class ImageVideoUtils {
//   const ImageVideoUtils._();
//   static Future<MediaPickSetting?> selectMediaPickSetting(
//     BuildContext context,
//   ) =>
//       showDialog<MediaPickSetting>(
//         context: context,
//         builder: (ctx) => AlertDialog(
//           contentPadding: EdgeInsets.zero,
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               TextButton.icon(
//                 icon: const Icon(
//                   Icons.collections,
//                   color: Colors.orangeAccent,
//                 ),
//                 label: Text('Gallery'.i18n),
//                 onPressed: () => Navigator.pop(ctx,
// MediaPickSetting.gallery),
//               ),
//               TextButton.icon(
//                 icon: const Icon(
//                   Icons.link,
//                   color: Colors.cyanAccent,
//                 ),
//                 label: Text('Link'.i18n),
//                 onPressed: () => Navigator.pop(ctx, MediaPickSetting.link),
//               )
//             ],
//           ),
//         ),
//       );

//   /// For image picking logic
//   static Future<void> handleImageButtonTap(
//     BuildContext context,
//     QuillController controller,
//     ImageSource imageSource,
//     OnImagePickCallback onImagePickCallback, {
//     FilePickImpl? filePickImpl,
//     WebImagePickImpl? webImagePickImpl,
//   }) async {
//     String? imageUrl;
//     if (kIsWeb) {
//       if (webImagePickImpl != null) {
//         imageUrl = await webImagePickImpl(onImagePickCallback);
//         return;
//       }
//       final file = await ImagePicker()
//.pickImage(source: ImageSource.gallery);
//       imageUrl = file?.path;
//       if (imageUrl == null) {
//         return;
//       }
//     } else if (isMobile()) {
//       imageUrl = await _pickImage(imageSource, onImagePickCallback);
//     } else {
//       assert(filePickImpl != null, 'Desktop must provide filePickImpl');
//       imageUrl =
//           await _pickImageDesktop
//(context, filePickImpl!, onImagePickCallback);
//     }

//     if (imageUrl == null) {
//       return;
//     }

//     controller.insertImageBlock(
//       imageUrl: imageUrl,
//     );
//   }

//   static Future<String?> _pickImage(
//     ImageSource source,
//     OnImagePickCallback onImagePickCallback,
//   ) async {
//     final pickedFile = await ImagePicker().pickImage(source: source);
//     if (pickedFile == null) {
//       return null;
//     }

//     return onImagePickCallback(File(pickedFile.path));
//   }

//   static Future<String?> _pickImageDesktop(
//     BuildContext context,
//     FilePickImpl filePickImpl,
//     OnImagePickCallback onImagePickCallback,
//   ) async {
//     final filePath = await filePickImpl(context);
//     if (filePath == null || filePath.isEmpty) return null;

//     final file = File(filePath);
//     return onImagePickCallback(file);
//   }

//   /// For video picking logic
//   static Future<void> handleVideoButtonTap(
//     BuildContext context,
//     QuillController controller,
//     ImageSource videoSource,
//     OnVideoPickCallback onVideoPickCallback, {
//     FilePickImpl? filePickImpl,
//     WebVideoPickImpl? webVideoPickImpl,
//   }) async {
//     final index = controller.selection.baseOffset;
//     final length = controller.selection.extentOffset - index;

//     String? videoUrl;
//     if (kIsWeb) {
//       assert(
//         webVideoPickImpl != null,
//         'Please provide webVideoPickImpl for Web '
//         'in the options of this button',
//       );
//       videoUrl = await webVideoPickImpl!(onVideoPickCallback);
//     } else if (isMobile()) {
//       videoUrl = await _pickVideo(videoSource, onVideoPickCallback);
//     } else {
//       assert(filePickImpl != null, 'Desktop must provide filePickImpl');
//       videoUrl =
//           await _pickVideoDesktop(context, filePickImpl!,
// onVideoPickCallback);
//     }

//     if (videoUrl != null) {
//       controller.replaceText(index, length, BlockEmbed.video(videoUrl),
// null);
//     }
//   }

//   static Future<String?> _pickVideo(
//       ImageSource source, OnVideoPickCallback onVideoPickCallback) async {
//     final pickedFile = await ImagePicker().pickVideo(source: source);
//     if (pickedFile == null) {
//       return null;
//     }

//     return onVideoPickCallback(File(pickedFile.path));
//   }

//   static Future<String?> _pickVideoDesktop(
//       BuildContext context,
//       FilePickImpl filePickImpl,
//       OnVideoPickCallback onVideoPickCallback) async {
//     final filePath = await filePickImpl(context);
//     if (filePath == null || filePath.isEmpty) return null;

//     final file = File(filePath);
//     return onVideoPickCallback(file);
//   }
// }
