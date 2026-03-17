import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../auth/auth_provider.dart';
import 'gallery_provider.dart';
import 'gallery_repository.dart';

class PhotoDetailSheet extends ConsumerWidget {
  const PhotoDetailSheet({
    required this.photo,
    super.key,
  });

  final Photo photo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repository = ref.watch(galleryRepositoryProvider);
    final authToken = ref.watch(authTokenProvider);
    final formatter = DateFormat.yMMMd().add_jm();
    final uploadedAt = DateTime.tryParse(photo.uploadedAt) ?? DateTime.now();
    final purgedAt = photo.purgedAt != null ? DateTime.tryParse(photo.purgedAt!) : null;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: authToken.when(
          data: (token) {
            if (token == null) {
              return const Text('Your session expired. Please sign in again.');
            }

            final imageUrl = repository.getImageUrl(photo.photoId, token);

            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      errorWidget: (context, _, __) => const AspectRatio(
                        aspectRatio: 1,
                        child: ColoredBox(
                          color: Color(0xFFE6E1D8),
                          child: Center(child: Icon(Icons.broken_image_outlined)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(photo.filename, style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  Text('Uploaded: ${formatter.format(uploadedAt)}'),
                  const SizedBox(height: 8),
                  Text('Resolution: ${photo.width} x ${photo.height}'),
                  const SizedBox(height: 8),
                  Text('Type: ${photo.mimeType}'),
                  const SizedBox(height: 8),
                  Text('Original size: ${_formatBytes(photo.sizeBytes)}'),
                  const SizedBox(height: 8),
                  Text(
                    photo.originalAvailable
                        ? 'Original file is still on the device'
                        : 'Original file was purged from the device',
                  ),
                  if (purgedAt != null) ...[
                    const SizedBox(height: 8),
                    Text('Purged: ${formatter.format(purgedAt)}'),
                  ],
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const Text('Unable to load secure photo view.'),
        ),
      ),
    );
  }

  String _formatBytes(int bytes) {
    if (bytes >= 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    if (bytes >= 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '$bytes B';
  }
}
