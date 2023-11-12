import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_quill/translations.dart';

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
  final Function(double, double) onImageResize;

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
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return _showCupertinoMenu();
      case TargetPlatform.android:
        return _showMaterialMenu();
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        return _showMaterialMenu();
      default:
        throw UnsupportedError(
          'Not supposed to be invoked for $defaultTargetPlatform',
        );
    }
  }

  Widget _showMaterialMenu() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [_widthSlider(), _heightSlider()],
    );
  }

  Widget _showCupertinoMenu() {
    return CupertinoActionSheet(actions: [
      CupertinoActionSheetAction(
        onPressed: () {},
        child: _widthSlider(),
      ),
      CupertinoActionSheetAction(
        onPressed: () {},
        child: _heightSlider(),
      )
    ]);
  }

  Widget _slider({
    required double value,
    required double max,
    required bool isHeight,
    required ValueChanged<double> onChanged,
  }) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Card(
          child: Slider(
            value: value,
            max: max,
            divisions: 1000,
            // Might need to be changed
            label: isHeight ? context.loc.height : context.loc.width,
            onChanged: (val) {
              setState(() {
                onChanged(val);
                _resizeImage();
              });
            },
          ),
        ));
  }

  Widget _heightSlider() {
    return _slider(
      value: _height,
      max: widget.maxHeight,
      isHeight: true,
      onChanged: (value) {
        _height = value;
      },
    );
  }

  Widget _widthSlider() {
    return _slider(
      value: _width,
      max: widget.maxWidth,
      isHeight: false,
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
