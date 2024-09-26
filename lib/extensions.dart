@Deprecated(
  'The extensions.dart file was primarily intended for flutter_quill_extensions '
  'to expose certain internal APIs and should not be used directly, as it is subject to breaking changes.\n'
  'The replacement is flutter_quill_internal.dart which is also for internal use only.',
)
library flutter_quill.extensions;

// This file contains exports that are meant to be used
// internally and are not part of the public API as
// breaking changes can happen

export 'src/common/utils/platform.dart';
export 'src/common/utils/string.dart';
export 'src/common/utils/widgets.dart';
export 'src/document/nodes/leaf.dart';
export 'src/rules/delete.dart';
export 'src/rules/format.dart';
export 'src/rules/insert.dart';
export 'src/rules/rule.dart';
