// ignore_for_file: avoid_print

import 'dart:io';

import 'package:yaml/yaml.dart';

const _usage =
    'Usage: ./pubspec_version_check.dart <version> <pubspec-file-path>';

/// Validate a version to match with the version in pubspec.yaml file
void main(List<String> args) {
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
  final pubspecYaml = loadYaml(pubspecFile.readAsStringSync());
  final pubspecVersion = pubspecYaml['version'];
  if (version != pubspecVersion) {
    print(
        'The version ($version) does not match the version in pubspec.yaml ($pubspecVersion).');
    exit(1);
  }
  print('The version ($version) match the version in pubspec.yaml');
}
