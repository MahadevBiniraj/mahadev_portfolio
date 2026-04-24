import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class KollywoodTitleReveal extends StatefulWidget {
  const KollywoodTitleReveal({
    super.key,
    required this.displayName,
    required this.tagline,
    required this.progress,
  });

  final String displayName;
  final String tagline;
  final double progress; // 0.0 to 1.0 driving the sequence

  @override
  State<KollywoodTitleReveal> createState() => _KollywoodTitleRevealState();
}

class _KollywoodTitleRevealState extends State<KollywoodTitleReveal>
    with SingleTickerProviderStateMixin {
  late AnimationController _glitchController;

  @override
  void initState() {
    super.initState();
    _glitchController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    )..repeat();
  }

  @override
  void dispose() {
    _glitchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Sequence timing
    // 0.0 - 0.7: Main Name Reveal
    // 0.6 - 1.0: Subtitle Fade
    final nameProgress = (widget.progress / 0.7).clamp(0.0, 1.0);
    final subtitleProgress = ((widget.progress - 0.6) / 0.4).clamp(0.0, 1.0);
    
    // Zoom effect: 1.0 to 1.15
    final zoom = 1.0 + (widget.progress * 0.15);

    return Container(
      color: Colors.black,
      child: Stack(
        children: [
          // Background Smoke/Dust
          Positioned.fill(
            child: _CinematicAtmosphere(progress: widget.progress),
          ),
          
          // Fire Embers
          Positioned.fill(
            child: _FireEmbers(progress: widget.progress),
          ),

          // Main Content
          Center(
            child: Transform.scale(
              scale: zoom,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Glitchy Metallic Title
                  _GlitchyMetallicText(
                    text: widget.displayName,
                    progress: nameProgress,
                    glitch: _glitchController,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Cinematic Subtitle
                  Opacity(
                    opacity: subtitleProgress,
                    child: Transform.translate(
                      offset: Offset(0, 10 * (1 - subtitleProgress)),
                      child: Text(
                        widget.tagline.toUpperCase(),
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w300,
                          letterSpacing: 8,
                          color: Colors.white.withValues(alpha: 0.7),
                          shadows: [
                            Shadow(
                              color: Colors.white.withValues(alpha: 0.3),
                              blurRadius: 10,
                            ),
                          ],
                        ),
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
}

class _GlitchyMetallicText extends StatelessWidget {
  const _GlitchyMetallicText({
    required this.text,
    required this.progress,
    required this.glitch,
  });

  final String text;
  final double progress;
  final Animation<double> glitch;

  @override
  Widget build(BuildContext context) {
    final goldGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        const Color(0xFFD4AF37), // Gold
        const Color(0xFFF9F295), // Light Gold
        const Color(0xFFD4AF37), // Gold
        const Color(0xFFB8860B), // Dark Gold
      ],
      stops: const [0.0, 0.4, 0.6, 1.0],
    );

    return AnimatedBuilder(
      animation: glitch,
      builder: (context, _) {
        final isGlitching = progress > 0.3 && math.Random().nextDouble() > 0.92;
        final offset = isGlitching 
            ? Offset((math.Random().nextDouble() - 0.5) * 4, 0)
            : Offset.zero;

        return Stack(
          children: [
            // Glowing background blur
            Opacity(
              opacity: progress * 0.5,
              child: ShaderMask(
                shaderCallback: (bounds) => goldGradient.createShader(bounds),
                child: Text(
                  text,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.syncopate(
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 12,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            
            // Chromatic aberration (Red layer)
            if (isGlitching)
              Transform.translate(
                offset: offset + const Offset(-2, 0),
                child: Opacity(
                  opacity: 0.5,
                  child: Text(
                    text,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.syncopate(
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 12,
                      color: Colors.red.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ),

            // Main Metallic Layer
            Opacity(
              opacity: progress,
              child: Transform.translate(
                offset: offset,
                child: ShaderMask(
                  blendMode: BlendMode.srcIn,
                  shaderCallback: (bounds) => goldGradient.createShader(bounds),
                  child: Text(
                    text,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.syncopate(
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 12,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _FireEmbers extends StatefulWidget {
  const _FireEmbers({required this.progress});
  final double progress;

  @override
  State<_FireEmbers> createState() => _FireEmbersState();
}

class _FireEmbersState extends State<_FireEmbers> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  final List<_Ember> _embers = [];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
    for (int i = 0; i < 30; i++) {
      _embers.add(_Ember());
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        for (var e in _embers) {
          e.update();
        }
        return CustomPaint(
          painter: _EmberPainter(embers: _embers, opacity: widget.progress),
        );
      },
    );
  }
}

class _Ember {
  double x = math.Random().nextDouble();
  double y = math.Random().nextDouble();
  double size = math.Random().nextDouble() * 2 + 1;
  double vx = (math.Random().nextDouble() - 0.5) * 0.002;
  double vy = -math.Random().nextDouble() * 0.005 - 0.002;
  double life = math.Random().nextDouble();

  void update() {
    x += vx;
    y += vy;
    life -= 0.01;
    if (life <= 0 || y < 0) {
      x = math.Random().nextDouble();
      y = 1.1;
      life = 1.0;
    }
  }
}

class _EmberPainter extends CustomPainter {
  _EmberPainter({required this.embers, required this.opacity});
  final List<_Ember> embers;
  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (var e in embers) {
      final alpha = (e.life * opacity * 0.8).clamp(0.0, 1.0);
      paint.color = Colors.orangeAccent.withValues(alpha: alpha);
      canvas.drawCircle(Offset(e.x * size.width, e.y * size.height), e.size, paint);
      
      // Glow
      paint.color = Colors.redAccent.withValues(alpha: alpha * 0.3);
      paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawCircle(Offset(e.x * size.width, e.y * size.height), e.size * 3, paint);
      paint.maskFilter = null;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _CinematicAtmosphere extends StatelessWidget {
  const _CinematicAtmosphere({required this.progress});
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Dark smoke layers
        Positioned.fill(
          child: Opacity(
            opacity: progress * 0.4,
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.5,
                  colors: [
                    Colors.white.withValues(alpha: 0.05),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ),
        // Vignette
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.8),
                ],
                stops: const [0.5, 1.0],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
