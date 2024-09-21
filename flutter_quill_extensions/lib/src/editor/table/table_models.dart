import 'package:meta/meta.dart';

@experimental
class TableModel {
  TableModel({required this.columns, required this.rows});

  factory TableModel.fromMap(Map<String, dynamic> json) {
    return TableModel(
      columns: (json['columns'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(
          key,
          ColumnModel.fromMap(
            value,
          ),
        ),
      ),
      rows: (json['rows'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(
          key,
          RowModel.fromMap(
            value,
          ),
        ),
      ),
    );
  }
  Map<String, ColumnModel> columns;
  Map<String, RowModel> rows;

  Map<String, dynamic> toMap() {
    return {
      'columns': columns.map(
        (key, value) => MapEntry(
          key,
          value.toMap(),
        ),
      ),
      'rows': rows.map(
        (key, value) => MapEntry(
          key,
          value.toMap(),
        ),
      ),
    };
  }
}

@experimental
class ColumnModel {
  ColumnModel({required this.id, required this.position});

  factory ColumnModel.fromMap(Map<String, dynamic> json) {
    return ColumnModel(
      id: json['id'],
      position: json['position'],
    );
  }
  String id;
  int position;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'position': position,
    };
  }
}

@experimental
class RowModel {
  // Key is column ID, value is cell content

  RowModel({required this.id, required this.cells});

  factory RowModel.fromMap(Map<String, dynamic> json) {
    return RowModel(
      id: json['id'],
      cells: Map<String, String>.from(json['cells']),
    );
  }
  String id;
  Map<String, String> cells;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cells': cells,
    };
  }
}
