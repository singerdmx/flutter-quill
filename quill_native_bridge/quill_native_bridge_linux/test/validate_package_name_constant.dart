import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:quill_native_bridge_linux/src/constants.dart';
import 'package:yaml/yaml.dart';

void main() {
  test('the package name constant should match the one in pubspec.yaml', () {
    const pubspecYamlFileName = 'pubspec.yaml';
    final pubspecYamlFile = File(pubspecYamlFileName);
    if (!pubspecYamlFile.existsSync()) {
      fail(
        "The '$pubspecYamlFileName' file doesn't exist. Run the test from the package root directory.",
      );
    }
    final pubspecYaml = loadYaml(pubspecYamlFile.readAsStringSync()) as YamlMap;
    final pubspecYamlPackageName = pubspecYaml['name'] as String?;

    expect(kPackageName, pubspecYamlPackageName);
  });
}
