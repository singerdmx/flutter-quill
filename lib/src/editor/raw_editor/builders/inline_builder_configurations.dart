import '../../../document/nodes/leaf.dart';
import '../../../document/nodes/line.dart';
import '../../../document/nodes/node.dart';
import '../../embed/embed_editor_builder.dart';
import '../../widgets/link.dart';
import 'config/base_builder_configuration.dart';

typedef LaunchURL = void Function(String);
typedef LinkActionPicker = Future<LinkMenuAction> Function(Node);

class InlineBuilderConfiguration extends BaseBuilderConfiguration<Line> {
  InlineBuilderConfiguration({
    required super.textDirection,
    required this.onLaunchUrl,
    required this.linkActionPicker,
    required this.embedBuilder,
    required super.node,
    required super.customRecognizerBuilder,
    required super.customStyleBuilder,
    required super.customLinkPrefixes,
    required super.readOnly,
    required super.styles,
    required this.devicePixelRatioOf,
  });
  final double devicePixelRatioOf;
  final LaunchURL? onLaunchUrl;
  final LinkActionPicker linkActionPicker;
  final EmbedBuilder Function(Embed) embedBuilder;
}
