import 'dart:typed_data';

Future<String> downloadBytesImpl({
  required String fileName,
  required Uint8List bytes,
  String? mimeType,
}) {
  throw UnsupportedError('File download is not supported on this platform.');
}
