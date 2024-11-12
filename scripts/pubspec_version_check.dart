// ignore_for_file: avoid_print

import 'dart:io';

import 'package:yaml/yaml.dart';

/// Validate a version to match with the version in pubspec.yaml file
void checkPubspecVersion({
  required String expectedVersion,
  required String pubspecFilePath,
}) {
  if (expectedVersion.isEmpty) {
    print('The version is empty.');
    exit(1);
  }

  if (pubspecFilePath.isEmpty) {
    print('The pubspec file path is empty.');
    exit(1);
  }
  final pubspecFile = File(pubspecFilePath);
  if (!pubspecFile.existsSync()) {
    print('The pubspec file does not exist: ${pubspecFile.absolute.path}');
    exit(1);
  }
  final pubspecYaml = loadYaml(pubspecFile.readAsStringSync());
  final pubspecVersion = pubspecYaml['version'];
  if (expectedVersion != pubspecVersion) {
    print(
      'The version ($expectedVersion) does not match the version in pubspec.yaml ($pubspecVersion).\n'
      'The pubspec.yaml file is located at: ${pubspecFile.absolute.path}',
    );
    exit(1);
  }
  print('The version ($expectedVersion) match the version in pubspec.yaml');
}
