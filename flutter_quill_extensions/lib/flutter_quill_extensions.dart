library flutter_quill_extensions;

import 'package:flutter_quill/flutter_quill.dart';

import 'embeds/builders.dart';

export 'embeds/toolbar.dart';
export 'embeds/builders.dart';
export 'embeds/embed_types.dart';
export 'embeds/utils.dart';

class FlutterQuillEmbeds {
  static List<EmbedBuilder> get builders => [
        ImageEmbedBuilder(),
        VideoEmbedBuilder(),
        FormulaEmbedBuilder(),
      ];
}
