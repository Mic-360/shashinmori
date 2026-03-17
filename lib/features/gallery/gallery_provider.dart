import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'gallery_repository.dart';

class GalleryState {
  const GalleryState({
    this.photos = const [],
    this.nextCursor,
    this.hasMore = true,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.errorMessage,
  });

  final List<Photo> photos;
  final String? nextCursor;
  final bool hasMore;
  final bool isLoading;
  final bool isLoadingMore;
  final String? errorMessage;

  GalleryState copyWith({
    List<Photo>? photos,
    String? nextCursor,
    bool? hasMore,
    bool? isLoading,
    bool? isLoadingMore,
    String? errorMessage,
    bool clearError = false,
  }) {
    return GalleryState(
      photos: photos ?? this.photos,
      nextCursor: nextCursor ?? this.nextCursor,
      hasMore: hasMore ?? this.hasMore,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class GalleryController extends Notifier<GalleryState> {
  late final GalleryRepository _repository;

  @override
  GalleryState build() {
    _repository = ref.read(galleryRepositoryProvider);
    return const GalleryState();
  }

  Future<void> loadInitial() async {
    if (state.isLoading) {
      return;
    }

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final page = await _repository.fetchPhotos();
      state = state.copyWith(
        photos: page.photos,
        nextCursor: page.nextCursor,
        hasMore: page.hasMore,
        isLoading: false,
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: error.toString(),
      );
    }
  }

  Future<void> refresh() async {
    state = state.copyWith(
      isLoading: true,
      isLoadingMore: false,
      nextCursor: null,
      hasMore: true,
      clearError: true,
    );

    try {
      final page = await _repository.fetchPhotos();
      state = state.copyWith(
        photos: page.photos,
        nextCursor: page.nextCursor,
        hasMore: page.hasMore,
        isLoading: false,
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: error.toString(),
      );
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || state.isLoading || !state.hasMore) {
      return;
    }

    state = state.copyWith(isLoadingMore: true, clearError: true);

    try {
      final page = await _repository.fetchPhotos(cursor: state.nextCursor);
      state = state.copyWith(
        photos: [...state.photos, ...page.photos],
        nextCursor: page.nextCursor,
        hasMore: page.hasMore,
        isLoadingMore: false,
      );
    } catch (error) {
      state = state.copyWith(
        isLoadingMore: false,
        errorMessage: error.toString(),
      );
    }
  }
}

final galleryRepositoryProvider = Provider<GalleryRepository>((ref) {
  return GalleryRepository();
});

final galleryControllerProvider =
    NotifierProvider<GalleryController, GalleryState>(GalleryController.new);
