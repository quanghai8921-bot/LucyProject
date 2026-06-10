import 'dart:typed_data';

import 'file_download_stub.dart'
    if (dart.library.html) 'file_download_web.dart'
    if (dart.library.io) 'file_download_io.dart';

Future<String> downloadBytes({
  required String fileName,
  required Uint8List bytes,
  String? mimeType,
}) {
  return downloadBytesImpl(
    fileName: fileName,
    bytes: bytes,
    mimeType: mimeType,
  );
}
