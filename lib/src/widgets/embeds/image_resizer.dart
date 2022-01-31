import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../translations/toolbar.i18n.dart';

class ImageResizer extends StatefulWidget {
  const ImageResizer(
      {required this.imageWidth,
      required this.imageHeight,
      required this.maxWidth,
      required this.maxHeight,
      required this.onImageResize,
      Key? key})
      : super(key: key);

  final double? imageWidth;
  final double? imageHeight;
  final double maxWidth;
  final double maxHeight;
  final Function(double, double) onImageResize;

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
                divisions: 1000,
                label: 'Width'.i18n,
                onChanged: (val) {
                  setState(() {
                    _width = val;
                    _resizeImage();
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
                divisions: 1000,
                label: 'Height'.i18n,
                onChanged: (val) {
                  setState(() {
                    _height = val;
                    _resizeImage();
                  });
                },
              ),
            )),
      )
    ]);
  }

  bool _scheduled = false;

  void _resizeImage() {
    if (_scheduled) {
      return;
    }

    _scheduled = true;
    SchedulerBinding.instance!.addPostFrameCallback((_) {
      widget.onImageResize(_width, _height);
      _scheduled = false;
    });
  }
}
