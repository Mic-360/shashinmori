import 'package:cross_file/cross_file.dart';
import 'package:tus_client_dart/tus_client_dart.dart';

Future<String> uploadWithTusTransport({
  required XFile file,
  required Uri uri,
  required Map<String, String> metadata,
  required Map<String, String> headers,
  required void Function(double progress) onProgress,
}) async {
  final client = TusClient(
    file,
    retries: 3,
    retryInterval: 2,
  );

  await client.upload(
    uri: uri,
    metadata: metadata,
    headers: headers,
    onProgress: (progress, _) => onProgress((progress / 100).clamp(0.0, 1.0)),
  );

  final uploadUri = client.uploadUrl;
  if (uploadUri == null) {
    throw Exception('Upload finished without a tus upload URL.');
  }

  return uploadUri.pathSegments.isNotEmpty
      ? uploadUri.pathSegments.last
      : uploadUri.toString();
}
