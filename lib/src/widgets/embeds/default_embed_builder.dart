import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gallery_saver/gallery_saver.dart';

import '../../models/documents/nodes/leaf.dart' as leaf;
import '../../translations/toolbar.i18n.dart';
import '../../utils/platform.dart';
import '../../utils/string.dart';
import 'image.dart';
import 'video_app.dart';
import 'youtube_video_app.dart';

Widget defaultEmbedBuilder(
    BuildContext context, leaf.Embed node, bool readOnly) {
  assert(!kIsWeb, 'Please provide EmbedBuilder for Web');
  switch (node.value.type) {
    case 'image':
      final imageUrl = standardizeImageUrl(node.value.data);
      var image;
      final style = node.style.attributes['style'];
      if (isMobile() && style != null) {
        final _attrs = parseKeyValuePairs(style.value.toString(),
            {'mobileWidth', 'mobileHeight', 'mobileMargin', 'mobileAlignment'});
        if (_attrs.isNotEmpty) {
          assert(
              _attrs['mobileWidth'] != null && _attrs['mobileHeight'] != null,
              'mobileWidth and mobileHeight must be specified');
          final w = double.parse(_attrs['mobileWidth']!);
          final h = double.parse(_attrs['mobileHeight']!);
          final m = _attrs['mobileMargin'] == null
              ? 0.0
              : double.parse(_attrs['mobileMargin']!);
          final a = getAlignment(_attrs['mobileAlignment']);
          image = Padding(
              padding: EdgeInsets.all(m),
              child: imageByUrl(imageUrl, width: w, height: h, alignment: a));
        }
      }
      image ??= imageByUrl(imageUrl);

      if (!readOnly || !isMobile() || isImageBase64(imageUrl)) {
        return image;
      }

      // We provide option menu only for mobile platform excluding base64 image
      return GestureDetector(
          onTap: () {
            showDialog(
                context: context,
                builder: (context) => Padding(
                      padding: const EdgeInsets.fromLTRB(50, 0, 50, 0),
                      child: SimpleDialog(
                          shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10))),
                          children: [
                            _SimpleDialogItem(
                              icon: Icons.save,
                              color: Colors.greenAccent,
                              text: 'Save'.i18n,
                              onPressed: () {
                                // TODO: improve this
                                GallerySaver.saveImage(imageUrl).then((_) =>
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Saved'.i18n))));
                              },
                            ),
                            _SimpleDialogItem(
                              icon: Icons.zoom_in,
                              color: Colors.cyanAccent,
                              text: 'Zoom'.i18n,
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ImageTapWrapper(
                                            imageUrl: imageUrl)));
                              },
                            )
                          ]),
                    ));
          },
          child: image);
    case 'video':
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
