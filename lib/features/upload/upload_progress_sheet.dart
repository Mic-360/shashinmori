import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../upload/upload_provider.dart';
import '../../shared/widgets/glass_card.dart';

class UploadProgressSheet extends ConsumerWidget {
  const UploadProgressSheet({super.key});

  IconData _phaseIcon(UploadPhase phase) {
    return switch (phase) {
      UploadPhase.picking => Icons.photo_library_outlined,
      UploadPhase.uploading => Icons.cloud_upload_outlined,
      UploadPhase.syncing => Icons.sync_outlined,
      UploadPhase.done => Icons.check_circle_outline,
      UploadPhase.failed => Icons.error_outline,
    };
  }

  String _phaseLabel(UploadPhase phase) {
    return switch (phase) {
      UploadPhase.picking => 'Picking file\u2026',
      UploadPhase.uploading => 'Uploading\u2026',
      UploadPhase.syncing => 'Processing\u2026',
      UploadPhase.done => 'Complete',
      UploadPhase.failed => 'Failed',
    };
  }

  Color _phaseColor(UploadPhase phase, ColorScheme cs) {
    return switch (phase) {
      UploadPhase.done => cs.primary,
      UploadPhase.failed => cs.error,
      _ => cs.tertiary,
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final tasks = ref.watch(uploadControllerProvider);

    if (tasks.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: cs.primaryContainer.withValues(alpha: 0.4),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.cloud_upload_outlined,
                  size: 56,
                  color: cs.primary,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'No uploads yet', 
                style: tt.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tap the upload button to start\nadding photos to your forest.',
                textAlign: TextAlign.center,
                style: tt.bodyMedium?.copyWith(
                  color: cs.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        final color = _phaseColor(task.phase, cs);
        final isDone = task.phase == UploadPhase.done;
        final isFailed = task.phase == UploadPhase.failed;

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: GlassCard(
            borderRadius: 24,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _phaseIcon(task.phase),
                          color: color,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              task.filename,
                              style: tt.titleSmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _phaseLabel(task.phase),
                              style: tt.labelSmall?.copyWith(color: color),
                            ),
                          ],
                        ),
                      ),
                      if (isDone)
                        Icon(Icons.check_circle, color: cs.primary, size: 24)
                      else if (isFailed)
                        Icon(Icons.cancel, color: cs.error, size: 24)
                      else
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            value: task.phase == UploadPhase.uploading
                                ? task.transferProgress
                                : null,
                            color: color,
                          ),
                        ),
                    ],
                  ),
                  if (!isDone && !isFailed) ...[
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: task.phase == UploadPhase.uploading
                            ? task.transferProgress
                            : null,
                        minHeight: 4,
                        color: color,
                        backgroundColor: color.withValues(alpha: 0.12),
                      ),
                    ),
                    if (task.phase == UploadPhase.uploading)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          '${(task.transferProgress * 100).toStringAsFixed(0)}%',
                          style: tt.labelSmall?.copyWith(
                            color: cs.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                  ],
                  if (task.errorMessage != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: cs.errorContainer.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline,
                              size: 16, color: cs.error),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              task.errorMessage!,
                              style: tt.bodySmall?.copyWith(
                                color: cs.error,
                              ),
                            ),
                          ),
                        ],
                      ),
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
