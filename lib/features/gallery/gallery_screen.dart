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
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent * 0.8) {
      ref.read(galleryControllerProvider.notifier).loadMore();
    }
  }

  int _columnCount(double width) {
    if (width >= 1400) return 6;
    if (width >= 1100) return 5;
    if (width >= 900) return 4;
    if (width >= 600) return 3;
    return 2;
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
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final state = ref.watch(galleryControllerProvider);
    final authToken = ref.watch(authTokenProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = _columnCount(constraints.maxWidth);
        final isWide = constraints.maxWidth >= 600;

        // Search bar header (Google Photos style)
        final searchHeader = Padding(
          padding: EdgeInsets.fromLTRB(
            isWide ? 24 : 16,
            isWide ? 16 : 8,
            isWide ? 24 : 16,
            8,
          ),
          child: SearchBar(
            backgroundColor: WidgetStatePropertyAll(
              Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF1A1F1C).withValues(alpha: 0.75)
                  : Colors.white.withValues(alpha: 0.75),
            ),
            elevation: const WidgetStatePropertyAll(0),
            hintText: 'Search your photos',
            leading: Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Icon(
                Icons.search_rounded,
                color: cs.onSurface.withValues(alpha: 0.5),
              ),
            ),
            trailing: [
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: IconButton(
                  icon: CircleAvatar(
                    radius: 16,
                    backgroundColor: cs.primaryContainer,
                    child: Icon(
                      Icons.person,
                      size: 18,
                      color: cs.onPrimaryContainer,
                    ),
                  ),
                  onPressed: () {},
                ),
              ),
            ],
            onTap: () {},
          ),
        );

        if (state.isLoading && state.photos.isEmpty) {
          return Column(
            children: [
              searchHeader,
              Expanded(child: LoadingShimmer(crossAxisCount: columns)),
            ],
          );
        }

        if (state.errorMessage != null && state.photos.isEmpty) {
          return Column(
            children: [
              searchHeader,
              Expanded(
                child: ErrorView(
                  message: state.errorMessage!,
                  onRetry: () =>
                      ref.read(galleryControllerProvider.notifier).loadInitial(),
                ),
              ),
            ],
          );
        }

        if (authToken.isLoading && state.photos.isNotEmpty) {
          return Column(
            children: [
              searchHeader,
              Expanded(child: LoadingShimmer(crossAxisCount: columns)),
            ],
          );
        }

        final token = authToken.value;
        if (token == null) {
          return Column(
            children: [
              searchHeader,
              Expanded(
                child: ErrorView(
                  message: 'Your session expired. Please sign in again.',
                  onRetry: () =>
                      ref.read(galleryControllerProvider.notifier).refresh(),
                ),
              ),
            ],
          );
        }

        if (state.photos.isEmpty) {
          return Column(
            children: [
              searchHeader,
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () =>
                      ref.read(galleryControllerProvider.notifier).refresh(),
                  child: ListView(
                    children: [
                      const SizedBox(height: 120),
                      Center(
                        child: Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            color: cs.primaryContainer.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(40),
                          ),
                          child: Icon(
                            Icons.add_photo_alternate_outlined,
                            size: 64,
                            color: cs.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'No photos yet',
                        textAlign: TextAlign.center,
                        style: tt.displaySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Upload the first family memory\nto start growing your forest.',
                        textAlign: TextAlign.center,
                        style: tt.bodyMedium?.copyWith(
                          color: cs.onSurface.withValues(alpha: 0.4),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }

        return Column(
          children: [
            searchHeader,
            Expanded(
              child: RefreshIndicator(
                onRefresh: () =>
                    ref.read(galleryControllerProvider.notifier).refresh(),
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
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 16,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: cs.surfaceContainer,
                              shape: BoxShape.circle,
                            ),
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: cs.primary,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
