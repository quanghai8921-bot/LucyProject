// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:typed_data';

Future<String> downloadBytesImpl({
  required String fileName,
  required Uint8List bytes,
  String? mimeType,
}) async {
  final safeName = _safeFileName(fileName);
  final blob = html.Blob(<Object>[bytes], mimeType ?? 'application/octet-stream');
  final url = html.Url.createObjectUrlFromBlob(blob);
  try {
    html.AnchorElement(href: url)
      ..download = safeName
      ..style.display = 'none'
      ..click();
    return safeName;
  } finally {
    html.Url.revokeObjectUrl(url);
  }
}

String _safeFileName(String fileName) {
  final trimmed = fileName.trim().isEmpty ? 'lucy-material' : fileName.trim();
  return trimmed.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
}
