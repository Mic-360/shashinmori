import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../shared/models/app_error.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 900;

          final signInForm = FadeTransition(
            opacity: CurvedAnimation(
              parent: _fadeController,
              curve: Curves.easeOut,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Logo
                      SvgPicture.asset(
                        'web/favicon.svg',
                        width: 80,
                        height: 80,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'ShashinMori',
                        style: tt.headlineLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Sign in to access your family\'s photo forest',
                        style: tt.bodyLarge?.copyWith(
                          color: cs.onSurface.withValues(alpha: 0.6),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),
                      // Google sign-in button styled like M3 Expressive
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: _isLoading ? null : _signIn,
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 18,
                            ),
                          ),
                          icon: _isLoading
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: cs.onPrimary,
                                  ),
                                )
                              : const Icon(Icons.login_rounded),
                          label: Text(
                            _isLoading
                                ? 'Signing in\u2026'
                                : 'Continue with Google',
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).maybePop(),
                          child: const Text('Back'),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        'Your photos are encrypted and private to your family.',
                        style: tt.bodySmall?.copyWith(
                          color: cs.onSurface.withValues(alpha: 0.4),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );

          if (!isWide) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [const Color(0xFF111512), const Color(0xFF0D2818)]
                      : [const Color(0xFFFAFDF7), const Color(0xFFE8F5E9)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: SafeArea(child: signInForm),
            );
          }

          return Row(
            children: [
              // Left panel - branding
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF1B3A2D), Color(0xFF2E5E3F)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  padding: const EdgeInsets.all(64),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SvgPicture.asset(
                        'web/favicon.svg',
                        width: 64,
                        height: 64,
                        colorFilter: const ColorFilter.mode(
                          Color(0xFFA5D6A7),
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        'Preserve the\nquiet moments.',
                        style: tt.displaySmall?.copyWith(
                          color: Colors.white,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 400),
                        child: Text(
                          'ShashinMori keeps uploads resilient, the gallery '
                          'current, and family photos organized across web '
                          'and Android.',
                          style: tt.bodyLarge?.copyWith(
                            color: Colors.white.withValues(alpha: 0.7),
                            height: 1.6,
                          ),
                        ),
                      ),
                    ],
                  ),
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
