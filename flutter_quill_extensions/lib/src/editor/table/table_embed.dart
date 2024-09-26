import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:meta/meta.dart';
import '../../common/utils/quill_table_utils.dart';
import 'table_cell_embed.dart';
import 'table_models.dart';

@experimental
@Deprecated(
    'CustomTableEmbed will no longer used and it will be removed in future releases')
class CustomTableEmbed extends CustomBlockEmbed {
  const CustomTableEmbed(String value) : super(tableType, value);

  static const String tableType = 'table';

  static CustomTableEmbed fromDocument(Document document) =>
      CustomTableEmbed(jsonEncode(document.toDelta().toJson()));

  Document get document => Document.fromJson(jsonDecode(data));
}

//Embed builder

@experimental
class QuillEditorTableEmbedBuilder extends EmbedBuilder {
  @override
  String get key => 'table';

  @override
  Widget build(
    BuildContext context,
    QuillController controller,
    Embed node,
    bool readOnly,
    bool inline,
    TextStyle textStyle,
  ) {
    final tableData = node.value.data;
    // ignore: deprecated_member_use_from_same_package
    return TableWidget(
      tableData: tableData,
      controller: controller,
    );
  }
}

@experimental
@Deprecated(
    'TableWidget will no longer used and it will be removed in future releases')
class TableWidget extends StatefulWidget {
  const TableWidget({
    required this.tableData,
    required this.controller,
    super.key,
  });
  final QuillController controller;
  final Map<String, dynamic> tableData;

  @override
  State<TableWidget> createState() => _TableWidgetState();
}

// ignore: deprecated_member_use_from_same_package
class _TableWidgetState extends State<TableWidget> {
  TableModel _tableModel = TableModel(columns: {}, rows: {});
  String _selectedColumnId = '';
  String _selectedRowId = '';

  @override
  void initState() {
    _tableModel = TableModel.fromMap(widget.tableData);
    super.initState();
  }

  void _addColumn() {
    setState(() {
      final id = '${_tableModel.columns.length + 1}';
      final position = _tableModel.columns.length;
      _tableModel.columns[id] = ColumnModel(id: id, position: position);
      _tableModel.rows.forEach((key, row) {
        row.cells[id] = '';
      });
    });
    _updateTable();
  }

  void _addRow() {
    setState(() {
      final id = '${_tableModel.rows.length + 1}';
      final cells = <String, String>{};
      _tableModel.columns.forEach((key, column) {
        cells[key] = '';
      });
      _tableModel.rows[id] = RowModel(id: id, cells: cells);
    });
    _updateTable();
  }

  void _removeColumn(String columnId) {
    setState(() {
      _tableModel.columns.remove(columnId);
      _tableModel.rows.forEach((key, row) {
        row.cells.remove(columnId);
      });
      if (_selectedRowId == _selectedColumnId) {
        _selectedRowId = '';
      }
      _selectedColumnId = '';
    });
    _updateTable();
  }

  void _removeRow(String rowId) {
    setState(() {
      _tableModel.rows.remove(rowId);
      _selectedRowId = '';
    });
    _updateTable();
  }

  void _updateCell(String columnId, String rowId, String data) {
    setState(() {
      _tableModel.rows[rowId]!.cells[columnId] = data;
    });
    _updateTable();
  }

  void _updateTable() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final offset = getEmbedNode(
        widget.controller,
        widget.controller.selection.start,
      ).offset;
      final delta = Delta()..insert({'table': _tableModel.toMap()});
      widget.controller.replaceText(
        offset,
        1,
        delta,
        TextSelection.collapsed(
          offset: offset,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        decoration: BoxDecoration(
            border: Border.all(
                color: Theme.of(context).textTheme.bodyMedium?.color ??
                    Colors.black)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () async {
                final position = renderPosition(context);
                await showMenu<TableOperation>(
                    context: context,
                    position: position,
                    items: [
                      const PopupMenuItem(
                        value: TableOperation.addColumn,
                        child: Text('Add column'),
                      ),
                      const PopupMenuItem(
                        value: TableOperation.addRow,
                        child: Text('Add row'),
                      ),
                      const PopupMenuItem(
                        value: TableOperation.removeColumn,
                        child: Text('Delete column'),
                      ),
                      const PopupMenuItem(
                        value: TableOperation.removeRow,
                        child: Text('Delete row'),
                      ),
                    ]).then((value) {
                  if (value != null) {
                    if (value == TableOperation.addRow) {
                      _addRow();
                    }
                    if (value == TableOperation.addColumn) {
                      _addColumn();
                    }
                    if (value == TableOperation.removeColumn) {
                      _removeColumn(_selectedColumnId);
                    }
                    if (value == TableOperation.removeRow) {
                      _removeRow(_selectedRowId);
                    }
                  }
                });
              },
            ),
            const Divider(
              color: Colors.white,
              height: 1,
            ),
            Table(
              border: const TableBorder.symmetric(
                  inside: BorderSide(color: Colors.white)),
              children: _buildTableRows(),
            ),
          ],
        ),
      ),
    );
  }

  List<TableRow> _buildTableRows() {
    final rows = <TableRow>[];

    _tableModel.rows.forEach((rowId, rowModel) {
      final rowCells = <Widget>[];
      final rowKey = rowId;
      rowModel.cells.forEach((key, value) {
        if (key != 'id') {
          final columnId = key;
          final data = value;
          // ignore: deprecated_member_use_from_same_package
          rowCells.add(TableCellWidget(
            cellId: rowKey,
            onTap: (node) {
              setState(() {
                _selectedColumnId = columnId;
                _selectedRowId = rowModel.id;
              });
            },
            cellData: data,
            onUpdate: (data) => _updateCell(columnId, rowKey, data),
          ));
        }
      });
      rows.add(TableRow(children: rowCells));
    });
    return rows;
  }
}
