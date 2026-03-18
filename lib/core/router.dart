import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/auth_provider.dart';
import '../features/auth/login_screen.dart';
import '../features/gallery/gallery_screen.dart';
import '../features/landing/landing_screen.dart';
import '../features/upload/upload_fab.dart';
import '../features/upload/upload_progress_sheet.dart';
import '../shared/widgets/adaptive_scaffold.dart';
import '../shared/widgets/animated_background.dart';
import '../shared/widgets/glass_card.dart';

final routerProvider = Provider<GoRouter>((ref) {
  ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final signedIn = FirebaseAuth.instance.currentUser != null;
      final path = state.matchedLocation;
      final onLanding = path == '/';
      final onLogin = path == '/login';

      // If not signed in: allow landing and login, redirect others
      if (!signedIn) {
        if (onLanding || onLogin) return null;
        return '/';
      }

      // If signed in: redirect landing and login to gallery
      if (onLanding || onLogin) return '/gallery';

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const LandingScreen(),
      ),
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

    return Stack(
      children: [
        const Positioned.fill(child: AnimatedBackground()),
        AdaptiveScaffold(
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
          label: 'Photos',
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
    ),
  ],
);
  }
}

class _ProfileScreen extends ConsumerWidget {
  const _ProfileScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final user = FirebaseAuth.instance.currentUser;
    final authRepository = ref.watch(authRepositoryProvider);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Column(
            children: [
              // Avatar
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: cs.primaryContainer,
                ),
                child: user?.photoURL != null
                    ? ClipOval(
                        child: Image.network(
                          user!.photoURL!,
                          width: 96,
                          height: 96,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Icon(
                            Icons.person,
                            size: 48,
                            color: cs.onPrimaryContainer,
                          ),
                        ),
                      )
                    : Icon(
                        Icons.person,
                        size: 48,
                        color: cs.onPrimaryContainer,
                      ),
              ),
              const SizedBox(height: 20),
              Text(
                user?.displayName ?? 'Family member',
                style: tt.headlineSmall,
              ),
              const SizedBox(height: 4),
              Text(
                user?.email ?? '',
                style: tt.bodyMedium?.copyWith(
                  color: cs.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 32),

              // Settings cards
              GlassCard(
                borderRadius: 24,
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                    children: [
                      _ProfileTile(
                        icon: Icons.eco_outlined,
                        title: 'About ShashinMori',
                        subtitle: 'Your family photo forest',
                        onTap: () {},
                      ),
                      Divider(
                        indent: 56,
                        height: 1,
                        color: cs.outlineVariant.withValues(alpha: 0.2),
                      ),
                      _ProfileTile(
                        icon: Icons.storage_outlined,
                        title: 'Storage',
                        subtitle: 'View storage usage',
                        onTap: () {},
                      ),
                      Divider(
                        indent: 56,
                        height: 1,
                        color: cs.outlineVariant.withValues(alpha: 0.2),
                      ),
                      _ProfileTile(
                        icon: Icons.dark_mode_outlined,
                        title: 'Appearance',
                        subtitle: 'Following system theme',
                        onTap: () {},
                      ),
                    ],
                  ),
              ),
              const SizedBox(height: 16),
              GlassCard(
                borderRadius: 24,
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: _ProfileTile(
                  icon: Icons.logout,
                  title: 'Sign out',
                  subtitle: 'Sign out of your account',
                  iconColor: cs.error,
                  onTap: () async {
                    await authRepository.signOut();
                  },
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    'assets/favicon.svg',
                    width: 16,
                    height: 16,
                    colorFilter: ColorFilter.mode(
                      cs.onSurface.withValues(alpha: 0.3),
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'ShashinMori v1.0.0',
                    style: tt.bodySmall?.copyWith(
                      color: cs.onSurface.withValues(alpha: 0.3),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.iconColor,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return ListTile(
      leading:
          Icon(icon, color: iconColor ?? cs.onSurface.withValues(alpha: 0.7)),
      title: Text(title, style: tt.bodyLarge),
      subtitle: Text(
        subtitle,
        style: tt.bodySmall?.copyWith(
          color: cs.onSurface.withValues(alpha: 0.5),
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: cs.onSurface.withValues(alpha: 0.3),
      ),
      onTap: onTap,
    );
  }
}
