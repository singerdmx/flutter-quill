import 'package:meta/meta.dart';
import 'copy_cut_service.dart';
import 'default_copy_cut_service.dart';

@immutable
@experimental
abstract final class CopyCutServiceProvider {
  static CopyCutService _instance = DefaultCopyCutService();

  static CopyCutService get instance => _instance;

  static void setInstance(CopyCutService service) {
    _instance = service;
  }

  static void setInstanceToDefault() {
    _instance = DefaultCopyCutService();
  }
}
