import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:tuple/tuple.dart';

import '../../models/documents/attribute.dart';
import '../../models/documents/nodes/embeddable.dart';
import '../../models/documents/nodes/leaf.dart' as leaf;
import '../../translations/toolbar.i18n.dart';
import '../../utils/platform.dart';
import '../../utils/string.dart';
import '../controller.dart';
import 'image.dart';
import 'image_resizer.dart';
import 'video_app.dart';
import 'youtube_video_app.dart';

Widget defaultEmbedBuilder(BuildContext context, QuillController controller,
    leaf.Embed node, bool readOnly) {
  assert(!kIsWeb, 'Please provide EmbedBuilder for Web');

  Tuple2<double?, double?>? _widthHeight;
  switch (node.value.type) {
    case BlockEmbed.imageType:
      final imageUrl = standardizeImageUrl(node.value.data);
      var image;
      final style = node.style.attributes['style'];
      if (isMobile() && style != null) {
        final _attrs = parseKeyValuePairs(style.value.toString(), {
          Attribute.mobileWidth,
          Attribute.mobileHeight,
          Attribute.mobileMargin,
          Attribute.mobileAlignment
        });
        if (_attrs.isNotEmpty) {
          assert(
              _attrs[Attribute.mobileWidth] != null &&
                  _attrs[Attribute.mobileHeight] != null,
              'mobileWidth and mobileHeight must be specified');
          final w = double.parse(_attrs[Attribute.mobileWidth]!);
          final h = double.parse(_attrs[Attribute.mobileHeight]!);
          _widthHeight = Tuple2(w, h);
          final m = _attrs[Attribute.mobileMargin] == null
              ? 0.0
              : double.parse(_attrs[Attribute.mobileMargin]!);
          final a = getAlignment(_attrs[Attribute.mobileAlignment]);
          image = Padding(
              padding: EdgeInsets.all(m),
              child: imageByUrl(imageUrl, width: w, height: h, alignment: a));
        }
      }

      if (_widthHeight == null) {
        image = imageByUrl(imageUrl);
        _widthHeight = Tuple2((image as Image).width, image.height);
      }

      if (!readOnly && isMobile()) {
        return GestureDetector(
            onTap: () {
              showDialog(
                  context: context,
                  builder: (context) {
                    final resizeOption = _SimpleDialogItem(
                      icon: Icons.settings_outlined,
                      color: Colors.lightBlueAccent,
                      text: 'Resize'.i18n,
                      onPressed: () {
                        Navigator.pop(context);
                        showCupertinoModalPopup<void>(
                            context: context,
                            builder: (context) {
                              final _screenSize = MediaQuery.of(context).size;
                              return ImageResizer(
                                  onImageResize: (w, h) {
                                    final res = getImageNode(
                                        controller, controller.selection.start);
                                    final attr = replaceStyleString(
                                        getImageStyleString(controller), w, h);
                                    controller.formatText(
                                        res.item1, 1, StyleAttribute(attr));
                                  },
                                  imageWidth: _widthHeight?.item1,
                                  imageHeight: _widthHeight?.item2,
                                  maxWidth: _screenSize.width,
                                  maxHeight: _screenSize.height);
                            });
                      },
                    );
                    final copyOption = _SimpleDialogItem(
                      icon: Icons.copy_all_outlined,
                      color: Colors.cyanAccent,
                      text: 'Copy'.i18n,
                      onPressed: () {
                        final imageNode =
                            getImageNode(controller, controller.selection.start)
                                .item2;
                        final imageUrl = imageNode.value.data;
                        controller.copiedImageUrl =
                            Tuple2(imageUrl, getImageStyleString(controller));
                        Navigator.pop(context);
                      },
                    );
                    final removeOption = _SimpleDialogItem(
                      icon: Icons.delete_forever_outlined,
                      color: Colors.red.shade200,
                      text: 'Remove'.i18n,
                      onPressed: () {
                        final offset =
                            getImageNode(controller, controller.selection.start)
                                .item1;
                        controller.replaceText(offset, 1, '',
                            TextSelection.collapsed(offset: offset));
                        Navigator.pop(context);
                      },
                    );
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(50, 0, 50, 0),
                      child: SimpleDialog(
                          shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10))),
                          children: [resizeOption, copyOption, removeOption]),
                    );
                  });
            },
            child: image);
      }

      if (!readOnly || !isMobile() || isImageBase64(imageUrl)) {
        return image;
      }

      // We provide option menu for mobile platform excluding base64 image
      return _menuOptionsForReadonlyImage(context, imageUrl, image);
    case BlockEmbed.videoType:
      final videoUrl = node.value.data;
      if (videoUrl.contains('youtube.com') || videoUrl.contains('youtu.be')) {
        return YoutubeVideoApp(
            videoUrl: videoUrl, context: context, readOnly: readOnly);
      }
      return VideoApp(videoUrl: videoUrl, context: context, readOnly: readOnly);
    default:
      throw UnimplementedError(
        'Embeddable type "${node.value.type}" is not supported by default '
        'embed builder of QuillEditor. You must pass your own builder function '
        'to embedBuilder property of QuillEditor or QuillField widgets.',
      );
  }
}

Widget _menuOptionsForReadonlyImage(
    BuildContext context, String imageUrl, Image image) {
  return GestureDetector(
      onTap: () {
        showDialog(
            context: context,
            builder: (context) {
              final saveOption = _SimpleDialogItem(
                icon: Icons.save,
                color: Colors.greenAccent,
                text: 'Save'.i18n,
                onPressed: () {
                  imageUrl = appendFileExtensionToImageUrl(imageUrl);
                  GallerySaver.saveImage(imageUrl).then((_) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text('Saved'.i18n)));
                    Navigator.pop(context);
                  });
                },
              );
              final zoomOption = _SimpleDialogItem(
                icon: Icons.zoom_in,
                color: Colors.cyanAccent,
                text: 'Zoom'.i18n,
                onPressed: () {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              ImageTapWrapper(imageUrl: imageUrl)));
                },
              );
              return Padding(
                padding: const EdgeInsets.fromLTRB(50, 0, 50, 0),
                child: SimpleDialog(
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    children: [saveOption, zoomOption]),
              );
            });
      },
      child: image);
}

class _SimpleDialogItem extends StatelessWidget {
  const _SimpleDialogItem(
      {required this.icon,
      required this.color,
      required this.text,
      required this.onPressed,
      Key? key})
      : super(key: key);

  final IconData icon;
  final Color color;
  final String text;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SimpleDialogOption(
      onPressed: onPressed,
      child: Row(
        children: [
          Icon(icon, size: 36, color: color),
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 16),
            child:
                Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
