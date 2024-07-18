// ignore_for_file: avoid_print

import 'dart:io';

void main() async {
  await runCommand('flutter', ['analyze']);

  await runCommand('flutter', ['test']);

  await runCommand('flutter', ['pub', 'publish', '--dry-run']);

  await runCommand('dart', ['fix', '--apply']);

  await runCommand('dart', ['format', '.']);

  await runCommand('dart', ['format', '--set-exit-if-changed', '.']);

  await runCommand(
    'flutter',
    [
      'build',
      'web',
      '--release',
      '--dart-define=CI=true',
    ],
    workingDirectory: 'example',
  );

  print('');

  await runCommand('dart', ['./scripts/ensure_translations_correct.dart']);

  print('');

  print('Checks completed.');
}

Future<void> runCommand(
  String executable,
  List<String> arguments, {
  String? workingDirectory,
}) async {
  print(
      "Running '$executable ${arguments.join(' ')}' in directory '${workingDirectory ?? 'root'}'...");
  final result = await Process.run(executable, arguments,
      workingDirectory: workingDirectory);
  print(result.stdout);
  print(result.stderr);
}
