import 'dart:typed_data';

import 'package:cross_file/cross_file.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path/path.dart' as p;

import '../../core/api_client.dart';
import '../../core/config.dart';
import '../../shared/models/app_error.dart';
import 'upload_transport_stub.dart'
    if (dart.library.io) 'upload_transport_io.dart'
    if (dart.library.html) 'upload_transport_web.dart' as transport;

class UploadStatus {
  const UploadStatus({
    required this.status,
    this.photoId,
    this.failureReason,
  });

  final String status;
  final String? photoId;
  final String? failureReason;
}

class UploadRepository {
  Future<String> startUpload({
    required XFile file,
    required String userId,
    required void Function(double progress) onProgress,
  }) async {
    final bytes = await file.readAsBytes();
    final mimeType = _detectMimeType(bytes, file.name);
    if (!mimeType.startsWith('image/')) {
      throw const AppError(
        code: 'UNSUPPORTED_MEDIA_TYPE',
        message: 'Only image uploads are supported.',
      );
    }

    final token = await FirebaseAuth.instance.currentUser?.getIdToken();
    if (token == null || token.isEmpty) {
      throw const AppError(
        code: 'UNAUTHORIZED',
        message: 'You need to be signed in to upload.',
      );
    }

    final uploadId = await transport.uploadWithTusTransport(
      file: file,
      uri: Uri.parse('${Config.apiBaseUrl}/v1/uploads'),
      metadata: {
        'filename': p.basename(file.name),
        'userId': userId,
        'mimeType': mimeType,
      },
      headers: {
        'Authorization': 'Bearer $token',
      },
      onProgress: onProgress,
    );

    return uploadId;
  }

  Future<UploadStatus> pollStatus(String uploadId) async {
    final response = await apiClient.get<Map<String, dynamic>>(
      '/v1/uploads/$uploadId/status',
    );
    final body = response.data ?? const <String, dynamic>{};
    final data = body['data'] as Map<String, dynamic>? ?? const {};
    final photo = data['photo'] as Map<String, dynamic>?;

    return UploadStatus(
      status: data['status'] as String? ?? 'pending',
      photoId: data['photoId'] as String? ?? photo?['photoId'] as String?,
      failureReason: data['failureReason'] as String?,
    );
  }

  String _detectMimeType(Uint8List bytes, String filename) {
    if (bytes.length >= 12 &&
        bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4E &&
        bytes[3] == 0x47) {
      return 'image/png';
    }
    if (bytes.length >= 3 &&
        bytes[0] == 0xFF &&
        bytes[1] == 0xD8 &&
        bytes[2] == 0xFF) {
      return 'image/jpeg';
    }
    if (bytes.length >= 6 &&
        String.fromCharCodes(bytes.sublist(0, 6)) == 'GIF87a') {
      return 'image/gif';
    }
    if (bytes.length >= 6 &&
        String.fromCharCodes(bytes.sublist(0, 6)) == 'GIF89a') {
      return 'image/gif';
    }
    if (bytes.length >= 12 &&
        String.fromCharCodes(bytes.sublist(8, 12)) == 'WEBP') {
      return 'image/webp';
    }

    final extension = p.extension(filename).toLowerCase();
    return switch (extension) {
      '.png' => 'image/png',
      '.jpg' || '.jpeg' => 'image/jpeg',
      '.gif' => 'image/gif',
      '.webp' => 'image/webp',
      '.bmp' => 'image/bmp',
      _ => 'application/octet-stream',
    };
  }
}
