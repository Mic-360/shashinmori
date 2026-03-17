import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'upload_provider.dart';

class UploadProgressSheet extends ConsumerWidget {
  const UploadProgressSheet({super.key});

  String _phaseLabel(UploadPhase phase) {
    return switch (phase) {
      UploadPhase.picking => 'Picking',
      UploadPhase.uploading => 'Uploading',
      UploadPhase.syncing => 'Syncing',
      UploadPhase.done => 'Done',
      UploadPhase.failed => 'Failed',
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(uploadControllerProvider);

    if (tasks.isEmpty) {
      return const Center(
        child: Text('No active uploads yet. Start one from the upload button.'),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: tasks.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final task = tasks[index];
        final colorScheme = Theme.of(context).colorScheme;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.filename,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: task.phase == UploadPhase.failed ? null : task.transferProgress,
                  color: task.phase == UploadPhase.failed
                      ? colorScheme.error
                      : colorScheme.primary,
                ),
                const SizedBox(height: 8),
                Text(_phaseLabel(task.phase)),
                if (task.errorMessage != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    task.errorMessage!,
                    style: TextStyle(color: colorScheme.error),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
