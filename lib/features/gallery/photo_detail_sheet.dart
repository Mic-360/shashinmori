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
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final repository = ref.watch(galleryRepositoryProvider);
    final authToken = ref.watch(authTokenProvider);
    final formatter = DateFormat.yMMMd().add_jm();
    final uploadedAt = DateTime.tryParse(photo.uploadedAt) ?? DateTime.now();
    final purgedAt =
        photo.purgedAt != null ? DateTime.tryParse(photo.purgedAt!) : null;

    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      minChildSize: 0.5,
      maxChildSize: 0.96,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: authToken.when(
            data: (token) {
              if (token == null) {
                return Center(
                  child: Text(
                    'Your session expired. Please sign in again.',
                    style: tt.bodyLarge,
                  ),
                );
              }

              final imageUrl = repository.getImageUrl(photo.photoId, token);

              return CustomScrollView(
                controller: scrollController,
                slivers: [
                  // Drag handle
                  SliverToBoxAdapter(
                    child: Center(
                      child: Container(
                        margin: const EdgeInsets.only(top: 12, bottom: 8),
                        width: 32,
                        height: 4,
                        decoration: BoxDecoration(
                          color: cs.onSurface.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                  // Photo
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.contain,
                          placeholder: (context, _) => AspectRatio(
                            aspectRatio: photo.width / photo.height,
                            child: Container(
                              color: cs.surfaceContainerHighest,
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                          ),
                          errorWidget: (context, _, __) => AspectRatio(
                            aspectRatio: 1,
                            child: Container(
                              color: cs.surfaceContainerHighest,
                              child: Icon(
                                Icons.broken_image_outlined,
                                size: 48,
                                color: cs.onSurface.withValues(alpha: 0.3),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Action buttons row
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _ActionButton(
                            icon: Icons.share_outlined,
                            label: 'Share',
                            onTap: () {},
                          ),
                          _ActionButton(
                            icon: Icons.edit_outlined,
                            label: 'Edit',
                            onTap: () {},
                          ),
                          _ActionButton(
                            icon: Icons.info_outline,
                            label: 'Info',
                            onTap: () {},
                          ),
                          _ActionButton(
                            icon: Icons.delete_outline,
                            label: 'Delete',
                            onTap: () {},
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Details section
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Divider(height: 1),
                          const SizedBox(height: 20),
                          Text(photo.filename, style: tt.titleLarge),
                          const SizedBox(height: 20),
                          _DetailRow(
                            icon: Icons.calendar_today_outlined,
                            label: 'Uploaded',
                            value: formatter.format(uploadedAt),
                          ),
                          _DetailRow(
                            icon: Icons.photo_size_select_actual_outlined,
                            label: 'Resolution',
                            value: '${photo.width} \u00d7 ${photo.height}',
                          ),
                          _DetailRow(
                            icon: Icons.image_outlined,
                            label: 'Type',
                            value: photo.mimeType,
                          ),
                          _DetailRow(
                            icon: Icons.sd_storage_outlined,
                            label: 'Size',
                            value: _formatBytes(photo.sizeBytes),
                          ),
                          _DetailRow(
                            icon: photo.originalAvailable
                                ? Icons.cloud_done_outlined
                                : Icons.cloud_off_outlined,
                            label: 'Original',
                            value: photo.originalAvailable
                                ? 'Available on device'
                                : 'Purged from device',
                          ),
                          if (purgedAt != null)
                            _DetailRow(
                              icon: Icons.auto_delete_outlined,
                              label: 'Purged',
                              value: formatter.format(purgedAt),
                            ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => Center(
              child: Text(
                'Unable to load photo.',
                style: tt.bodyLarge,
              ),
            ),
          ),
        );
      },
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

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: cs.onSurface.withValues(alpha: 0.7)),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.6),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, size: 20, color: cs.onSurface.withValues(alpha: 0.5)),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: tt.labelSmall?.copyWith(
                  color: cs.onSurface.withValues(alpha: 0.5),
                ),
              ),
              Text(value, style: tt.bodyMedium),
            ],
          ),
        ],
      ),
    );
  }
}
