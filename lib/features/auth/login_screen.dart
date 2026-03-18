import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../shared/models/app_error.dart';
import '../../shared/widgets/animated_background.dart';
import 'auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  late final AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    setState(() => _isLoading = true);

    try {
      await ref.read(authRepositoryProvider).signInWithGoogle();
    } catch (error) {
      final appError = error is AppError
          ? error
          : const AppError(
              code: 'SIGN_IN_FAILED',
              message: 'Unable to sign in right now.',
            );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(appError.message)),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 900;
          final isDark = Theme.of(context).brightness == Brightness.dark;

          final signInForm = FadeTransition(
            opacity: CurvedAnimation(
              parent: _fadeController,
              curve: Curves.easeOut,
            ),
            child: Center(
              child: AnimatedBuilder(
                animation: _fadeController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, 20 * (1 - Curves.easeOutCubic.transform(_fadeController.value))),
                    child: child,
                  );
                },
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1A1F1C).withValues(alpha: 0.7) : Colors.white.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(36),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.08),
                          blurRadius: 40,
                          offset: const Offset(0, 20),
                        ),
                        BoxShadow(
                          color: Colors.white.withValues(alpha: isDark ? 0.05 : 0.8),
                          blurRadius: 0,
                          spreadRadius: 1,
                          offset: const Offset(0, 1),
                        ),
                      ],
                      border: Border.all(
                        color: Colors.white.withValues(alpha: isDark ? 0.1 : 0.5),
                        width: 1.5,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(36),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                        child: Padding(
                          padding: const EdgeInsets.all(48),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                'assets/favicon.svg',
                                width: 72,
                                height: 72,
                              ),
                              const SizedBox(height: 24),
                              Text(
                                'ShashinMori',
                                style: tt.displaySmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -0.5,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Sign in to start utilizing your Pixel storage',
                                style: tt.bodyMedium?.copyWith(
                                  color: cs.onSurface.withValues(alpha: 0.7),
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 48),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: _isLoading ? null : _signIn,
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 18,
                                    ),
                                    backgroundColor: isDark ? const Color(0xFF2C322E) : Colors.white,
                                    foregroundColor: isDark ? Colors.white : Colors.black87,
                                    elevation: 2,
                                    shadowColor: Colors.black.withValues(alpha: 0.2),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                  ),
                                  icon: _isLoading
                                      ? SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: isDark ? Colors.white : Colors.black87,
                                          ),
                                        )
                                      : SvgPicture.network(
                                          'https://upload.wikimedia.org/wikipedia/commons/c/c1/Google_%22G%22_logo.svg',
                                          width: 24,
                                          height: 24,
                                        ),
                                  label: Text(
                                    _isLoading
                                        ? 'Signing in\u2026'
                                        : 'Continue with Google',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: -0.2,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton(
                                  onPressed: () => Navigator.of(context).maybePop(),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                  ),
                                  child: const Text('Back'),
                                ),
                              ),
                              const SizedBox(height: 32),
                              Text(
                                'Your photos are private and separated by Firestore security rules.',
                                style: tt.bodySmall?.copyWith(
                                  color: cs.onSurface.withValues(alpha: 0.5),
                                  height: 1.4,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );

          if (!isWide) {
            return Stack(
              children: [
                const Positioned.fill(child: AnimatedBackground()),
                SafeArea(child: signInForm),
              ],
            );
          }

          return Row(
            children: [
              // Left panel - branding
              Expanded(
                child: Stack(
                  children: [
                    const Positioned.fill(child: AnimatedBackground(forceDark: true)),
                    Container(
                      padding: const EdgeInsets.all(64),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Revive your\nold Pixel.',
                            style: tt.displayMedium?.copyWith(
                              color: Colors.white,
                              height: 1.1,
                              letterSpacing: -1.0,
                            ),
                          ),
                          const SizedBox(height: 20),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 400),
                            child: Text(
                              'ShashinMori bridges your current device and your old Pixel '
                              'to bring you unlimited Google Photos storage, fully automated.',
                              style: tt.bodyLarge?.copyWith(
                                color: Colors.white.withValues(alpha: 0.7),
                                height: 1.6,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Right panel - sign-in form
              Expanded(child: signInForm),
            ],
          );
        },
      ),
    );
  }
}


