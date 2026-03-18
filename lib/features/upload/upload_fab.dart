import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/models/app_error.dart';
import 'upload_provider.dart';

class UploadFab extends ConsumerStatefulWidget {
  const UploadFab({super.key});

  @override
  ConsumerState<UploadFab> createState() => _UploadFabState();
}

class _UploadFabState extends ConsumerState<UploadFab>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleUpload() async {
    setState(() => _isUploading = true);
    _controller.forward();

    try {
      await ref.read(uploadControllerProvider.notifier).pickAndUpload();
    } catch (error) {
      final message =
          error is AppError ? error.message : 'Unable to start an upload.';
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  Icons.error_outline,
                  color: Theme.of(context).colorScheme.onError,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(message)),
              ],
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        _controller.reverse();
        setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return FloatingActionButton.extended(
      onPressed: _isUploading ? null : _handleUpload,
      icon: _isUploading
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: cs.onPrimaryContainer,
              ),
            )
          : const Icon(Icons.add_photo_alternate_outlined),
      label: Text(_isUploading ? 'Picking\u2026' : 'Upload'),
    );
  }
}
