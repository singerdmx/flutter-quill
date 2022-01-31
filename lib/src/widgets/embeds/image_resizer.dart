import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../translations/toolbar.i18n.dart';

class ImageResizer extends StatefulWidget {
  const ImageResizer(
      {required this.imageWidth, required this.imageHeight, Key? key})
      : super(key: key);

  final double? imageWidth;
  final double? imageHeight;

  @override
  _ImageResizerState createState() => _ImageResizerState();
}

class _ImageResizerState extends State<ImageResizer> {
  late double _width;
  late double _height;
  late double _maxWidth;
  late double _maxHeight;

  @override
  Widget build(BuildContext context) {
    _maxWidth = MediaQuery.of(context).size.width;
    _maxHeight = MediaQuery.of(context).size.height;
    _width = widget.imageWidth ?? _maxWidth;
    _height = widget.imageHeight ?? _maxHeight;

    return CupertinoActionSheet(actions: [
      CupertinoActionSheetAction(
        onPressed: () {},
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Card(
              child: Slider(
                value: _width,
                max: _maxWidth,
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
                max: _maxHeight,
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
