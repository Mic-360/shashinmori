import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'gallery_repository.dart';
import 'photo_detail_sheet.dart';

class PhotoCard extends StatelessWidget {
  const PhotoCard({
    required this.photo,
    required this.previewUrl,
    super.key,
  });

  final Photo photo;
  final String previewUrl;

  @override
  Widget build(BuildContext context) {
    final aspectRatio = photo.width == 0 || photo.height == 0
        ? 1.0
        : photo.width / photo.height;

    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () {
        showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          builder: (context) => PhotoDetailSheet(photo: photo),
        );
      },
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: aspectRatio.clamp(0.7, 1.4),
              child: CachedNetworkImage(
                imageUrl: previewUrl,
                fit: BoxFit.cover,
                errorWidget: (context, _, __) => const ColoredBox(
                  color: Color(0xFFE6E1D8),
                  child: Center(
                    child: Icon(Icons.broken_image_outlined),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                photo.filename,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
