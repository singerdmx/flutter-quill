import '../../common/utils/platform.dart';

/// Whether the magnifier feature is supported on the current platform.
bool magnifierSupported = isAndroid || isIos;
