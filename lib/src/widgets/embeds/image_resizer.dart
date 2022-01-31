import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ImageResizer extends StatefulWidget {
  const ImageResizer({Key? key}) : super(key: key);

  @override
  _ImageResizerState createState() => _ImageResizerState();
}

class _ImageResizerState extends State<ImageResizer> {
  @override
  Widget build(BuildContext context) {
    return CupertinoActionSheet(actions: [
      CupertinoActionSheetAction(
        onPressed: () {},
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Card(
              child: Slider(
                value: 50,
                max: 100,
                divisions: 5,
                onChanged: (val) {},
              ),
            )),
      ),
      CupertinoActionSheetAction(
        onPressed: () {},
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Card(
              child: Slider(
                value: 10,
                max: 100,
                divisions: 5,
                onChanged: (val) {},
              ),
            )),
      )
    ]);
  }
}
