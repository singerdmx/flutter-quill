// ignore_for_file: avoid_print

import 'dart:io' show File;

import 'package:path/path.dart' as path;

import './pub_get.dart' as pub_get show main;
import 'packages.dart' show repoPackages;

Future<void> main(List<String> args) async {
  for (final package in repoPackages) {
    await enable(packageDirectoryPath: package);
  }
  await pub_get.main([]);
  print('Local development for all libraries has been enabled');
}

Future<void> enable({required String packageDirectoryPath}) async {
  final pubspecOverridesFile =
      File(path.join(packageDirectoryPath, 'pubspec_overrides.yaml'));
  final pubspecOverridesDisabledFile =
      File(path.join(packageDirectoryPath, 'pubspec_overrides.yaml.disabled'));
  if (!(await pubspecOverridesDisabledFile.exists())) {
    print('$packageDirectoryPath does not support local development mode.');
    return;
  }
  await pubspecOverridesDisabledFile.copy(pubspecOverridesFile.path);
}
