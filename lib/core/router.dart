import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/auth_provider.dart';
import '../features/auth/login_screen.dart';
import '../features/gallery/gallery_screen.dart';
import '../features/upload/upload_fab.dart';
import '../features/upload/upload_progress_sheet.dart';
import '../shared/widgets/adaptive_scaffold.dart';

final routerProvider = Provider<GoRouter>((ref) {
  ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/gallery',
    redirect: (context, state) {
      final signedIn = FirebaseAuth.instance.currentUser != null;
      final onLogin = state.matchedLocation == '/login';

      if (!signedIn) {
        return onLogin ? null : '/login';
      }

      if (onLogin) {
        return '/gallery';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => _AppShell(
          location: state.matchedLocation,
          child: child,
        ),
        routes: [
          GoRoute(
            path: '/gallery',
            builder: (context, state) => const GalleryScreen(),
          ),
          GoRoute(
            path: '/uploads',
            builder: (context, state) => const UploadProgressSheet(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const _ProfileScreen(),
          ),
        ],
      ),
    ],
  );
});

class _AppShell extends StatelessWidget {
  const _AppShell({
    required this.location,
    required this.child,
  });

  final String location;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final currentIndex = switch (location) {
      '/uploads' => 1,
      '/profile' => 2,
      _ => 0,
    };

    return AdaptiveScaffold(
      currentIndex: currentIndex,
      onDestinationSelected: (index) {
        switch (index) {
          case 0:
            context.go('/gallery');
          case 1:
            context.go('/uploads');
          case 2:
            context.go('/profile');
        }
      },
      destinations: const [
        AdaptiveDestination(
          icon: Icons.photo_library_outlined,
          selectedIcon: Icons.photo_library,
          label: 'Gallery',
        ),
        AdaptiveDestination(
          icon: Icons.cloud_upload_outlined,
          selectedIcon: Icons.cloud_upload,
          label: 'Uploads',
        ),
        AdaptiveDestination(
          icon: Icons.account_circle_outlined,
          selectedIcon: Icons.account_circle,
          label: 'Profile',
        ),
      ],
      floatingActionButton: currentIndex == 2 ? null : const UploadFab(),
      child: child,
    );
  }
}

class _ProfileScreen extends ConsumerWidget {
  const _ProfileScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = FirebaseAuth.instance.currentUser;
    final authRepository = ref.watch(authRepositoryProvider);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Family profile',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 12),
                  Text(user?.displayName ?? 'Signed in'),
                  const SizedBox(height: 8),
                  Text(user?.email ?? ''),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () async {
                      await authRepository.signOut();
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text('Sign out'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
