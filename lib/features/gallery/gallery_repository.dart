import '../../core/api_client.dart';
import '../../core/config.dart';

class Photo {
  const Photo({
    required this.photoId,
    required this.filename,
    required this.mimeType,
    required this.sizeBytes,
    required this.uploadedAt,
    required this.width,
    required this.height,
    required this.originalAvailable,
    required this.purgedAt,
    required this.status,
  });

  factory Photo.fromJson(Map<String, dynamic> json) {
    return Photo(
      photoId: json['photoId'] as String,
      filename: json['filename'] as String? ?? '',
      mimeType: json['mimeType'] as String? ?? 'image/jpeg',
      sizeBytes: (json['sizeBytes'] as num?)?.toInt() ?? 0,
      uploadedAt: json['uploadedAt'] as String? ?? '',
      width: (json['width'] as num?)?.toInt() ?? 1,
      height: (json['height'] as num?)?.toInt() ?? 1,
      originalAvailable: json['originalAvailable'] as bool? ?? false,
      purgedAt: json['purgedAt'] as String?,
      status: json['status'] as String? ?? 'active',
    );
  }

  final String photoId;
  final String filename;
  final String mimeType;
  final int sizeBytes;
  final String uploadedAt;
  final int width;
  final int height;
  final bool originalAvailable;
  final String? purgedAt;
  final String status;
}

class PhotoPage {
  const PhotoPage({
    required this.photos,
    required this.nextCursor,
    required this.hasMore,
  });

  final List<Photo> photos;
  final String? nextCursor;
  final bool hasMore;
}

class GalleryRepository {
  Future<PhotoPage> fetchPhotos({String? cursor, int limit = 20}) async {
    final response = await apiClient.get<Map<String, dynamic>>(
      '/v1/photos',
      queryParameters: {
        if (cursor != null) 'cursor': cursor,
        'limit': limit,
      },
    );

    final body = response.data ?? const <String, dynamic>{};
    final data = (body['data'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(Photo.fromJson)
        .toList();

    return PhotoPage(
      photos: data,
      nextCursor: body['nextCursor'] as String?,
      hasMore: body['hasMore'] as bool? ?? false,
    );
  }

  String getPreviewUrl(String photoId, String token) {
    return Uri.parse('${Config.apiBaseUrl}/v1/photos/$photoId/preview')
        .replace(queryParameters: {'token': token}).toString();
  }

  String getImageUrl(String photoId, String token) {
    return Uri.parse('${Config.apiBaseUrl}/v1/photos/$photoId/image')
        .replace(queryParameters: {'token': token}).toString();
  }
}
