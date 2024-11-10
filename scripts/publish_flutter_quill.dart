// ignore_for_file: avoid_print

import 'dart:io';

import './update_changelog_version.dart';
import './update_pubspec_version.dart';
import 'pubspec_version_check.dart';

// NOTE: This script is for the maintainers.

const _usage = 'Usage: ./publish_flutter_quill.dart <new-version>';

// The flutter_quill pubspec.yaml
const _targetPubspecYaml = './pubspec.yaml';

// The flutter_quill CHANGELOG
const _targetChangelog = './CHANGELOG.md';

const _confirmPublishOptionName = 'Y';

const _changelogAndPubspecRestoreMessage =
    'ℹ️ Changes to CHANGELOG.md and pubspec.yaml have not been reverted.\n'
    'To revert them, run:\n'
    'git restore --staged $_targetChangelog $_targetPubspecYaml\n'
    'git restore $_targetChangelog $_targetPubspecYaml';

void main(List<String> args) {
  print('➡️ Arguments provided: $args');

  if (args.isEmpty) {
    print('❌ Missing required arguments. $_usage');
    exit(1);
  }
  if (args.length > 1) {
    print('❌ Too many arguments. $_usage');
    exit(1);
  }
  if (args.length != 1) {
    print('❌ Expected a single argument. $_usage');
    exit(1);
  }
  final version = args[0];
  if (version.isEmpty) {
    print('❌ The version is empty. $_usage');
    exit(1);
  }
  if (version.startsWith('v')) {
    print(
      '❌ Version ($version) should not start with `v`, as the script will add it to the tag.',
    );
    exit(1);
  }
  final confirmPublish =
      args.elementAtOrNull(3) == '-$_confirmPublishOptionName';
  if (!_isValidVersion(version)) {
    print('❌ Invalid version format ($version).');
    exit(1);
  }
  if (!_isGitClean()) {
    print(
        '❌ Git working directory is not clean. Commit all changes and try again.');
    exit(1);
  }
  updatePubspecVersion(
    newVersion: version,
    pubspecFilePath: _targetPubspecYaml,
  );
  checkPubspecVersion(
    expectedVersion: version,
    pubspecFilePath: _targetPubspecYaml,
  );
  updateChangelogVersion(
    newVersion: version,
    changelogFilePath: _targetChangelog,
  );

  try {
    Process.runSync('git', ['add', _targetPubspecYaml, _targetChangelog]);

    if (_isGitClean()) {
      print(
        '❌ No changes detected after updating $_targetChangelog and $_targetPubspecYaml.\n'
        'Review the script for potential issues.',
      );
      exit(1);
    }

    print('✅ CHANGELOG and pubspec.yaml files have been updated.');
    if (!confirmPublish) {
      print(
        'ℹ️ To confirm publishing, type `$_confirmPublishOptionName` and press Enter.\n'
        'Tip: Add `-$_confirmPublishOptionName` as an argument to skip this prompt in the future.',
      );
      final confirm = stdin.readLineSync();
      if (confirm != _confirmPublishOptionName) {
        print('❌ The publishing process has been aborted.\n'
            '$_changelogAndPubspecRestoreMessage');
        exit(1);
      }
    }

    final tagName = 'v$version';

    print('ℹ️ Committing changes...');
    Process.runSync(
        'git', ['commit', '-m', 'chore(release): prepare to publish $version']);

    print('ℹ️ Creating git tag `$tagName`...');
    Process.runSync('git', ['tag', tagName]);

    print('ℹ️ Pushing commit to remote...');
    Process.runSync('git', ['push']);

    print('ℹ️ Pushing tag to remote...');
    Process.runSync('git', ['push', 'origin', tagName]);
    print(
      '✅ The tag $tagName has been pushed. The GitHub workflow will handle the rest.\n'
      'For more details, check: https://github.com/singerdmx/flutter-quill/actions',
    );
  } catch (e) {
    print(
      '❌ An error occurred during the publishing process: ${e.toString()}\n\n',
    );
    print(_changelogAndPubspecRestoreMessage);
  }
}

// Same as https://dart.dev/tools/pub/automated-publishing#configuring-a-github-action-workflow-for-publishing-to-pub-dev
// but without the `v`.
bool _isValidVersion(String version) {
  final regex = RegExp(r'^[0-9]+\.[0-9]+\.[0-9]+(-[a-zA-Z0-9]+(\.[0-9]+)?)?$');
  return regex.hasMatch(version);
}

bool _isGitClean() {
  final result = Process.runSync('git', ['status', '--porcelain']);
  // If the output is empty, the repository is clean
  return result.stdout.toString().trim().isEmpty;
}
