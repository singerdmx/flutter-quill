// ignore_for_file: avoid_print

import 'dart:io' show File;

import 'package:yaml_edit/yaml_edit.dart';

// You must run this script in the root folder of the repo and not inside the scripts

import '../version.dart';

final packages = [
  './',
  './flutter_quill_extensions',
  './flutter_quill_test',
  './quill_html_converter',
  './quill_pdf_converter',
];

Future<void> main(List<String> args) async {
  for (final element in packages) {
    await updatePubspecYamlFile('$element/pubspec.yaml');
    if (element != packages.first) {
      updateChangelogMD(element);
    }
  }
}

Future<void> updatePubspecYamlFile(String path) async {
  final file = File(path);
  final yaml = await file.readAsString();
  final yamlEditor = YamlEditor(yaml)..update(['version'], version);
  await file.writeAsString(yamlEditor.toString());
  print(yamlEditor.toString());
}

Future<void> updateChangelogMD(String path) async {
  final changeLog = await File('./CHANGELOG.md').readAsString();
  final currentFile = File('$path/CHANGELOG.md');
  await currentFile.writeAsString(changeLog);
}
