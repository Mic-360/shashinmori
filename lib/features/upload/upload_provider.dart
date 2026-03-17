import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../shared/models/app_error.dart';
import '../gallery/gallery_provider.dart';
import 'upload_repository.dart';

enum UploadPhase { picking, uploading, syncing, done, failed }

class UploadTask {
  const UploadTask({
    required this.filename,
    required this.transferProgress,
    required this.phase,
    this.uploadId,
    this.errorMessage,
  });

  final String filename;
  final double transferProgress;
  final UploadPhase phase;
  final String? uploadId;
  final String? errorMessage;

  UploadTask copyWith({
    String? filename,
    double? transferProgress,
    UploadPhase? phase,
    String? uploadId,
    String? errorMessage,
    bool clearError = false,
  }) {
    return UploadTask(
      filename: filename ?? this.filename,
      transferProgress: transferProgress ?? this.transferProgress,
      phase: phase ?? this.phase,
      uploadId: uploadId ?? this.uploadId,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class UploadController extends Notifier<List<UploadTask>> {
  final Map<String, Timer> _timers = <String, Timer>{};
  late final UploadRepository _repository;

  @override
  List<UploadTask> build() {
    _repository = ref.read(uploadRepositoryProvider);
    ref.onDispose(() {
      for (final timer in _timers.values) {
        timer.cancel();
      }
    });
    return const [];
  }

  Future<void> pickAndUpload() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw const AppError(
        code: 'UNAUTHORIZED',
        message: 'Sign in before uploading.',
      );
    }

    final taskIndex = state.length;
    state = [
      ...state,
      const UploadTask(
        filename: 'Preparing upload...',
        transferProgress: 0,
        phase: UploadPhase.picking,
      ),
    ];

    try {
      final file = await _pickImage();
      if (file == null) {
        final nextState = [...state]..removeAt(taskIndex);
        state = nextState;
        return;
      }

      _updateTask(
        taskIndex,
        state[taskIndex].copyWith(
          filename: file.name,
          phase: UploadPhase.uploading,
          transferProgress: 0,
          clearError: true,
        ),
      );

      final uploadId = await _repository.startUpload(
        file: file,
        userId: user.uid,
        onProgress: (progress) {
          _updateTask(
            taskIndex,
            state[taskIndex].copyWith(
              transferProgress: progress,
              phase: UploadPhase.uploading,
            ),
          );
        },
      );

      _updateTask(
        taskIndex,
        state[taskIndex].copyWith(
          uploadId: uploadId,
          phase: UploadPhase.syncing,
          transferProgress: 1,
        ),
      );

      _startPolling(uploadId, taskIndex);
    } catch (error) {
      final message = error is AppError
          ? error.message
          : 'Upload failed to start.';
      _updateTask(
        taskIndex,
        state[taskIndex].copyWith(
          phase: UploadPhase.failed,
          errorMessage: message,
        ),
      );
    }
  }

  Future<XFile?> _pickImage() async {
    if (kIsWeb) {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        withData: true,
      );
      final file = result?.files.single;
      if (file == null || file.bytes == null) {
        return null;
      }

      return XFile.fromData(
        file.bytes!,
        name: file.name,
        mimeType: file.extension,
      );
    }

    final picker = ImagePicker();
    return picker.pickImage(source: ImageSource.gallery);
  }

  void _startPolling(String uploadId, int index) {
    _timers[uploadId]?.cancel();
    _timers[uploadId] = Timer.periodic(const Duration(seconds: 5), (timer) async {
      try {
        final result = await _repository.pollStatus(uploadId);
        if (result.status == 'available') {
          timer.cancel();
          _timers.remove(uploadId);
          _updateTask(
            index,
            state[index].copyWith(
              phase: UploadPhase.done,
              transferProgress: 1,
            ),
          );
          await ref.read(galleryControllerProvider.notifier).refresh();
          return;
        }

        if (result.status == 'failed') {
          timer.cancel();
          _timers.remove(uploadId);
          _updateTask(
            index,
            state[index].copyWith(
              phase: UploadPhase.failed,
              errorMessage: result.failureReason ?? 'Upload failed.',
            ),
          );
          return;
        }

        _updateTask(
          index,
          state[index].copyWith(
            phase: UploadPhase.syncing,
            transferProgress: 1,
          ),
        );
      } catch (error) {
        timer.cancel();
        _timers.remove(uploadId);
        _updateTask(
          index,
          state[index].copyWith(
            phase: UploadPhase.failed,
            errorMessage: error is AppError
                ? error.message
                : 'Upload status polling failed.',
          ),
        );
      }
    });
  }

  void _updateTask(int index, UploadTask task) {
    final nextState = [...state];
    nextState[index] = task;
    state = nextState;
  }
}

final uploadRepositoryProvider = Provider<UploadRepository>((ref) {
  return UploadRepository();
});

final uploadControllerProvider =
    NotifierProvider<UploadController, List<UploadTask>>(UploadController.new);
