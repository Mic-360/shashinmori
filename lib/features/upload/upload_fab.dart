import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/models/app_error.dart';
import 'upload_provider.dart';

class UploadFab extends ConsumerWidget {
  const UploadFab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FloatingActionButton.extended(
      onPressed: () async {
        try {
          await ref.read(uploadControllerProvider.notifier).pickAndUpload();
        } catch (error) {
          final message = error is AppError
              ? error.message
              : 'Unable to start an upload.';
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(message)),
            );
          }
        }
      },
      icon: const Icon(Icons.add_a_photo_outlined),
      label: const Text('Upload'),
    );
  }
}
