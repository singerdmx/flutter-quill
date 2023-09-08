import 'package:flutter/material.dart';

class LinkDialogAction {
  LinkDialogAction({required this.builder});

  Widget Function(bool canPress, void Function() applyLink) builder;
}
