// ignore_for_file: avoid_print

import 'dart:io';
import 'package:http/http.dart' as http;

import './update_changelog_version.dart';
import './update_pubspec_version.dart';
import 'pubspec_version_check.dart';

// NOTE: This script is for the maintainers.

const _usage = 'Usage: ./publish_flutter_quill.dart <new-version>';

// The flutter_quill pubspec.yaml
const _targetPubspecYaml = './pubspec.yaml';

// The flutter_quill CHANGELOG
const _targetChangelog = './CHANGELOG.md';

const _exampleDirectory = './example';

const _targetExamplePubspecLock = '$_exampleDirectory/pubspec.lock';

const _confirmPublishOptionName = 'Y';

const _mainGitRemote = 'origin';

const _githubRepoActionsLink =
    'https://github.com/singerdmx/flutter-quill/actions';

const _packageName = 'flutter_quill';

const _changelogAndPubspecRestoreMessage =
    'ℹ️  Changes to CHANGELOG.md and pubspec.yaml have not been reverted.\n'
    'To revert them, run:\n'
    'git restore --staged $_targetChangelog $_targetPubspecYaml $_targetExamplePubspecLock\n'
    'git restore $_targetChangelog $_targetPubspecYaml $_targetExamplePubspecLock';

Future<void> main(List<String> args) async {
  print('➡️ Arguments provided: $args');

  if (args.isEmpty) {
    print('❌ Missing required arguments. $_usage');
    exit(1);
  }
  if (args.length > 2) {
    print('❌ Too many arguments. $_usage');
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
      args.elementAtOrNull(1) == '-$_confirmPublishOptionName';
  if (!_isValidVersion(version)) {
    print('❌ Invalid version format ($version).');
    exit(1);
  }
  if (!_isGitClean()) {
    print(
        '❌ Git working directory is not clean. Commit all changes and try again.');
    exit(1);
  }

  print(
    'ℹ️ Checking if the version `$version` is already published on pub.dev...',
  );
  if (await _isPackageVersionPublished(version)) {
    print(
        '❌ The version `$version` of the `$_packageName` package is already published on pub.dev.');
    print(
        '📦 Check the package page on pub.dev: https://pub.dev/packages/$_packageName/versions');
    print('⚠️ Choose a different version and try again.');
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
    // To update pubspec.lock of the example
    print(
      'ℹ️ Running `flutter pub get` in the example directory to update `pubspec.lock`...',
    );
    Process.runSync('flutter', ['pub', 'get', '-C', _exampleDirectory]);

    Process.runSync(
      'git',
      ['add', _targetPubspecYaml, _targetChangelog, _targetExamplePubspecLock],
    );

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
    Process.runSync('git', ['push', _mainGitRemote, tagName]);
    print(
      '✅ The tag $tagName has been pushed. The GitHub workflow will handle the rest.\n'
      'For more details, check: $_githubRepoActionsLink',
    );
  } catch (e) {
    print(
      '❌ An error occurred during the publishing process: ${e.toString()}\n',
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

/// Returns `true` if the specified [version] is already published on [pub.dev](https://pub.dev/).
Future<bool> _isPackageVersionPublished(String version) async {
  final url = 'https://pub.dev/api/packages/$_packageName/versions/$version';
  final response = await http.get(Uri.parse(url));
  switch (response.statusCode) {
    case 200:
      return true;
    case 404:
      return false;
    default:
      throw StateError(
        'Unexpected response status code: ${response.statusCode}\nResponse Body: ${response.body}',
      );
  }
}
