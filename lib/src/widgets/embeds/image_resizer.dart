import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../translations/toolbar.i18n.dart';

class ImageResizer extends StatefulWidget {
  const ImageResizer(
      {required this.imageWidth,
      required this.imageHeight,
      required this.maxWidth,
      required this.maxHeight,
      Key? key})
      : super(key: key);

  final double? imageWidth;
  final double? imageHeight;
  final double maxWidth;
  final double maxHeight;

  @override
  _ImageResizerState createState() => _ImageResizerState();
}

class _ImageResizerState extends State<ImageResizer> {
  late double _width;
  late double _height;

  @override
  void initState() {
    super.initState();
    _width = widget.imageWidth ?? widget.maxWidth;
    _height = widget.imageHeight ?? widget.maxHeight;
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoActionSheet(actions: [
      CupertinoActionSheetAction(
        onPressed: () {},
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Card(
              child: Slider(
                value: _width,
                max: widget.maxWidth,
                divisions: 100,
                label: 'Width'.i18n,
                onChanged: (val) {
                  setState(() {
                    _width = val;
                  });
                },
              ),
            )),
      ),
      CupertinoActionSheetAction(
        onPressed: () {},
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Card(
              child: Slider(
                value: _height,
                max: widget.maxHeight,
                divisions: 100,
                label: 'Height'.i18n,
                onChanged: (val) {
                  setState(() {
                    _height = val;
                  });
                },
              ),
            )),
      )
    ]);
  }
}
