import 'web_utils.dart';

WebUtils getWebUtils() => StubWebUtils();

class StubWebUtils implements WebUtils {
  @override
  String createImageUrl(List<int> imageBytes) {
    return '';
  }
}