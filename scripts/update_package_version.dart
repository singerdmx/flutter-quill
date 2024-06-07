// ignore_for_file: avoid_print

import 'dart:convert' show jsonDecode, jsonEncode;
import 'dart:io' show File, exit;

import 'package:yaml_edit/yaml_edit.dart' show YamlEditor;

/// The list of the packages that which will be used to update the `CHANGELOG.md`
/// and the version in the `pubspec.yaml` for all the packages
final _packages = [
  './',
  './dart_quill_delta',
  './flutter_quill_extensions',
  './flutter_quill_test',
  './quill_html_converter',
  './quill_pdf_converter',
];

const _usage = 'Usage: ./script <version> <changelog-version-content>';

/// A script that should run in the root folder and not inside any other folder
/// it has one task, which update the version for `pubspec.yaml` and
/// `CHANGELOG.md` for all the packages, the `CHANGELOG.md` files will be
/// generated from a json file which is the source of the data
///
/// the script can be used with the following args [_usage]
/// it will require a version and the changes for that version (as a [String])
/// if the version exist then it will modify it with the new changes
/// if not, then will be added at the start
///
/// the source file (which used to generate the `CHANGELOG.md` files) will
/// also updated with the new change
///
/// this script designed to run in CI to automate the process of updating
/// the package
Future<void> main(List<String> args) async {
  if (args.isEmpty || args.length < 2) {
    print('Missing required arguments ($args). $_usage');
    exit(1);
  }
  if (args.length > 2) {
    print('Too many arguments ($args). $_usage');
    exit(1);
  }
  final passedVersion = args[0];
  if (passedVersion.isEmpty) {
    print('The version is empty ($args). $_usage');
    exit(1);
  }
  final passedVersionContent = args[1];
  if (passedVersionContent.isEmpty) {
    print('The version content is empty ($args). $_usage');
    exit(1);
  }

  print(
    'The version is $passedVersion and the content is:\n$passedVersionContent',
  );

  // A file that will be used to build the `CHANGELOG.md` files
  // the data format is in Json
  final sourceChangeLogFile = File('./CHANGELOG_DATA.json');
  await _replaceVersion(
    sourceChangeLogFile: sourceChangeLogFile,
    version: passedVersion,
    versionContent: passedVersionContent,
  );
  final sourceChangeLog = jsonDecode(await sourceChangeLogFile.readAsString())
      as Map<String, Object?>;
  final generatedChangeLogBuffer = StringBuffer()
    ..write(
      '<!-- This file is auto-generated from ${sourceChangeLogFile.uri.pathSegments.last} using a script - Manual changes will be overwritten -->\n\n',
    )
    ..write('# Changelog\n\n')
    ..write(
      'All notable changes to this project will be documented in this file.\n\n',
    );
  sourceChangeLog.forEach((version, versionContent) {
    generatedChangeLogBuffer
      ..write('## $version\n\n')
      ..write('$versionContent\n\n');
  });

  for (final packagePath in _packages) {
    await _updatePubspecYamlFile(
      pubspecYamlPath: '$packagePath/pubspec.yaml',
      newVersion: passedVersion,
    );
    _updateChangelog(
      changeLogFilePath: '$packagePath/CHANGELOG.md',
      changeLogContent: generatedChangeLogBuffer.toString(),
    );
  }
}

/// Replace the version content by the version if it exist
/// or add the version at the start of the map if it doesn't exist
///
/// then save the changes to the [sourceChangeLogFile]
Future<void> _replaceVersion({
  required File sourceChangeLogFile,
  required String version,
  required String versionContent,
}) async {
  final sourceChangeLog = jsonDecode(await sourceChangeLogFile.readAsString())
      as Map<String, Object?>;
  if (sourceChangeLog[version] != null) {
    sourceChangeLog[version] = versionContent;
  } else {
    // A workaround to add the new item at the start, the order matter
    // becase later it will generate the markdown files
    final newMap = <String, Object?>{version: versionContent};
    sourceChangeLog
      ..forEach((key, value) => newMap[key] = value)
      ..clear()
      ..addAll(newMap);
  }
  await sourceChangeLogFile.writeAsString(jsonEncode(sourceChangeLog));
}

/// Update the [pubspecYamlPath] file to update the `version` property from [newVersion]
Future<void> _updatePubspecYamlFile({
  required String pubspecYamlPath,
  required String newVersion,
}) async {
  final file = File(pubspecYamlPath);
  final yaml = await file.readAsString();
  final yamlEditor = YamlEditor(yaml)..update(['version'], newVersion);
  await file.writeAsString(yamlEditor.toString());
}

/// Copy [changeLogContent] and overwrite it to the [changeLogFilePath]
Future<void> _updateChangelog({
  required String changeLogFilePath,
  required String changeLogContent,
}) async {
  final changeLogFile = File(changeLogFilePath);
  await changeLogFile.writeAsString(changeLogContent);
}
