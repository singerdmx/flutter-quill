import 'dart:io';

import 'package:flutter/services.dart';

import 'temp_file_utils.dart';

/// Extracts a binary file from the assets to a temporary location
/// to be executed.
///
/// Copy the binary file located in the assets directory into a temporary
/// directory, and sets the file to be executable.
///
/// - [assetFilePath] The name of the binary file to extract from assets.
///
/// Returns: The extracted binary file as [File]. Should be removed when no longer needed.
/// Throws: [FileSystemException] can be thrown with `Text file busy`
/// if [_copyAssetTo] called while the file is executing.
Future<File> extractBinaryFromAsset(String assetFilePath) async {
  final extractedBinaryPath = generateTempFilePath(_getFileName(assetFilePath));
  final extractedBinaryFile = File(extractedBinaryPath);

  await _copyAssetTo(
    assetFilePath: assetFilePath,
    destinationFile: extractedBinaryFile,
  );
  await _makeFileExecutable(extractedBinaryPath);

  return extractedBinaryFile;
}

/// Copies the asset file to a destination directory.
///
/// - [assetFilePath] The path of the asset file to be copied.
/// - [destinationFile] The target path where the asset file will be copied.
Future<void> _copyAssetTo({
  required String assetFilePath,
  required File destinationFile,
}) async {
  final assetBytes =
      (await rootBundle.load(assetFilePath)).buffer.asUint8List();

  final parentDirectory = destinationFile.parent;
  if (!(await parentDirectory.exists())) {
    await parentDirectory.create(recursive: true);
  }

  await destinationFile.writeAsBytes(assetBytes);
}

/// Makes the specified file executable.
///
/// - [filePath] The path of the file to make executable.
Future<void> _makeFileExecutable(String filePath) async {
  assert(
    Platform.isLinux,
    'Must be on Linux to add execute permissions with chmod +x.',
  );
  await Process.run('chmod', ['+x', filePath]);
}

/// Extracts the file name from the file path.
///
/// - [filePath] The full path of the file.
///
/// Returns: The name of the file extracted from the path.
String _getFileName(String filePath) => filePath.split('/').last;
