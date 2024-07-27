import 'package:flutter/foundation.dart' show immutable;
import 'copy_cut_service.dart';
import 'default_copy_cut_service.dart';

@immutable
class CopyCutServiceProvider {
  const CopyCutServiceProvider._();
  static CopyCutService _instance = DefaultCopyCutService();

  static CopyCutService get instance => _instance;

  static void setInstance(CopyCutService service) {
    _instance = service;
  }

  static void setInstanceToDefault() {
    _instance = DefaultCopyCutService();
  }
}
