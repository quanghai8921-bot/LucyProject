import 'dart:io';
import 'dart:typed_data';

Future<String> downloadBytesImpl({
  required String fileName,
  required Uint8List bytes,
  String? mimeType,
}) async {
  final safeName = _safeFileName(fileName);
  final file = File('${Directory.systemTemp.path}/${DateTime.now().millisecondsSinceEpoch}_$safeName');
  await file.writeAsBytes(bytes);
  return file.path;
}

String _safeFileName(String fileName) {
  final trimmed = fileName.trim().isEmpty ? 'lucy-material' : fileName.trim();
  return trimmed.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
}
