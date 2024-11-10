// ignore_for_file: avoid_print

import 'dart:io';

import 'package:yaml_edit/yaml_edit.dart';

/// Update the version in `pubspec.yaml` of a package.
Future<void> updatePubspecVersion({
  required String newVersion,
  required String pubspecFilePath,
}) async {
  if (newVersion.isEmpty) {
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
  _updatePubspecYamlFile(
    pubspecFile: pubspecFile,
    newVersion: newVersion,
  );
}

/// Update the `pubspec.yaml` package version to [newVersion]
void _updatePubspecYamlFile({
  required File pubspecFile,
  required String newVersion,
}) {
  final yaml = pubspecFile.readAsStringSync();
  final yamlEditor = YamlEditor(yaml)..update(['version'], newVersion);
  pubspecFile.writeAsStringSync(yamlEditor.toString());
}
