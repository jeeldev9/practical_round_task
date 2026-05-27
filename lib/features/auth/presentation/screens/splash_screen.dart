import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../generated/assets.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  // Logo: scale up from 0.7 → 1.0
  late final Animation<double> _logoScale;

  // Everything: fade in 0 → 1
  late final Animation<double> _fadeIn;

  // Tagline: slide up from below
  late final Animation<Offset> _taglineSlide;

  // Bottom section: fade in slightly later
  late final Animation<double> _bottomFade;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );

    // Logo pops in with elastic bounce in the first 55% of the timeline
    _logoScale = _controller.drive(
      Tween<double>(begin: 0.65, end: 1.0).chain(
        CurveTween(curve: const Interval(0.0, 0.55, curve: Curves.elasticOut)),
      ),
    );

    // Full screen fade — covers 0 → 45% of timeline
    _fadeIn = _controller.drive(
      Tween<double>(begin: 0.0, end: 1.0).chain(
        CurveTween(curve: const Interval(0.0, 0.45, curve: Curves.easeIn)),
      ),
    );

    // Tagline slides up from 30px below — runs from 35% → 80%
    _taglineSlide = _controller.drive(
      Tween<Offset>(begin: const Offset(0, 0.6), end: Offset.zero).chain(
        CurveTween(
            curve: const Interval(0.35, 0.80, curve: Curves.easeOutCubic)),
      ),
    );

    // Bottom spinner fades in late — 60% → 100%
    _bottomFade = _controller.drive(
      Tween<double>(begin: 0.0, end: 1.0).chain(
        CurveTween(curve: const Interval(0.60, 1.0, curve: Curves.easeIn)),
      ),
    );

    // Wait for the first frame before starting — prevents choppy first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: const [0.0, 0.5, 1.0],
            colors: isDark
                ? [
                    const Color(0xFF0D0D1A),
                    const Color(0xFF1A1040),
                    const Color(0xFF0D0D1A),
                  ]
                : [
                    const Color(0xFFEEECFF),
                    const Color(0xFFFFFFFF),
                    const Color(0xFFEDF0FF),
                  ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // ── Decorative top-right glow ───────────────────────────────
              Positioned(
                top: -60,
                right: -60,
                child: Container(
                  width: 240,
                  height: 240,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.primary.withValues(alpha: isDark ? 0.25 : 0.15),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              // ── Decorative bottom-left glow ─────────────────────────────
              Positioned(
                bottom: -80,
                left: -80,
                child: Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.accent.withValues(alpha: isDark ? 0.12 : 0.08),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              // ── Main content ────────────────────────────────────────────
              Column(
                children: [
                  // Center section: logo + title + tagline
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Animated logo card
                          ScaleTransition(
                            scale: _logoScale,
                            child: FadeTransition(
                              opacity: _fadeIn,
                              child: _buildLogoCard(isDark),
                            ),
                          ),

                          const SizedBox(height: 36),

                          // App name fades in with logo
                          FadeTransition(
                            opacity: _fadeIn,
                            child: Text(
                              'Smart Task Manager',
                              style: GoogleFonts.poppins(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : AppColors.textPrimary,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),

                          // Tagline slides up
                          SlideTransition(
                            position: _taglineSlide,
                            child: FadeTransition(
                              opacity: _fadeIn,
                              child: Text(
                                'Manage tasks, anywhere.',
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400,
                                  color: isDark
                                      ? Colors.white54
                                      : AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Bottom: loading indicator fades in last
                  FadeTransition(
                    opacity: _bottomFade,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 52),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 26,
                            height: 26,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                AppColors.primary,
                              ),
                              backgroundColor:
                                  AppColors.primary.withValues(alpha: 0.12),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            'Getting things ready...',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.white38 : AppColors.textHint,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
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

  Widget _buildLogoCard(bool isDark) {
    return Container(
      width: 116,
      height: 116,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: isDark ? const Color(0xFF1C1C2E) : Colors.white,
        boxShadow: [
          // Brand purple glow
          BoxShadow(
            color: AppColors.primary.withValues(alpha: isDark ? 0.40 : 0.22),
            blurRadius: 48,
            spreadRadius: 4,
            offset: const Offset(0, 10),
          ),
          // Subtle dark shadow for depth
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.10),
            blurRadius: 24,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Image.asset(
            Assets.imagesAppIcon,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
