import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_web_portfolio/app/core/constants/app_colors.dart';
import 'package:flutter_web_portfolio/app/core/constants/cinematic_curves.dart';
import 'package:flutter_web_portfolio/app/widgets/preloader_animations.dart';
import 'package:flutter_web_portfolio/app/widgets/kollywood_title_reveal.dart';

/// Cinematic preloader — a jaw-dropping intro sequence that plays once per
/// session before revealing the main portfolio content.
///
/// Sequence (across ~3.5 s master timeline):
///   0.00–0.05  Fade-in background & particles
///   0.05–0.40  Letter-by-letter name reveal
///   0.30–0.55  Tagline fade-in below name
///   0.10–0.75  Progress bar + percentage counter
///   0.78–1.00  Circle-expand reveal to main content
///
/// Usage:
/// ```dart
/// CinematicPreloader(
///   onLoadingComplete: () => loadingController.setLoading(false),
///   child: HomeView(),
/// )
/// ```
class CinematicPreloader extends StatefulWidget {
  const CinematicPreloader({
    super.key,
    required this.child,
    this.onLoadingComplete,
    this.displayName = 'MAHADEV BINIRAJ',
    this.tagline = 'Flutter Full Stack Developer',
    this.minimumDuration = const Duration(milliseconds: 5000),
    this.exitDuration = const Duration(milliseconds: 800),
  });

  /// The main content revealed after the preloader finishes.
  final Widget child;

  /// Fired once the full sequence (including exit) completes.
  final VoidCallback? onLoadingComplete;

  /// Name displayed during the letter-stagger reveal.
  final String displayName;

  /// Tagline that fades in below the name.
  final String tagline;

  /// Minimum wall-clock time the preloader is visible (for dramatic effect).
  final Duration minimumDuration;

  /// Duration of the circle-expand exit animation.
  final Duration exitDuration;

  /// Session-scoped flag — ensures the preloader plays only once.
  static bool _hasPlayedThisSession = false;

  /// Reset for testing or hot-restart scenarios.
  static void resetSessionFlag() => _hasPlayedThisSession = false;

  @override
  State<CinematicPreloader> createState() => _CinematicPreloaderState();
}

class _CinematicPreloaderState extends State<CinematicPreloader>
    with TickerProviderStateMixin {
  // ── Controllers ──────────────────────────────────────────────────────────

  /// Master timeline for the entire preloader sequence.
  AnimationController? _master;

  /// Exit animation: circle-expand reveal.
  AnimationController? _exit;

  // ── Sequenced intervals off the master controller ────────────────────────

  Animation<double>? _bgFade;
  Animation<double>? _exitReveal;

  bool _showContent = false;
  bool _preloaderDone = false;

  @override
  void initState() {
    super.initState();

    // Skip entirely if already played this session.
    if (CinematicPreloader._hasPlayedThisSession) {
      _preloaderDone = true;
      _showContent = true;
      return;
    }

    CinematicPreloader._hasPlayedThisSession = true;

    // ── Master timeline ───────────────────────────────────────────────────
    final master = AnimationController(
      vsync: this,
      duration: widget.minimumDuration,
    );
    _master = master;

    // ── Exit controller ───────────────────────────────────────────────────
    final exit = AnimationController(
      vsync: this,
      duration: widget.exitDuration,
    );
    _exit = exit;

    // ── Interval animations ───────────────────────────────────────────────

    _bgFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: master,
        curve: const Interval(0.0, 0.08, curve: Curves.easeOut),
      ),
    );

    _exitReveal = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: exit,
        curve: CinematicCurves.dramaticEntrance,
      ),
    );

    exit.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => _preloaderDone = true);
        widget.onLoadingComplete?.call();
      }
    });

    // Start the sequence
    master.forward().then((_) {
      setState(() => _showContent = true);
      // Allow one frame for the child to layout before the reveal
      WidgetsBinding.instance.addPostFrameCallback((_) {
        exit.forward();
      });
    });
  }

  @override
  void dispose() {
    _master?.dispose();
    _exit?.dispose();
    super.dispose();
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // Already played — passthrough.
    if (_preloaderDone && _showContent) {
      return widget.child;
    }

    // Skip path (shouldn't happen, but defensive).
    if (_preloaderDone) {
      return widget.child;
    }

    return Stack(
      children: [
        // Main content sits behind, ready for the reveal
        if (_showContent) Positioned.fill(child: widget.child),

        // Exit reveal clips the preloader away
        AnimatedBuilder(
          animation: _exit!,
          builder: (_, __) {
            if (_exitReveal!.value >= 1.0) return const SizedBox.shrink();

            // Inverse clip: we clip the *preloader* with an inverted circle
            return _InverseCircleClip(
              progress: _exitReveal!.value,
              child: _buildPreloaderSurface(context),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPreloaderSurface(BuildContext context) =>
    AnimatedBuilder(
      animation: _master!,
      builder: (_, __) => Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.backgroundDark
                    .withValues(alpha: _bgFade!.value),
                AppColors.background
                    .withValues(alpha: _bgFade!.value),
                const Color(0xFF0A0520)
                    .withValues(alpha: _bgFade!.value),
              ],
            ),
          ),
          child: Stack(
            children: [
              // Layer 1: Ambient particles
              Positioned.fill(
                child: Opacity(
                  opacity: _bgFade!.value,
                  child: const PreloaderParticles(
                    particleCount: 40,
                    color: AppColors.heroAccent,
                  ),
                ),
              ),

              // Layer 2: Film grain
              Positioned.fill(
                child: Opacity(
                  opacity: _bgFade!.value * 0.6,
                  child: const PreloaderFilmGrain(opacity: 0.025),
                ),
              ),

              // Layer 3: Vignette
              Positioned.fill(
                child: Opacity(
                  opacity: _bgFade!.value,
                  child: const _Vignette(),
                ),
              ),

              // Layer 4: Kollywood Title Reveal
              Positioned.fill(
                child: KollywoodTitleReveal(
                  displayName: widget.displayName,
                  tagline: widget.tagline,
                  progress: _master!.value,
                ),
              ),
            ],
          ),
        ),
      ),
    );

  // ── Responsive helpers ───────────────────────────────────────────────────

}
class _Vignette extends StatelessWidget {
  const _Vignette();

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 1.0,
          colors: [
            Colors.transparent,
            Colors.black.withValues(alpha: 0.4),
          ],
          stops: const [0.4, 1.0],
        ),
      ),
    ),
  );
}

/// Clips the child to everything *outside* an expanding circle,
/// effectively "eating away" the preloader from the center.
class _InverseCircleClip extends StatelessWidget {
  const _InverseCircleClip({
    required this.progress,
    required this.child,
  });

  final double progress;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (progress <= 0) return child;
    if (progress >= 1) return const SizedBox.shrink();

    return ClipPath(
      clipper: _InverseCircleClipper(progress),
      child: child,
    );
  }
}

class _InverseCircleClipper extends CustomClipper<Path> {
  _InverseCircleClipper(this.progress);
  final double progress;

  @override
  Path getClip(Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = math.sqrt(
      (size.width / 2) * (size.width / 2) +
          (size.height / 2) * (size.height / 2),
    );
    final radius = maxRadius * progress;

    // Full rect minus the expanding circle
    final outer = Path()..addRect(Offset.zero & size);
    final hole = Path()
      ..addOval(Rect.fromCircle(center: center, radius: radius));

    return Path.combine(PathOperation.difference, outer, hole);
  }

  @override
  bool shouldReclip(_InverseCircleClipper old) => progress != old.progress;
}
