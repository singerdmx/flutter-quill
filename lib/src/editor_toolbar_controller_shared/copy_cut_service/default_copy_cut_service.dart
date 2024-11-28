import 'package:meta/meta.dart';

import '../../document/nodes/leaf.dart';
import 'copy_cut_service.dart';

/// Default implementation for [CopyCutService]
///
/// This implementation always return the default embed character
/// replacemenet ([\uFFFC]) to work with the embeds from the internal
/// flutter quill plugins
@experimental
class DefaultCopyCutService extends CopyCutService {
  @override
  CopyCutAction getCopyCutAction(String type) {
    return (data) => Embed.kObjectReplacementCharacter;
  }
}
