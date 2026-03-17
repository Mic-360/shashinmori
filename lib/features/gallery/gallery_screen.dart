import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_provider.dart';
import '../../shared/widgets/error_view.dart';
import '../../shared/widgets/loading_shimmer.dart';
import '../../shared/widgets/photo_grid.dart';
import 'gallery_provider.dart';
import 'photo_card.dart';

class GalleryScreen extends ConsumerStatefulWidget {
  const GalleryScreen({super.key});

  @override
  ConsumerState<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends ConsumerState<GalleryScreen> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_handleScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = ref.read(galleryControllerProvider);
      if (state.photos.isEmpty && !state.isLoading) {
        ref.read(galleryControllerProvider.notifier).loadInitial();
      }
    });
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) {
      return;
    }

    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent * 0.8) {
      ref.read(galleryControllerProvider.notifier).loadMore();
    }
  }

  int _columnCount(double width) {
    if (width >= 1400) {
      return 5;
    }
    if (width >= 900) {
      return 4;
    }
    if (width >= 600) {
      return 3;
    }
    final orientation = MediaQuery.of(context).orientation;
    return orientation == Orientation.landscape ? 3 : 2;
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_handleScroll)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(galleryControllerProvider);
    final authToken = ref.watch(authTokenProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = _columnCount(constraints.maxWidth);

        if (state.isLoading && state.photos.isEmpty) {
          return LoadingShimmer(crossAxisCount: columns);
        }

        if (state.errorMessage != null && state.photos.isEmpty) {
          return ErrorView(
            message: state.errorMessage!,
            onRetry: () => ref.read(galleryControllerProvider.notifier).loadInitial(),
          );
        }

        if (authToken.isLoading && state.photos.isNotEmpty) {
          return LoadingShimmer(crossAxisCount: columns);
        }

        final token = authToken.value;
        if (token == null) {
          return ErrorView(
            message: 'Your session expired. Please sign in again.',
            onRetry: () => ref.read(galleryControllerProvider.notifier).refresh(),
          );
        }

        if (state.photos.isEmpty) {
          return RefreshIndicator(
            onRefresh: () => ref.read(galleryControllerProvider.notifier).refresh(),
            child: ListView(
              children: const [
                SizedBox(height: 160),
                Icon(Icons.photo_library_outlined, size: 64),
                SizedBox(height: 16),
                Center(child: Text('No photos yet')),
                SizedBox(height: 8),
                Center(child: Text('Upload the first family memory to get started.')),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => ref.read(galleryControllerProvider.notifier).refresh(),
          child: Stack(
            children: [
              PhotoGrid(
                controller: _scrollController,
                crossAxisCount: columns,
                itemCount: state.photos.length,
                itemBuilder: (context, index) {
                  final photo = state.photos[index];
                  final previewUrl = ref
                      .read(galleryRepositoryProvider)
                      .getPreviewUrl(photo.photoId, token);
                  return PhotoCard(
                    photo: photo,
                    previewUrl: previewUrl,
                  );
                },
              ),
              if (state.isLoadingMore)
                const Positioned(
                  left: 0,
                  right: 0,
                  bottom: 24,
                  child: Center(child: CircularProgressIndicator()),
                ),
            ],
          ),
        );
      },
    );
  }
}
