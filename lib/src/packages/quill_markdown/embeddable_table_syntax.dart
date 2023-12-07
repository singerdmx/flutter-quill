import 'package:charcode/charcode.dart';
import 'package:markdown/markdown.dart';

import '../../../flutter_quill.dart' hide Node;

/// Parses markdown table and saves the table markdown content into the element attributes.
class EmbeddableTableSyntax extends BlockSyntax {
  /// @nodoc
  const EmbeddableTableSyntax();
  static const _base = TableSyntax();

  @override
  bool canEndBlock(BlockParser parser) => false;

  @override
  RegExp get pattern => _base.pattern;

  @override
  bool canParse(BlockParser parser) => _base.canParse(parser);

  /// Parses a table into its three parts:
  ///
  /// * a head row of head cells (`<th>` cells)
  /// * a divider of hyphens and pipes (not rendered)
  /// * many body rows of body cells (`<td>` cells)
  @override
  Node? parse(BlockParser parser) {
    final columnCount = _columnCount(parser.next!.content);
    final headCells = _columnCount(parser.current.content);
    final valBuf =
        StringBuffer('${parser.current.content}\n${parser.next!.content}');
    parser.advance();
    if (columnCount != headCells) {
      return null;
    }

    // advance header and divider of hyphens.
    parser.advance();

    while (!parser.isDone && !BlockSyntax.isAtBlockEnd(parser)) {
      valBuf.write('\n${parser.current.content}');
      parser.advance();
    }

    return Element.empty(EmbeddableTable.tableType)
      ..attributes['data'] = valBuf.toString();
  }

  int _columnCount(String line) {
    final startIndex = _walkPastOpeningPipe(line);

    var endIndex = line.length - 1;
    while (endIndex > 0) {
      final ch = line.codeUnitAt(endIndex);
      if (ch == $pipe) {
        endIndex--;
        break;
      }
      if (ch != $space && ch != $tab) {
        break;
      }
      endIndex--;
    }

    return line.substring(startIndex, endIndex + 1).split('|').length;
  }

  int _walkPastWhitespace(String line, int index) {
    while (index < line.length) {
      final ch = line.codeUnitAt(index);
      if (ch != $space && ch != $tab) {
        break;
      }
      //ignore: parameter_assignments
      index++;
    }
    return index;
  }

  int _walkPastOpeningPipe(String line) {
    var index = 0;
    while (index < line.length) {
      final ch = line.codeUnitAt(index);
      if (ch == $pipe) {
        index++;
        index = _walkPastWhitespace(line, index);
      }
      if (ch != $space && ch != $tab) {
        // No leading pipe.
        break;
      }
      index++;
    }
    return index;
  }
}

/// An [Embeddable] table that can used to render a table in quill_editor
class EmbeddableTable extends BlockEmbed {
  /// @nodoc
  EmbeddableTable(String data) : super(tableType, data);

  /// [Embeddable] type
  static const tableType = 'x-embed-table';

  /// Create from markdown.
  //ignore: prefer_constructors_over_static_methods
  static EmbeddableTable fromMdSyntax(Map<String, String> attributes) =>
      EmbeddableTable(attributes['data']!);

  /// Outputs table markdown to output.
  static void toMdSyntax(Embed embed, StringSink out) {
    out
      ..writeln(embed.value.data)
      ..writeln();
  }
}
