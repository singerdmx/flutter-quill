import 'package:flutter_quill_extensions/src/common/utils/file_path_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('extractFileNameFromUrl', () {
    test('extracts file name from a standard URL', () {
      expect(
        extractFileNameFromUrl(
            'https://example.com/path/to/file/document.json'),
        equals('document.json'),
      );
    });

    test('extracts file name from a URL with query parameters', () {
      expect(
        extractFileNameFromUrl(
            'https://example.com/path/to/file/quill_document.json?version=1.2.3'),
        equals('quill_document.json'),
      );
    });

    test('extracts file name from a URL with query parameters', () {
      expect(
        extractFileNameFromUrl(
            'https://firebasestorage.googleapis.com/v0/b/eventat-4ba96.appspot.com/o/2019-Metrology-Events.jpg?alt=media&token=bfc47032-5173-4b3f-86bb-9659f46b362a'),
        equals('2019-Metrology-Events.jpg'),
      );
    });

    test('handles a URL with a trailing slash', () {
      expect(
        extractFileNameFromUrl('https://example.com/path/to/file/'),
        equals('file'),
      );
    });

    test('handles a URL ending with a slash and no file name', () {
      expect(
        extractFileNameFromUrl('https://example.com/path/to/'),
        equals('to'),
      );
    });

    test('handles a URL with multiple slashes in the path', () {
      expect(
        extractFileNameFromUrl(
            'https://example.com/path/to/extra/level/file.doc'),
        equals('file.doc'),
      );
    });

    test('handles URLs without any path components', () {
      expect(
        extractFileNameFromUrl('https://example.com'),
        isNull,
      );
    });

    test('extracts file name from a URL with special characters', () {
      expect(
        extractFileNameFromUrl(
            'https://example.com/files/2013-report-final_v2.json'),
        equals('2013-report-final_v2.json'),
      );
    });
  });
  group('extractFileNameFromFilePath', () {
    test('extracts file name from a standard file path', () {
      expect(
        extractFileNameFromFilePath('/path/to/file/document_file.json'),
        equals('document_file.json'),
      );
    });

    test('returns null for a path that ends with a trailing slash', () {
      expect(
        extractFileNameFromFilePath('/path/to/file/document_file.json/'),
        isNull,
      );
    });

    test('returns null for a path with only slashes', () {
      expect(
        extractFileNameFromFilePath('/path/to/'),
        isNull,
      );
    });

    test('returns null for an empty path', () {
      expect(
        extractFileNameFromFilePath(''),
        isNull,
      );
    });

    test('returns null for a path without a file name', () {
      expect(
        extractFileNameFromFilePath('/path/to/emptyfolder/'),
        isNull,
      );
    });

    test('extracts file name from a file path with special characters', () {
      expect(
        extractFileNameFromFilePath('/path/to/file/2015-report-final_v2.json'),
        equals('2015-report-final_v2.json'),
      );
    });

    test('returns null for a path that is just a file name with no directories',
        () {
      expect(
        extractFileNameFromFilePath('document.png'),
        equals('document.png'),
      );
    });

    test('returns null for a path that ends with a space or invalid format',
        () {
      expect(
        extractFileNameFromFilePath('/path/to/file/invalid/'),
        isNull,
      );
    });
  });
}
