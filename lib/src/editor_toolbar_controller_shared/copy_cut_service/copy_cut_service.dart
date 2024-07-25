import 'package:flutter/foundation.dart';

typedef CopyCutAction = Object? Function(dynamic data);

/// An abstraction to make it easy to provide different implementations
/// For copy or cut actions from a Line (just for embeddable blocks)
@immutable
abstract class CopyCutService {
  /// Get the CopyCutAction by the type
  /// of the embeddable (this type is decided by
  /// the property type of that class)
  CopyCutAction getCopyCutAction(String type);
}
