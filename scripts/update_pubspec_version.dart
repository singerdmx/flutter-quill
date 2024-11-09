// ignore_for_file: avoid_print

import 'dart:io';

import 'package:yaml_edit/yaml_edit.dart';

const _usage =
    'Usage: ./update_pubspec_version.dart <version> <pubspec-file-path>';

/// Update the version in `pubspec.yaml` of a package.
///
/// This script will be used in CI workflow.
Future<void> main(List<String> args) async {
  print('The passed args: $args');
  if (args.isEmpty) {
    print('Missing required arguments. $_usage');
    exit(1);
  }
  if (args.length > 2) {
    print('Too many arguments. $_usage');
    exit(1);
  }
  if (args.length != 2) {
    print('Should only pass 2 arguments. $_usage');
    exit(1);
  }
  final version = args[0];
  if (version.isEmpty) {
    print('The version is empty. $_usage');
    exit(1);
  }
  final pubspecPath = args[1];
  if (pubspecPath.isEmpty) {
    print('The pubspec file path is empty. $_usage');
    exit(1);
  }
  final pubspecFile = File(pubspecPath);
  if (!pubspecFile.existsSync()) {
    print('The pubspec file does not exist: ${pubspecFile.absolute.path}');
    exit(1);
  }
  updatePubspecYamlFile(
    pubspecFile: pubspecFile,
    newVersion: version,
  );
}

/// Update the `pubspec.yaml` package version to [newVersion]
void updatePubspecYamlFile({
  required File pubspecFile,
  required String newVersion,
}) {
  final yaml = pubspecFile.readAsStringSync();
  final yamlEditor = YamlEditor(yaml)..update(['version'], newVersion);
  pubspecFile.writeAsStringSync(yamlEditor.toString());
}
