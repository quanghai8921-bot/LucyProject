// ignore: avoid_web_libraries_in_flutter
import 'dart:async';
import 'dart:html' as html;
import 'dart:js_util' as js_util;

class LocalRecordingService {
  html.MediaRecorder? _mediaRecorder;
  List<html.Blob> _chunks = [];

  Future<bool> start() async {
    try {
      final mediaDevices = html.window.navigator.mediaDevices;
      if (mediaDevices == null) return false;
      
      final options = js_util.jsify({
        'video': true,
        'audio': true,
      });
      final promise = js_util.callMethod(mediaDevices, 'getDisplayMedia', [options]);
      
      final stream = await js_util.promiseToFuture(promise) as html.MediaStream;
      
      _mediaRecorder = html.MediaRecorder(stream);
      _chunks = [];
      
      _mediaRecorder!.addEventListener('dataavailable', (event) {
        final blob = (event as dynamic).data as html.Blob;
        if (blob.size > 0) {
          _chunks.add(blob);
        }
      });
      
      _mediaRecorder!.start();
      return true;
    } catch (e) {
      html.window.console.error('Lỗi khi bật MediaRecorder: $e');
      return false;
    }
  }

  Future<void> stop(String fileName) async {
    if (_mediaRecorder == null) return;
    
    final completer = Completer<void>();
    _mediaRecorder!.addEventListener('stop', (_) {
      final blob = html.Blob(_chunks, 'video/webm');
      final url = html.Url.createObjectUrlFromBlob(blob);
      html.AnchorElement(href: url)
        ..download = '$fileName.webm'
        ..style.display = 'none'
        ..click();
      html.Url.revokeObjectUrl(url);
      completer.complete();
    });
    
    _mediaRecorder!.stop();
    
    final tracks = _mediaRecorder!.stream?.getTracks() ?? [];
    for (var track in tracks) {
      track.stop();
    }
    
    _mediaRecorder = null;
    return completer.future;
  }
}
