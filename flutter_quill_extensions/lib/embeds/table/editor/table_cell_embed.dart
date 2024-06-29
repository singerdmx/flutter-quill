import 'dart:async';
import 'package:flutter/material.dart';

class TableCellWidget extends StatefulWidget {
  const TableCellWidget({
    required this.cellId,
    required this.cellData,
    required this.onUpdate,
    required this.onTap,
    super.key,
  });
  final String cellId;
  final String cellData;
  final Function(FocusNode node) onTap;
  final Function(String data) onUpdate;

  @override
  State<TableCellWidget> createState() => _TableCellWidgetState();
}

class _TableCellWidgetState extends State<TableCellWidget> {
  late final TextEditingController controller;
  late final FocusNode node;
  Timer? _debounce;
  @override
  void initState() {
    controller = TextEditingController(text: widget.cellData);
    node = FocusNode();
    super.initState();
  }

  void _onTextChanged() {
    if (!_debounce!.isActive) {
      widget.onUpdate(controller.text);
      return;
    }
  }

  @override
  void dispose() {
    controller
      ..removeListener(_onTextChanged)
      ..dispose();
    node.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      constraints: const BoxConstraints(
        minHeight: 50,
      ),
      padding: const EdgeInsets.only(left: 5, right: 5, top: 5),
      child: TextFormField(
        controller: controller,
        focusNode: node,
        keyboardType: TextInputType.multiline,
        maxLines: null,
        decoration: const InputDecoration.collapsed(hintText: ''),
        onTap: () {
          widget.onTap.call(node);
        },
        onTapAlwaysCalled: true,
        onChanged: (value) {
          _debounce = Timer(
            const Duration(milliseconds: 900),
            _onTextChanged,
          );
        },
      ),
    );
  }
}
