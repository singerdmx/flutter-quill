// ignore_for_file: avoid_print

import 'dart:io' show File, exit;

import 'package:yaml_edit/yaml_edit.dart';

/// The list of the packages that which will be used to update the `CHANGELOG.md`
/// and `README.md` files for all the packages
final _packages = [
  './',
  './dart_quill_delta',
  './flutter_quill_extensions',
  './flutter_quill_test',
  './quill_html_converter',
  './quill_pdf_converter',
];

/// A script that should run in the root folder and not inside any other folder
/// it has one task, which update the version for `pubspec.yaml` and `CHANGELOG.md` for all the packages
/// since we have only one CHANGELOG.md file and version, previously we had different `CHANGELOG.md` and `pubspec.yaml` package version
/// for each package
///
/// the new version should be passed in the [args], the script accept only one argument
Future<void> main(List<String> args) async {
  if (args.isEmpty) {
    print('Missing required version argument. Usage: ./script <new-version>');
    exit(1);
  }
  if (args.length > 1) {
    print('Too many arguments. Usage: ./script <new-version>');
    exit(1);
  }
  final newVersion = args[0];
  if (newVersion.isEmpty) {
    print('The new version is empty. Usage: ./script <new-version>');
    exit(1);
  }
  for (final packagePath in _packages) {
    await updatePubspecYamlFile('$packagePath/pubspec.yaml',
        newVersion: newVersion);
    if (packagePath != _packages.first) {
      updateChangelogMD('$packagePath/CHANGELOG.md');
    }
  }
}

/// Update the [pubspecYamlPath] file to update the `version` property from [newVersion]
Future<void> updatePubspecYamlFile(
  String pubspecYamlPath, {
  required String newVersion,
}) async {
  final file = File(pubspecYamlPath);
  final yaml = await file.readAsString();
  final yamlEditor = YamlEditor(yaml)..update(['version'], newVersion);
  await file.writeAsString(yamlEditor.toString());
  print(yamlEditor.toString());
}

/// Read the contents of the root `CHANGELOG.md` file and copy it
/// to the [changeLogFilePath]
Future<void> updateChangelogMD(String changeLogFilePath) async {
  final rootChangeLogFileContent = await File('./CHANGELOG.md').readAsString();
  final changeLogFile = File(changeLogFilePath);
  await changeLogFile.writeAsString(rootChangeLogFileContent);
}
