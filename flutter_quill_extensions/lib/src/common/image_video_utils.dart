import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' show QuillDialogTheme;
import 'package:flutter_quill/translations.dart';

import 'utils/patterns.dart';

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
