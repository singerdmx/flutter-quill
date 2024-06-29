// ignore_for_file: avoid_print

import 'dart:io' show Directory, Process;

Future<void> main(List<String> args) async {
  final generatedDartLocalizationsFolder = Directory('lib/src/l10n/generated');
  if (await generatedDartLocalizationsFolder.exists()) {
    print(
      'Generated directory (${generatedDartLocalizationsFolder.path}) exists, deleting it... 📁',
    );
    await generatedDartLocalizationsFolder.delete(recursive: true);
  }
  print('Running flutter pub get... 📦');
  await Process.run('flutter', ['pub', 'get']);

  print('Running flutter gen-l10n... 🌍');
  await Process.run('flutter', ['gen-l10n']);

  print('Applying Dart fixes to the newly generated files... 🔧');
  await Process.run('dart', ['fix', '--apply', './lib/src/l10n/generated']);

  print('Formatting the newly generated Dart files... ✨');
  await Process.run('dart', ['format', './lib/src/l10n/generated']);
}
