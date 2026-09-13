// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

void main() async {
  await runCommand('flutter', ['analyze']);

  await runCommand('flutter', ['test']);

  await runCommand('flutter', ['pub', 'publish', '--dry-run']);

  await runCommand('dart', ['fix', '--apply']);

  // Format only files that are modified but not yet committed, to avoid
  // reformatting the entire repository (e.g. after a Dart SDK formatter
  // update changes the default formatting style).
  final changedDartFiles = await uncommittedDartFiles();
  if (changedDartFiles.isEmpty) {
    print('No modified Dart files to format; skipping `dart format`.');
  } else {
    await runCommand('dart', ['format', ...changedDartFiles]);

    await runCommand('dart', [
      'format',
      '--set-exit-if-changed',
      ...changedDartFiles,
    ]);
  }

  await runCommand('flutter', [
    'build',
    'web',
    '--release',
    '--dart-define=CI=true',
  ], workingDirectory: 'example');

  print('');

  await runCommand('dart', ['./scripts/translations_check.dart']);

  print('');

  print('Checks completed.');
}

/// Returns the repo-relative paths of Dart files that are modified but not yet
/// committed: tracked changes (staged or unstaged) relative to `HEAD`, plus
/// untracked files. Deleted files are excluded so they aren't passed to
/// `dart format`.
Future<List<String>> uncommittedDartFiles() async {
  final tracked = await Process.run('git', ['diff', '--name-only', 'HEAD']);
  final untracked = await Process.run('git', [
    'ls-files',
    '--others',
    '--exclude-standard',
  ]);

  final paths = <String>{
    ...const LineSplitter().convert(tracked.stdout as String),
    ...const LineSplitter().convert(untracked.stdout as String),
  };

  return paths
      .where((path) => path.endsWith('.dart'))
      .where((path) => File(path).existsSync())
      .toList();
}

Future<void> runCommand(
  String executable,
  List<String> arguments, {
  String? workingDirectory,
}) async {
  print(
    "Running '$executable ${arguments.join(' ')}' in directory '${workingDirectory ?? 'root'}'...",
  );
  final result = await Process.run(
    executable,
    arguments,
    workingDirectory: workingDirectory,
  );
  print(result.stdout);
  print(result.stderr);
}
