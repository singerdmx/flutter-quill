// ignore_for_file: avoid_print

import 'dart:io' show File;

import 'package:yaml_edit/yaml_edit.dart';

import '../version.dart';

/// The list of the packages that which will be used to update the `CHANGELOG.md`
/// and the `README.md`, always make `'./'` at the top
///
/// since we should not update the `CHANGELOG.md` of
/// the `flutter_quill` since it used
/// in all the packages
final packages = [
  './',
  './dart_quill_delta',
  './flutter_quill_extensions',
  './flutter_quill_test',
  './quill_html_converter',
  './quill_pdf_converter',
];

/// A script that should run in the root folder of the repo and not inside
/// the scripts folder
///
/// it will update the versions and changelogs, the versions will be all the same
/// from the `version.dart` and the changelogs will be use the same one from the
/// root folder of `flutter_quill`
Future<void> main(List<String> args) async {
  for (final packagePath in packages) {
    await updatePubspecYamlFile('$packagePath/pubspec.yaml');
    if (packagePath != packages.first) {
      updateChangelogMD('$packagePath/CHANGELOG.md');
    }
  }
}

/// Read the `version` variable from `version.dart`
/// and update the package version
///  in `pubspec.yaml` from the [pubspecYamlPath]
Future<void> updatePubspecYamlFile(String pubspecYamlPath) async {
  final file = File(pubspecYamlPath);
  final yaml = await file.readAsString();
  final yamlEditor = YamlEditor(yaml)..update(['version'], version);
  await file.writeAsString(yamlEditor.toString());
  print(yamlEditor.toString());
}

/// Copy the text from the root `CHANGELOG.md` and paste it to the one
/// from the [changeLogPath]
Future<void> updateChangelogMD(String changeLogPath) async {
  final changeLog = await File('./CHANGELOG.md').readAsString();
  final currentFile = File(changeLogPath);
  await currentFile.writeAsString(changeLog);
}
