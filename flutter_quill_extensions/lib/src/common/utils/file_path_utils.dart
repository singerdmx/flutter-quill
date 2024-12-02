String? extractFileNameFromFilePath(String path) {
  if (path.isEmpty) {
    return null;
  }

  final withoutTrailings = !path.contains('/');
  if (withoutTrailings) {
    final onlyFileName = path.contains('.');
    if (onlyFileName) {
      return path;
    }
    return null;
  }

  final fileName = path.split('/').last;

  return fileName.isNotEmpty ? fileName : null;
}

String? extractFileNameFromUrl(String url) {
  // Check if the URL contains a query string or fragment and remove it
  final uri = Uri.parse(url);
  final path = uri.path;

  // Check if the path is empty or just contains slashes
  if (path.isEmpty || path == '/') {
    return null;
  }

  // Get the file name from the path by splitting and getting the last part
  String? fileName = path.split('/').last;

  // Handle cases where there are query parameters
  if (fileName.contains('?')) {
    fileName = fileName.split('?').first;
  }

  // If the path ends with '/', the last part is empty, so return the second last part
  if (fileName.isEmpty && path.split('/').length > 1) {
    fileName = path.split('/').reversed.skip(1).first;
  }

  return fileName;
}
