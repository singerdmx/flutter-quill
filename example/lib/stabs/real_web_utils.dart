import 'web_utils.dart';
import 'dart:html' as html;

WebUtils getWebUtils() => RealWebUtils();

class RealWebUtils implements WebUtils {
  @override
  String createImageUrl(List<int> imageBytes) {
    final blob = html.Blob([imageBytes], 'image/png');
    return html.Url.createObjectUrlFromBlob(blob);
  }
}
