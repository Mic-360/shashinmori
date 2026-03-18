import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen>
    with TickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final AnimationController _floatController;
  late final ScrollController _scrollController;
  bool _showTopBar = false;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
    _scrollController = ScrollController()..addListener(_onScroll);
  }

  void _onScroll() {
    final show = _scrollController.offset > 80;
    if (show != _showTopBar) setState(() => _showTopBar = show);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _floatController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverToBoxAdapter(child: _HeroSection(
                fadeController: _fadeController,
                floatController: _floatController,
                onGetStarted: () => context.go('/login'),
              )),
              SliverToBoxAdapter(child: _FeaturesSection()),
              const SliverToBoxAdapter(child: _MascotStorySection()),
              const SliverToBoxAdapter(child: _ApiDocsSection()),
              SliverToBoxAdapter(child: _FooterSection(
                onGetStarted: () => context.go('/login'),
              )),
            ],
          ),
          // Floating top bar
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            top: _showTopBar ? 0 : -80,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 8,
                left: 20,
                right: 20,
                bottom: 8,
              ),
              decoration: BoxDecoration(
                color: cs.surface.withValues(alpha: 0.92),
                border: Border(
                  bottom: BorderSide(
                    color: cs.outlineVariant.withValues(alpha: 0.2),
                  ),
                ),
              ),
              child: Row(
                children: [
                  SvgPicture.asset(
                    'web/favicon.svg',
                    width: 32,
                    height: 32,
                  ),
                  const SizedBox(width: 12),
                  Text('ShashinMori', style: tt.titleMedium),
                  const Spacer(),
                  FilledButton(
                    onPressed: () => context.go('/login'),
                    child: const Text('Sign in'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ───────────────────────────────────────────
// HERO SECTION
// ───────────────────────────────────────────
class _HeroSection extends StatelessWidget {
  const _HeroSection({
    required this.fadeController,
    required this.floatController,
    required this.onGetStarted,
  });

  final AnimationController fadeController;
  final AnimationController floatController;
  final VoidCallback onGetStarted;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      constraints: const BoxConstraints(minHeight: 600),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF0D2818),
                  const Color(0xFF111512),
                  const Color(0xFF1A1C0E),
                ]
              : [
                  const Color(0xFFE8F5E9),
                  const Color(0xFFFAFDF7),
                  const Color(0xFFFFF8E1),
                ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 900;
            final isMedium = constraints.maxWidth >= 600;

            return Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isWide ? 80 : (isMedium ? 40 : 24),
                vertical: isWide ? 80 : 48,
              ),
              child: isWide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(child: _heroText(context)),
                        const SizedBox(width: 64),
                        Expanded(child: _heroMascot(context)),
                      ],
                    )
                  : Column(
                      children: [
                        _heroMascot(context),
                        const SizedBox(height: 40),
                        _heroText(context),
                      ],
                    ),
            );
          },
        ),
      ),
    );
  }

  Widget _heroMascot(BuildContext context) {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: fadeController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
      ),
      child: AnimatedBuilder(
        animation: floatController,
        builder: (context, child) {
          final offset = math.sin(floatController.value * math.pi) * 12;
          return Transform.translate(
            offset: Offset(0, -offset),
            child: child,
          );
        },
        child: Container(
          constraints: const BoxConstraints(maxWidth: 360, maxHeight: 360),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2E7D32).withValues(alpha: 0.15),
                blurRadius: 80,
                spreadRadius: 20,
              ),
            ],
          ),
          child: SvgPicture.asset(
            'web/favicon.svg',
            width: 300,
            height: 300,
          ),
        ),
      ),
    );
  }

  Widget _heroText(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isWide = MediaQuery.of(context).size.width >= 900;

    return FadeTransition(
      opacity: CurvedAnimation(
        parent: fadeController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
      ),
      child: Column(
        crossAxisAlignment:
            isWide ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: cs.primaryContainer.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.eco, size: 16, color: cs.primary),
                const SizedBox(width: 8),
                Text(
                  'Your Family\'s Photo Forest',
                  style: tt.labelLarge?.copyWith(color: cs.primary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Every photo\nfinds its place\nin the forest.',
            style: tt.displayMedium?.copyWith(
              height: 1.1,
              color: cs.onSurface,
            ),
            textAlign: isWide ? TextAlign.start : TextAlign.center,
          ),
          const SizedBox(height: 20),
          Text(
            'ShashinMori keeps your family memories safe, organized, '
            'and beautifully preserved across all your devices.',
            style: tt.bodyLarge?.copyWith(
              color: cs.onSurface.withValues(alpha: 0.7),
              height: 1.6,
            ),
            textAlign: isWide ? TextAlign.start : TextAlign.center,
          ),
          const SizedBox(height: 36),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment:
                isWide ? WrapAlignment.start : WrapAlignment.center,
            children: [
              FilledButton.icon(
                onPressed: onGetStarted,
                icon: const Icon(Icons.arrow_forward_rounded),
                label: const Text('Get started'),
              ),
              OutlinedButton.icon(
                onPressed: () {
                  Scrollable.ensureVisible(
                    context,
                    duration: const Duration(milliseconds: 600),
                  );
                },
                icon: const Icon(Icons.info_outline),
                label: const Text('Learn more'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ───────────────────────────────────────────
// FEATURES SECTION
// ───────────────────────────────────────────
class _FeaturesSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isWide = MediaQuery.of(context).size.width >= 900;
    final isMedium = MediaQuery.of(context).size.width >= 600;

    final features = [
      _FeatureData(
        icon: Icons.cloud_upload_outlined,
        title: 'Resilient uploads',
        description:
            'TUS-based resumable uploads that survive network drops. '
            'Your photos always arrive safely.',
        color: cs.primary,
        containerColor: cs.primaryContainer,
      ),
      _FeatureData(
        icon: Icons.photo_library_outlined,
        title: 'Beautiful gallery',
        description:
            'Browse your memories in a Google Photos-inspired masonry grid. '
            'Fast, responsive, and delightful.',
        color: cs.tertiary,
        containerColor: cs.tertiaryContainer,
      ),
      _FeatureData(
        icon: Icons.devices_outlined,
        title: 'Everywhere you are',
        description:
            'Works seamlessly on Android, desktop browsers, and mobile web. '
            'One app, every screen.',
        color: cs.secondary,
        containerColor: cs.secondaryContainer,
      ),
      _FeatureData(
        icon: Icons.lock_outlined,
        title: 'Family-first privacy',
        description:
            'Firebase authentication keeps your memories private. '
            'Only your family sees your photos.',
        color: cs.error,
        containerColor: cs.errorContainer,
      ),
    ];

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isWide ? 80 : (isMedium ? 40 : 24),
        vertical: 80,
      ),
      child: Column(
        children: [
          Text(
            'Built for families who care',
            style: tt.headlineLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Text(
              'Simple, secure, and beautiful photo management '
              'that respects your privacy.',
              style: tt.bodyLarge?.copyWith(
                color: cs.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 48),
          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth >= 900
                  ? 4
                  : constraints.maxWidth >= 600
                      ? 2
                      : 1;
              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: features.map((f) {
                  final cardWidth = crossAxisCount == 1
                      ? constraints.maxWidth
                      : (constraints.maxWidth - 16 * (crossAxisCount - 1)) /
                          crossAxisCount;
                  return SizedBox(
                    width: cardWidth,
                    child: _FeatureCard(data: f),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _FeatureData {
  const _FeatureData({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.containerColor,
  });
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final Color containerColor;
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({required this.data});
  final _FeatureData data;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: data.containerColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(data.icon, color: data.color, size: 28),
            ),
            const SizedBox(height: 20),
            Text(data.title, style: tt.titleMedium),
            const SizedBox(height: 8),
            Text(
              data.description,
              style: tt.bodyMedium?.copyWith(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.6),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ───────────────────────────────────────────
// MASCOT STORY SECTION
// ───────────────────────────────────────────
class _MascotStorySection extends StatelessWidget {
  const _MascotStorySection();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isWide = MediaQuery.of(context).size.width >= 900;
    final isMedium = MediaQuery.of(context).size.width >= 600;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? [const Color(0xFF0D2818), const Color(0xFF111512)]
              : [const Color(0xFFE8F5E9), const Color(0xFFFAFDF7)],
        ),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isWide ? 80 : (isMedium ? 40 : 24),
        vertical: 80,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: isWide
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: _storyContent(context),
                    ),
                    const SizedBox(width: 64),
                    Expanded(child: _storyIllustration(context)),
                  ],
                )
              : Column(
                  children: [
                    _storyIllustration(context),
                    const SizedBox(height: 40),
                    _storyContent(context),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _storyIllustration(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withValues(
              alpha: 0.3,
            ),
        borderRadius: BorderRadius.circular(32),
      ),
      child: SvgPicture.asset(
        'web/favicon.svg',
        width: 200,
        height: 200,
      ),
    );
  }

  Widget _storyContent(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: cs.tertiaryContainer.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            'The story',
            style: tt.labelMedium?.copyWith(color: cs.onTertiaryContainer),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'The tale of Mori,\nthe Photo Forest Fairy',
          style: tt.headlineLarge?.copyWith(height: 1.2),
        ),
        const SizedBox(height: 24),
        _storyParagraph(
          context,
          'Deep within the digital realm, where pixels dance like fireflies '
          'and memories flow like gentle streams, there lives a kind fairy '
          'named Mori \u2014 the guardian of the Photo Forest.',
        ),
        const SizedBox(height: 16),
        _storyParagraph(
          context,
          'Long ago, when families began capturing moments with their cameras, '
          'these precious memories would scatter like autumn leaves in the wind '
          '\u2014 lost in forgotten folders, trapped in old devices, fading with time. '
          'Mori saw the sadness this brought and decided to create something magical.',
        ),
        const SizedBox(height: 16),
        _storyParagraph(
          context,
          'She planted the first Memory Tree from a single family photograph. '
          'As more photos were entrusted to her care, the forest grew. Each '
          'photograph became a seed, and each seed grew into a luminous tree '
          'whose leaves shimmered with the colors of the captured moment.',
        ),
        const SizedBox(height: 16),
        _storyParagraph(
          context,
          'Now, Mori tends to thousands of Memory Trees, each one preserving '
          'a family\'s most cherished moments. She ensures no photograph is '
          'ever lost, no memory ever fades. When you upload a photo to '
          'ShashinMori, Mori carefully plants it in the perfect spot in her '
          'forest, where the light catches it just right and it can grow '
          'alongside your other memories \u2014 safe and beautiful, forever.',
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHigh.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(20),
            border: Border(
              left: BorderSide(color: cs.primary, width: 3),
            ),
          ),
          child: Text(
            'ShashinMori (\u5199\u771f\u68ee\u308a) \u2014 '
            'Where every photo finds its place in the forest.',
            style: tt.titleSmall?.copyWith(
              fontStyle: FontStyle.italic,
              color: cs.onSurface.withValues(alpha: 0.8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _storyParagraph(BuildContext context, String text) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(context)
                .colorScheme
                .onSurface
                .withValues(alpha: 0.75),
            height: 1.7,
          ),
    );
  }
}

// ───────────────────────────────────────────
// API DOCUMENTATION SECTION
// ───────────────────────────────────────────
class _ApiDocsSection extends StatelessWidget {
  const _ApiDocsSection();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isWide = MediaQuery.of(context).size.width >= 900;
    final isMedium = MediaQuery.of(context).size.width >= 600;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isWide ? 80 : (isMedium ? 40 : 24),
        vertical: 80,
      ),
      child: Column(
        children: [
          Text('API reference', style: tt.headlineLarge,
              textAlign: TextAlign.center),
          const SizedBox(height: 12),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Text(
              'ShashinMori exposes a RESTful API built on Fastify with '
              'Firebase authentication, TUS resumable uploads, and '
              'Swagger/OpenAPI documentation.',
              style: tt.bodyLarge?.copyWith(
                color: cs.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 48),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 960),
              child: Column(
                children: [
                  _ApiGroupCard(
                    title: 'Authentication',
                    icon: Icons.lock_outline,
                    color: cs.primary,
                    endpoints: const [
                      _EndpointData(
                        method: 'POST',
                        path: '/v1/auth/profile',
                        description:
                            'Upsert user profile. Creates or updates the '
                            'user record in Firestore after Firebase token '
                            'verification. Returns the user profile.',
                        auth: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _ApiGroupCard(
                    title: 'Photos',
                    icon: Icons.photo_library_outlined,
                    color: cs.tertiary,
                    endpoints: const [
                      _EndpointData(
                        method: 'GET',
                        path: '/v1/photos',
                        description:
                            'List photos with cursor-based pagination. '
                            'Returns photo metadata with nextCursor and '
                            'hasMore flags for infinite scroll.',
                        auth: true,
                        params: 'cursor, limit (default: 20)',
                      ),
                      _EndpointData(
                        method: 'GET',
                        path: '/v1/photos/:photoId/preview',
                        description:
                            'Stream a thumbnail/preview image for the given '
                            'photo. Optimized for gallery grid display.',
                        auth: true,
                        params: 'token (query)',
                      ),
                      _EndpointData(
                        method: 'GET',
                        path: '/v1/photos/:photoId/image',
                        description:
                            'Stream the full-resolution original image. '
                            'Used in the detail view.',
                        auth: true,
                        params: 'token (query)',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _ApiGroupCard(
                    title: 'Uploads (TUS protocol)',
                    icon: Icons.cloud_upload_outlined,
                    color: const Color(0xFF7B61FF),
                    endpoints: const [
                      _EndpointData(
                        method: 'POST',
                        path: '/v1/uploads',
                        description:
                            'Create a new TUS upload. Parses Upload-Metadata '
                            'header for filename, filetype, and size. Queues '
                            'the upload for background processing.',
                        auth: true,
                      ),
                      _EndpointData(
                        method: 'PATCH',
                        path: '/v1/uploads/:uploadId',
                        description:
                            'Continue a resumable upload. Appends bytes to '
                            'the upload at the given offset.',
                        auth: true,
                      ),
                      _EndpointData(
                        method: 'HEAD',
                        path: '/v1/uploads/:uploadId',
                        description:
                            'Get upload status and current offset for '
                            'resumption after network interruptions.',
                        auth: true,
                      ),
                      _EndpointData(
                        method: 'OPTIONS',
                        path: '/v1/uploads',
                        description:
                            'TUS protocol discovery. Returns supported '
                            'extensions and max upload size.',
                        auth: false,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _ApiGroupCard(
                    title: 'System',
                    icon: Icons.monitor_heart_outlined,
                    color: cs.secondary,
                    endpoints: const [
                      _EndpointData(
                        method: 'GET',
                        path: '/v1/system/health',
                        description:
                            'Health check endpoint. Returns server uptime '
                            'and status. No authentication required.',
                        auth: false,
                      ),
                      _EndpointData(
                        method: 'GET',
                        path: '/v1/system/status',
                        description:
                            'System status with storage metrics, queue '
                            'state (BullMQ), and backup detection results.',
                        auth: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Card(
                    color: cs.surfaceContainerHigh,
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.info_outline, color: cs.primary,
                                  size: 20),
                              const SizedBox(width: 8),
                              Text('Additional info',
                                  style: tt.titleSmall),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _infoRow(context, 'Base URL',
                              'Configured via API_BASE_URL env variable'),
                          _infoRow(context, 'Auth',
                              'Firebase ID token in Authorization: Bearer header'),
                          _infoRow(context, 'Rate limiting',
                              'Fastify rate-limit plugin (configurable)'),
                          _infoRow(context, 'Docs',
                              'Interactive Swagger UI at /docs'),
                          _infoRow(context, 'OpenAPI spec',
                              'Available at /openapi.json'),
                          _infoRow(context, 'Workers',
                              'Upload processing, thumbnail generation, '
                              'backup detection, storage guard, cleanup'),
                          _infoRow(context, 'Storage',
                              'Google Cloud Storage with local filesystem '
                              'fallback'),
                          _infoRow(context, 'Queue',
                              'BullMQ with Redis for job processing'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(BuildContext context, String label, String value) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label,
                style: tt.labelMedium?.copyWith(color: cs.primary)),
          ),
          Expanded(
            child: Text(value,
                style: tt.bodySmall?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.7))),
          ),
        ],
      ),
    );
  }
}

class _EndpointData {
  const _EndpointData({
    required this.method,
    required this.path,
    required this.description,
    required this.auth,
    this.params,
  });
  final String method;
  final String path;
  final String description;
  final bool auth;
  final String? params;
}

class _ApiGroupCard extends StatelessWidget {
  const _ApiGroupCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.endpoints,
  });

  final String title;
  final IconData icon;
  final Color color;
  final List<_EndpointData> endpoints;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Card(
      child: Padding(
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
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Text(title, style: tt.titleMedium),
              ],
            ),
            const SizedBox(height: 20),
            ...endpoints.map((e) => _EndpointTile(endpoint: e)),
          ],
        ),
      ),
    );
  }
}

class _EndpointTile extends StatelessWidget {
  const _EndpointTile({required this.endpoint});
  final _EndpointData endpoint;

  Color _methodColor(String method) {
    return switch (method) {
      'GET' => const Color(0xFF2E7D32),
      'POST' => const Color(0xFFF9A825),
      'PATCH' => const Color(0xFF1565C0),
      'HEAD' => const Color(0xFF7B61FF),
      'OPTIONS' => const Color(0xFF78909C),
      'DELETE' => const Color(0xFFBA1A1A),
      _ => const Color(0xFF78909C),
    };
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final methodColor = _methodColor(endpoint.method);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: methodColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  endpoint.method,
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: methodColor,
                  ),
                ),
              ),
              Text(
                endpoint.path,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 13,
                  color: cs.onSurface,
                ),
              ),
              if (endpoint.auth)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: cs.primaryContainer.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.lock, size: 10, color: cs.primary),
                      const SizedBox(width: 4),
                      Text('Auth',
                          style: tt.labelSmall
                              ?.copyWith(color: cs.primary)),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            endpoint.description,
            style: tt.bodySmall?.copyWith(
              color: cs.onSurface.withValues(alpha: 0.6),
              height: 1.5,
            ),
          ),
          if (endpoint.params != null) ...[
            const SizedBox(height: 6),
            Text(
              'Params: ${endpoint.params}',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 11,
                color: cs.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ───────────────────────────────────────────
// FOOTER SECTION
// ───────────────────────────────────────────
class _FooterSection extends StatelessWidget {
  const _FooterSection({required this.onGetStarted});
  final VoidCallback onGetStarted;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0D2818) : const Color(0xFF1B3A2D),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 64),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
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
              const SizedBox(height: 20),
              Text(
                'Ready to grow your forest?',
                style: tt.headlineMedium?.copyWith(color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Start preserving your family\'s most precious moments today.',
                style: tt.bodyLarge?.copyWith(
                  color: Colors.white.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: onGetStarted,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFA5D6A7),
                  foregroundColor: const Color(0xFF002106),
                ),
                icon: const Icon(Icons.eco),
                label: const Text('Plant your first memory'),
              ),
              const SizedBox(height: 48),
              Divider(color: Colors.white.withValues(alpha: 0.15)),
              const SizedBox(height: 24),
              Text(
                '\u00a9 ShashinMori \u2014 '
                'Built with Flutter, Fastify & Firebase',
                style: tt.bodySmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.4),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
