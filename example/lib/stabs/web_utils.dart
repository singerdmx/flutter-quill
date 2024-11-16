import 'stub_web_utils.dart' if (dart.library.js) 'real_web_utils.dart';

abstract class WebUtils {
  String createImageUrl(List<int> imageBytes);

  factory WebUtils() => getWebUtils();
}
