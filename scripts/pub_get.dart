// ignore_for_file: avoid_print

import 'dart:io' show Process;

import 'packages.dart' show repoPackages;

Future<void> main(List<String> args) async {
  for (final package in repoPackages) {
    await Process.run(
      'flutter',
      ['pub', 'get'],
      workingDirectory: package,
    );
  }
  print('Got dependencies!');
}
