// ignore_for_file: avoid_print

import 'dart:io';

import './update_changelog_version.dart' as update_changelog_version;
import './update_pubspec_version.dart' as update_pubspec_version;

// NOTE: This script is for the maintainers.

const _usage = 'Usage: ./publish_flutter_quill.dart <new-version>';

// The flutter_quill pubspec.yaml
const _targetPubspecYaml = './pubspec.yaml';

// The flutter_quill CHANGELOG
const _targetChangelog = './CHANGELOG.md';

const _confirmPublishOptionName = 'Y';

void main(List<String> args) {
  print('The passed args: $args');
  if (args.isEmpty) {
    print('Missing required arguments. $_usage');
    exit(1);
  }
  if (args.length > 1) {
    print('Too many arguments. $_usage');
    exit(1);
  }
  if (args.length != 1) {
    print('Expect one argument. $_usage');
    exit(1);
  }
  final version = args[0];
  if (version.isEmpty) {
    print('The version is empty. $_usage');
    exit(1);
  }
  if (version.startsWith('v')) {
    print('The version ($version) should not start with v.');
    exit(1);
  }
  final confirmPublish =
      args.elementAtOrNull(3) == '-$_confirmPublishOptionName';
  if (!isValidVersion(version)) {
    print('The version ($version) is invalid.');
    exit(1);
  }
  if (!isGitClean()) {
    print(
        'The Git working tree is not clean. Commit your changes and run again.');
    exit(1);
  }
  update_pubspec_version.updatePubspecVersion(
    newVersion: version,
    pubspecFilePath: _targetPubspecYaml,
  );
  update_changelog_version.updateChangelogVersion(
    newVersion: version,
    changelogFilePath: _targetChangelog,
  );

  Process.runSync('git', ['add', _targetPubspecYaml, _targetChangelog]);
  if (isGitClean()) {
    print(
      'The Git working tree is still clean after updating $_targetChangelog and $_targetChangelog. Fix the script before continuing.',
    );
    exit(1);
  }

  print('✅ CHANGELOG and pubspec.yaml files has been updated.');
  if (!confirmPublish) {
    print(
      'To confirm the publish, type `$_confirmPublishOptionName` and then confirm the input.\n'
      'FYI: You can add `-$_confirmPublishOptionName` when running the script to skip this check.',
    );
    final confirm = stdin.readLineSync();
    if (confirm != _confirmPublishOptionName) {
      print(
        'The publishing process has been aborted.\n'
        'Changes to CHANGELOG.md and pubspec.yaml have not been reverted.\n'
        'To revert them, run:\n'
        'git restore --staged $_targetChangelog $_targetPubspecYaml\n'
        'git restore $_targetChangelog $_targetPubspecYaml',
      );
      exit(1);
    }
  }

  final tagName = 'v$version';
  Process.runSync(
      'git', ['commit', '-m', 'chore(release): prepare to publish $version']);
  Process.runSync('git', ['tag', tagName]);

  Process.runSync('git', ['push']);
  Process.runSync('git', ['push', 'origin', tagName]);
  print(
    '✅ The tag $tagName has been pushed, the GitHub workflow will do the rest.',
  );
}

// Same as https://dart.dev/tools/pub/automated-publishing#configuring-a-github-action-workflow-for-publishing-to-pub-dev
// but without the `v`.
bool isValidVersion(String version) {
  final regex = RegExp(r'^[0-9]+\.[0-9]+\.[0-9]+$');
  return regex.hasMatch(version);
}

bool isGitClean() {
  final result = Process.runSync('git', ['status', '--porcelain']);
  // If the output is empty, the repository is clean
  return result.stdout.toString().trim().isEmpty;
}
