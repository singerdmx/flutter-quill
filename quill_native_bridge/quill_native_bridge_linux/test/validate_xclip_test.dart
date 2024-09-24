import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quill_native_bridge_linux/src/constants.dart';

void main() async {
  testWidgets('validate xclip binary file', (tester) async {
    // Latest Xclip binary file https://github.com/astrand/xclip
    const latestXclipSha512Checksum =
        'f18ad061b8711c7b955edec8e5b203566e9c705da466733d148968a66fbce6db89e540790cc834e2390e4d42d8973b7c0245224e54aadd0133b201b37d3bed79';

    // Ensure the xclip file is in the assets directory and accessible
    // without any runtime issues.
    final xclipAssetFileBytes =
        (await rootBundle.load(kXclipAssetFile)).buffer.asUint8List();
    final xclipAssetFileSha512Checksum =
        sha512.convert(xclipAssetFileBytes).toString();

    expect(xclipAssetFileSha512Checksum, latestXclipSha512Checksum);
  });
}
