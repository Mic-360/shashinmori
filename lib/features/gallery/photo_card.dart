import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'gallery_repository.dart';
import 'photo_detail_sheet.dart';

class PhotoCard extends StatefulWidget {
  const PhotoCard({
    required this.photo,
    required this.previewUrl,
    super.key,
  });

  final Photo photo;
  final String previewUrl;

  @override
  State<PhotoCard> createState() => _PhotoCardState();
}

class _PhotoCardState extends State<PhotoCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final aspectRatio = widget.photo.width == 0 || widget.photo.height == 0
        ? 1.0
        : widget.photo.width / widget.photo.height;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () {
          showModalBottomSheet<void>(
            context: context,
            isScrollControlled: true,
            useSafeArea: true,
            builder: (context) => PhotoDetailSheet(photo: widget.photo),
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: cs.shadow.withValues(alpha: 0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                AspectRatio(
                  aspectRatio: aspectRatio.clamp(0.6, 1.8),
                  child: CachedNetworkImage(
                    imageUrl: widget.previewUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, _) => Container(
                      color: cs.surfaceContainerHighest,
                    ),
                    errorWidget: (context, _, __) => Container(
                      color: cs.surfaceContainerHighest,
                      child: Icon(
                        Icons.broken_image_outlined,
                        color: cs.onSurface.withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                ),
                // Hover overlay with selection indicator
                if (_isHovered)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Padding(
                          padding: const EdgeInsets.all(6),
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.9),
                              border: Border.all(
                                color: cs.outline.withValues(alpha: 0.3),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
