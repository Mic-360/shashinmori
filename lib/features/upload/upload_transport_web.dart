import 'package:cross_file/cross_file.dart';
import 'package:dio/dio.dart';

String _encodeMetadata(Map<String, String> metadata) {
  return metadata.entries
      .map((entry) => '${entry.key} ${Uri.encodeComponent(entry.value)}')
      .join(',');
}

Future<String> uploadWithTusTransport({
  required XFile file,
  required Uri uri,
  required Map<String, String> metadata,
  required Map<String, String> headers,
  required void Function(double progress) onProgress,
}) async {
  final bytes = await file.readAsBytes();
  final dio = Dio();

  final createResponse = await dio.postUri(
    uri,
    data: null,
    options: Options(
      headers: {
        ...headers,
        'Tus-Resumable': '1.0.0',
        'Upload-Length': bytes.length.toString(),
        'Upload-Metadata': _encodeMetadata(metadata),
      },
      validateStatus: (status) => status != null && status >= 200 && status < 400,
    ),
  );

  final location = createResponse.headers.value('location');
  if (location == null || location.isEmpty) {
    throw Exception('Tus server did not return an upload location.');
  }

  final uploadUri = uri.resolve(location);
  final uploadResponse = await dio.patchUri(
    uploadUri,
    data: Stream.fromIterable([bytes]),
    options: Options(
      headers: {
        ...headers,
        'Tus-Resumable': '1.0.0',
        'Upload-Offset': '0',
        'Content-Type': 'application/offset+octet-stream',
      },
      validateStatus: (status) => status != null && status >= 200 && status < 400,
    ),
    onSendProgress: (sent, total) {
      if (total > 0) {
        onProgress((sent / total).clamp(0.0, 1.0));
      }
    },
  );

  return uploadResponse.headers.value('x-upload-id') ??
      (uploadUri.pathSegments.isNotEmpty
          ? uploadUri.pathSegments.last
          : uploadUri.toString());
}
