import 'dart:io' show File;

import 'package:yaml_edit/yaml_edit.dart';

// You must run this script in the root folder of the repo and not inside the scripts

// ignore: unused_import
import '../version.dart';

Future<void> main(List<String> args) async {
  await updatePubspecYamlFile('./pubspec.yaml');
  await updatePubspecYamlFile('./flutter_quill_extensions/pubspec.yaml');
  await updatePubspecYamlFile('./flutter_quill_test/pubspec.yaml');
  await updatePubspecYamlFile('./packages/quill_html_converter/pubspec.yaml');
}

Future<void> updatePubspecYamlFile(String path) async {
  final file = File(path);
  final yaml = await file.readAsString();
  final yamlEditor = YamlEditor(yaml)..update(['version'], version);
  await file.writeAsString(yamlEditor.toString());
  // ignore: avoid_print
  print(yamlEditor.toString());
}
