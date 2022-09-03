import 'package:string_validator/string_validator.dart';

bool isImageBase64(String imageUrl) {
  return !imageUrl.startsWith('http') && isBase64(imageUrl);
}
