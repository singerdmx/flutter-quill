// ignore_for_file: avoid_print

import 'dart:io';

import 'package:intl/intl.dart';

// This script assumes your CHANGELOG.md format is based on https://keepachangelog.com/en/1.1.0/

const _usage =
    'Usage: ./update_changelog_version.dart <version> <changelog-file-path>';

/// [unreleased]: https://github.com/singerdmx/flutter-quill/compare/v6.0.0...HEAD
const kUnreleasedReferenceLinkName = 'unreleased';

/// ## [Unreleased]
const kUnreleasedVersionEntryName = 'Unreleased';

const kKeepAChangelogFormatLink = 'https://keepachangelog.com/en/1.1.0/';

/// Updates `CHANGELOG.md` by adding a new version entry with a link to the version,
/// the current date, and formatting to comply with the [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
///
/// ### Limitations
///
/// * The [updateVersionLinks] expects version tags to include the `v` prefix in the URLs.
/// For example, use `[2.0.0]: https://github.com/singerdmx/flutter-quill/compare/v1.0.0...v2.0.0`
/// instead of `[2.0.0]: https://github.com/singerdmx/flutter-quill/compare/1.0.0...2.0.0`.
/// * The [updateVersionLinks] expects the current version has previous version that's not the initial version.
/// if you have at least 3 releases, this shouldn't be an issue.
/// * The [updateVersionLinks] doesn't handle comments (<!-- -->) correctly.
///
/// This script will be used in CI workflow.
///
/// For a visual example, see: https://www.diffchecker.com/eAIScyop/
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
  final changelogPath = args[1];
  if (changelogPath.isEmpty) {
    print('The CHANGELOG file path is empty. $_usage');
    exit(1);
  }
  final changelogFile = File(changelogPath);
  if (!changelogFile.existsSync()) {
    print('The CHANGELOG file does not exist: ${changelogFile.absolute.path}');
    exit(1);
  }
  updateChangelogFile(
    changelogFile: changelogFile,
    newVersion: version,
  );
}

void updateChangelogFile({
  required File changelogFile,
  required String newVersion,
}) {
  final changelog = changelogFile.readAsStringSync();

  final newVersionFormattedDate =
      DateFormat('yyyy-MM-dd').format(DateTime.now());
  final changelogWithUpdateLinks = updateVersionLinks(
    changeLog: changelog,
    newVersion: newVersion,
  );
  final changelogWithUnreleasedReplacedByNewVersion =
      replaceUnreleasedWithNewVersion(
    changeLog: changelogWithUpdateLinks,
    newVersion: newVersion,
    newVersionFormattedDate: newVersionFormattedDate,
  );
  final changelogWithNewUnreleased = addNewUnreleasedEntry(
    changelog: changelogWithUnreleasedReplacedByNewVersion,
    newVersion: newVersion,
    newVersionFormattedDate: newVersionFormattedDate,
  );
  changelogFile.writeAsStringSync(changelogWithNewUnreleased);
}

/// Updates the link reference of `[unreleased]` and add a new link reference
/// after the `[unreleased]` for the [newVersion].
///
/// Those links are in the bottom of the file.
///
/// Example with `11.0.0` to [newVersion]:
///
/// ### Before
///
/// ```md
/// [unreleased]: https://github.com/singerdmx/flutter-quill/compare/v11.0.0-dev.5...HEAD
/// [11.0.0-dev.5]: https://github.com/singerdmx/flutter-quill/compare/v11.0.0-dev.4...v11.0.0-dev.5
/// [11.0.0-dev.4]: https://github.com/singerdmx/flutter-quill/compare/v11.0.0-dev.3...v11.0.0-dev.4
/// ```
///
/// ### After
///
/// ```md
/// [unreleased]: https://github.com/singerdmx/flutter-quill/compare/v11.0.0...HEAD
/// [11.0.0]: https://github.com/singerdmx/flutter-quill/compare/v11.0.0-dev.5...v11.0.0
/// [11.0.0-dev.5]: https://github.com/singerdmx/flutter-quill/compare/v11.0.0-dev.4...v11.0.0-dev.5
/// [11.0.0-dev.4]: https://github.com/singerdmx/flutter-quill/compare/v11.0.0-dev.3...v11.0.0-dev.4
/// ```
///
/// The `11.0.0-dev.4` remains unchanged (version released before the previous version),
/// it is only used to copy the `11.0.0-dev.5` and replace the versions.
///
/// For a more visual example, see: https://www.diffchecker.com/e5gH1Ldx/
String updateVersionLinks({
  required String changeLog,
  required String newVersion,
}) {
  final lines = changeLog.split('\n').reversed.toList();

  // Index of the line containing the unreleased version reference in Markdown, e.g.
  // [unreleased]: https://github.com/singerdmx/flutter-quill/compare/v11.0.0-dev.5...HEAD
  int? unreleasedRefLinkLineIndex;

  for (final (index, line) in lines.indexed) {
    if (line.toLowerCase().startsWith('[$kUnreleasedReferenceLinkName]:')) {
      unreleasedRefLinkLineIndex = index;
      break;
    }
  }

  if (unreleasedRefLinkLineIndex == null) {
    throw const FormatException(
      'Could not find the unreleased version link reference in the CHANGELOG that starts with: [$kUnreleasedReferenceLinkName]:\n\n'
      'Ensure the CHANGELOG format is based on $kKeepAChangelogFormatLink',
    );
  }

  // Index of the line containing the current version reference in Markdown, e.g.
  // [11.0.0-dev.5]: https://github.com/singerdmx/flutter-quill/compare/v11.0.0-dev.4...v11.0.0-dev.5
  final currentVersionRefLinkLineIndex = unreleasedRefLinkLineIndex - 1;

  final currentVersionRefLinkLine = lines[currentVersionRefLinkLineIndex];
  final currentVersion =
      getVersionFromVersionRefLinkLine(currentVersionRefLinkLine);

  final unreleasedRefLinkLine = lines[unreleasedRefLinkLineIndex];

  // Update the unreleased link ref
  if (!unreleasedRefLinkLine.contains(currentVersion)) {
    throw FormatException(
      'Expected the unreleased reference link to contain the current version.\n'
      'Expected something like: [$kUnreleasedReferenceLinkName]: https://github.com/.../compare/v$currentVersion...HEAD\n'
      'Actual: $unreleasedRefLinkLine\n'
      'Fix the CHANGELOG format. See also: $kKeepAChangelogFormatLink',
    );
  }
  final updatedUnreleasedRefLinkLine =
      unreleasedRefLinkLine.replaceFirst(currentVersion, newVersion);
  lines[unreleasedRefLinkLineIndex] = updatedUnreleasedRefLinkLine;

  // Add a new version link ref

  final twoVersionAgoRefLinkLine = lines[currentVersionRefLinkLineIndex - 1];
  final twoVersionAgo =
      getVersionFromVersionRefLinkLine(twoVersionAgoRefLinkLine);

  final newVersionRefLinkLine = currentVersionRefLinkLine
      .replaceFirst('[$currentVersion]', '[$newVersion]')
      .replaceFirst('v$currentVersion', 'v$newVersion')
      .replaceFirst('v$twoVersionAgo', 'v$currentVersion');
  lines.insert(unreleasedRefLinkLineIndex, newVersionRefLinkLine);

  // Return the updated CHANGELOG

  return lines.reversed.join('\n');
}

/// Extracts the version number from a given version reference link line in markdown format.
///
/// This function takes a string formatted as a version reference markdown link
/// (e.g., '[11.0.0-dev.5]: https://github.com/singerdmx/flutter-quill/compare/v11.0.0-dev.4...v11.0.0-dev.5')
/// and extracts the version number (e.g., '11.0.0-dev.5') from the square brackets.
///
/// ### Example:
///
/// ```dart
/// String versionRefLinkLine = '[11.0.0-dev.5]: https://github.com/singerdmx/flutter-quill/compare/v11.0.0-dev.4...v11.0.0-dev.5';
/// String version = getVersionFromVersionRefLinkLine(versionRefLinkLine);
/// print(version);  // Output: '11.0.0-dev.5'
/// ```
String getVersionFromVersionRefLinkLine(String versionRefLinkLine) {
  final version = versionRefLinkLine.substring(
    versionRefLinkLine.indexOf('[') + 1,
    versionRefLinkLine.indexOf(']'),
  );
  return version;
}

/// Replaces the 'Unreleased' section in [changeLog] with the specified [newVersion] and current date.
///
/// Example with `11.0.0` as [newVersion]:
///
/// ```diff
/// - ## [Unreleased]
/// + ## [11.0.0] - 2023-09-29
/// ```
String replaceUnreleasedWithNewVersion({
  required String changeLog,
  required String newVersion,
  required String newVersionFormattedDate,
}) {
  final lines = changeLog.split('\n');

  // Index of the line containing the unreleased version reference in Markdown, e.g.
  // [unreleased]: https://github.com/singerdmx/flutter-quill/compare/v11.0.0-dev.5...HEAD
  int? unreleasedVersionEntryIndex;

  for (final (index, line) in lines.indexed) {
    if (line
        .toLowerCase()
        .startsWith('## [$kUnreleasedVersionEntryName]'.toLowerCase())) {
      unreleasedVersionEntryIndex = index;
      break;
    }
  }

  if (unreleasedVersionEntryIndex == null) {
    throw const FormatException(
      'Could not find the unreleased release entry in the CHANGELOG that starts with: ## [$kUnreleasedVersionEntryName]\n\n'
      'Ensure the CHANGELOG format is based on $kKeepAChangelogFormatLink',
    );
  }

  final unreleasedVersionEntry = lines[unreleasedVersionEntryIndex];

  final newReleaseEntry =
      '${unreleasedVersionEntry.replaceFirst(kUnreleasedVersionEntryName, newVersion)} - $newVersionFormattedDate';
  lines[unreleasedVersionEntryIndex] = newReleaseEntry;

  return lines.join('\n');
}

/// Adds an empty `Unreleased` entry at the start of the CHANGELOG, before the new version entry.
String addNewUnreleasedEntry({
  required String changelog,
  required String newVersion,
  required String newVersionFormattedDate,
}) {
  final newVersionEntryIndex =
      changelog.indexOf('## [$newVersion] - $newVersionFormattedDate');
  if (newVersionEntryIndex == -1) {
    throw FormatException(
      'Could not find the new version entry in the CHANGELOG. Expected to find: ## [$newVersion] - $newVersionFormattedDate\n\n'
      'Ensure the CHANGELOG format is based on $kKeepAChangelogFormatLink or fix this script.',
    );
  }

  final changelogBeforeNewVersionEntry =
      changelog.substring(0, newVersionEntryIndex);
  const newUnreleasedEntry = '## [$kUnreleasedVersionEntryName]\n\n';
  final changelogFromVersionEntryOnward =
      changelog.substring(newVersionEntryIndex);
  // ignore: unnecessary_brace_in_string_interps
  return '${changelogBeforeNewVersionEntry}${newUnreleasedEntry}${changelogFromVersionEntryOnward}';
}
