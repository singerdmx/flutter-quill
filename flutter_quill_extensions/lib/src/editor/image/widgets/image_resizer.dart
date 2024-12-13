import 'package:flutter/cupertino.dart'
    show CupertinoActionSheet, CupertinoActionSheetAction;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show SchedulerBinding;
import 'package:flutter_quill/internal.dart';

class ImageResizer extends StatefulWidget {
  const ImageResizer({
    required this.imageWidth,
    required this.imageHeight,
    required this.maxWidth,
    required this.maxHeight,
    required this.onImageResize,
    super.key,
  });

  final double? imageWidth;
  final double? imageHeight;
  final double maxWidth;
  final double maxHeight;
  final Function(double width, double height) onImageResize;

  @override
  ImageResizerState createState() => ImageResizerState();
}

class ImageResizerState extends State<ImageResizer> {
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
    if (Theme.of(context).isCupertino) {
      return _showCupertinoMenu();
    }
    return _showMaterialMenu();
  }

  Widget _showMaterialMenu() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _widthSlider(),
        _heightSlider(),
      ],
    );
  }

  Widget _showCupertinoMenu() {
    return CupertinoActionSheet(
      actions: [
        CupertinoActionSheetAction(
          onPressed: () {},
          child: _widthSlider(),
        ),
        CupertinoActionSheetAction(
          onPressed: () {},
          child: _heightSlider(),
        )
      ],
    );
  }

  Widget _slider({
    required bool isWidth,
    required ValueChanged<double> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Card(
        child: Slider.adaptive(
          value: isWidth ? _width : _height,
          max: isWidth ? widget.maxWidth : widget.maxHeight,
          divisions: 1000,
          // Might need to be changed
          label: isWidth ? context.loc.width : context.loc.height,
          onChanged: (val) {
            setState(() {
              onChanged(val);
              _resizeImage();
            });
          },
        ),
      ),
    );
  }

  Widget _heightSlider() {
    return _slider(
      isWidth: false,
      onChanged: (value) {
        _height = value;
      },
    );
  }

  Widget _widthSlider() {
    return _slider(
      isWidth: true,
      onChanged: (value) {
        _width = value;
      },
    );
  }

  bool _scheduled = false;

  void _resizeImage() {
    if (_scheduled) {
      return;
    }

    _scheduled = true;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      widget.onImageResize(_width, _height);
      _scheduled = false;
    });
  }
}
