import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gallery_saver/gallery_saver.dart';

import '../../../widgets/image.dart';
import '../../models/documents/nodes/leaf.dart' as leaf;
import '../../utils/platform_helper.dart';
import '../../utils/simple_dialog_item.dart';
import '../../utils/string_helper.dart';
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

      /// We provide option menu only for mobile platform excluding base64
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
                            SimpleDialogItem(
                              icon: Icons.save,
                              color: Colors.greenAccent,
                              text: 'Save',
                              onPressed: () {
                                // TODO: improve this
                                GallerySaver.saveImage(imageUrl).then((_) =>
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                            content: Text('Saved'))));
                              },
                            ),
                            SimpleDialogItem(
                              icon: Icons.zoom_in,
                              color: Colors.cyanAccent,
                              text: 'Zoom',
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
