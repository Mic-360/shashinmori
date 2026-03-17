import 'package:cross_file/cross_file.dart';

Future<String> uploadWithTusTransport({
  required XFile file,
  required Uri uri,
  required Map<String, String> metadata,
  required Map<String, String> headers,
  required void Function(double progress) onProgress,
}) {
  throw UnsupportedError('Unsupported platform for tus uploads.');
}
