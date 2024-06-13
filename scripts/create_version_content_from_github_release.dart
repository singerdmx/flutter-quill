// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io' show exit;

import 'package:http/http.dart' as http;

import 'update_package_version.dart';

// A script is used in CI that will fetch release notes using GitHub API
// and create a file from it that will be used by another script
//
// This script should run from root project folder instead of scripts folder
// or others.

const _usage =
    'Usage: ./script <github-repository> <release-tag> <github-authorization> (optional)';

Future<void> main(List<String> args) async {
  print('📑 Fetch release notes from Github API');

  if (args.isEmpty) {
    print('Missing required arguments ($args). $_usage');
    exit(1);
  }
  if (args.length > 2) {
    print('Too many arguments ($args). $_usage');
    exit(1);
  }
  if (args.length < 2) {
    print('Missing arguments ($args). $_usage');
    exit(1);
  }

  final githubRepository = args[0];
  final releaseTag = args[1];
  final githubAuthorization = args.elementAtOrNull(2);
  final response = await http.get(
    Uri.parse(
      'https://api.github.com/repos/$githubRepository/releases/tags/$releaseTag',
    ),
    headers: {
      if (githubAuthorization != null) 'Authorization': githubAuthorization,
    },
  );
  if (response.statusCode != 200) {
    print('Response status code is ${response.statusCode} which is not 200');
    print('Response body: ${response.body}');
    exit(1);
  }
  final responseBody = response.body;
  print('⚠️ Validate release notes response');
  if (responseBody.trim().isEmpty) {
    print('Release notes response is empty.');
    exit(1);
  }
  print('Response body: $responseBody');
  final githubReleaseNotes =
      (jsonDecode(responseBody) as Map<String, Object?>)['body'] as String?;
  if (githubReleaseNotes == null) {
    print('Release notes is null.');
    exit(1);
  }
  if (!await versionContentFile.parent.exists()) {
    await versionContentFile.parent.create(recursive: true);
  }
  await versionContentFile.writeAsString(githubReleaseNotes);
}
