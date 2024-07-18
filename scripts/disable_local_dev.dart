// ignore_for_file: avoid_print

import 'dart:io' show File;

import 'package:path/path.dart' as path;

import './pub_get.dart' as pub_get show main;
import 'packages.dart' show repoPackages;

Future<void> main(List<String> args) async {
  for (final package in repoPackages) {
    await disable(packageDirectoryPath: package);
  }
  await pub_get.main([]);
  print('Local development for all libraries has been disabled');
}

Future<void> disable({required String packageDirectoryPath}) async {
  final pubspecOverridesFile =
      File(path.join(packageDirectoryPath, 'pubspec_overrides.yaml'));
  if (await pubspecOverridesFile.exists()) {
    await pubspecOverridesFile.delete();
  }
}
