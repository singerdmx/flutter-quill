import 'package:flutter/widgets.dart'
    show
        BuildContext,
        MediaQuery,
        Offset,
        Overlay,
        Rect,
        RelativeRect,
        RenderBox,
        Size,
        TextSelection;
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';

enum TableOperation {
  addColumn,
  addRow,
  removeColumn,
  removeRow,
}

RelativeRect renderPosition(BuildContext context, [Size? size]) {
  size ??= MediaQuery.sizeOf(context);
  final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
  final button = context.findRenderObject() as RenderBox;
  final position = RelativeRect.fromRect(
    Rect.fromPoints(
      button.localToGlobal(const Offset(0, -65), ancestor: overlay),
      button.localToGlobal(
          button.size.bottomRight(Offset.zero) + const Offset(-50, 0),
          ancestor: overlay),
    ),
    Offset.zero & size * 0.40,
  );
  return position;
}

void insertTable(int rows, int columns, QuillController quillController,
    ChangeSource? changeFrom) {
  final tableData = _createTableData(rows, columns);
  final delta = Delta()..insert({'table': tableData});
  final selection = quillController.selection;
  final replacedLength = selection.extentOffset - selection.baseOffset;
  final newBaseOffset = selection.baseOffset;
  final newExtentOffsetCandidate =
      (selection.baseOffset + 1 - replacedLength).toInt();
  final newExtentOffsetAdjusted =
      newExtentOffsetCandidate < 0 ? 0 : newExtentOffsetCandidate;
  quillController.replaceText(
    newBaseOffset,
    replacedLength,
    delta,
    TextSelection(
        baseOffset: newBaseOffset, extentOffset: newExtentOffsetAdjusted),
  );
}

Map<String, dynamic> _createTableData(int rows, int columns) {
  // Crear el mapa para las columnas
  final columnsData = <String, dynamic>{};
  for (var col = 0; col < columns; col++) {
    final columnId = '${col + 1}';
    columnsData[columnId] = {'id': columnId, 'position': col};
  }

  // Crear el mapa para las filas
  final rowsData = <String, dynamic>{};
  for (var row = 0; row < rows; row++) {
    final rowId = '${row + 1}';
    rowsData[rowId] = {'id': rowId, 'cells': {}};

    for (var col = 0; col < columns; col++) {
      final columnId = '${col + 1}';
      rowsData[rowId]['cells'][columnId] = '';
    }
  }

  // Combinar las columnas y filas en una estructura de tabla
  final tableData = <String, dynamic>{
    'columns': columnsData,
    'rows': rowsData,
  };

  return tableData;
}
