import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_web_portfolio/app/core/constants/app_colors.dart';
import 'package:flutter_web_portfolio/app/core/constants/cinematic_curves.dart';
import 'package:flutter_web_portfolio/app/core/constants/durations.dart';
import 'package:flutter_web_portfolio/app/widgets/cinematic_focusable.dart';

/// A premium, shaped CTA button with gradients and hover effects.
class PremiumCTAButton extends StatefulWidget {
  const PremiumCTAButton({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
    this.isPrimary = false,
    this.width,
  });

  final String label;
  final VoidCallback onTap;
  final IconData? icon;
  final bool isPrimary;
  final double? width;

  @override
  State<PremiumCTAButton> createState() => _PremiumCTAButtonState();
}

class _PremiumCTAButtonState extends State<PremiumCTAButton> {
  bool _hovered = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: widget.label,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        behavior: HitTestBehavior.translucent,
        child: AnimatedScale(
          scale: _pressed ? 0.96 : (_hovered ? 1.04 : 1.0),
          duration: AppDurations.microFast,
          curve: CinematicCurves.hoverLift,
          child: CinematicFocusable(
            onTap: widget.onTap,
            onHoverChanged: (h) => setState(() => _hovered = h),
            child: Container(
              width: widget.width,
              height: 54,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(27), // Pill shape
                boxShadow: _hovered && widget.isPrimary
                    ? [
                        BoxShadow(
                          color: AppColors.accent.withValues(alpha: 0.3),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ]
                    : [],
              ),
              child: AnimatedContainer(
                duration: AppDurations.buttonHover,
                curve: CinematicCurves.hoverLift,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(27),
                  gradient: widget.isPrimary
                      ? LinearGradient(
                          colors: [
                            AppColors.heroAccent,
                            AppColors.heroAccent.withValues(alpha: 0.8),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: !widget.isPrimary
                      ? (_hovered
                          ? Colors.white.withValues(alpha: 0.1)
                          : Colors.white.withValues(alpha: 0.05))
                      : null,
                  border: Border.all(
                    color: widget.isPrimary
                        ? Colors.white.withValues(alpha: 0.2)
                        : (_hovered
                            ? Colors.white.withValues(alpha: 0.4)
                            : Colors.white.withValues(alpha: 0.1)),
                    width: 1.5,
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.label,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: widget.isPrimary ? Colors.white : Colors.white,
                        letterSpacing: 1.2,
                      ),
                    ),
                    if (widget.icon != null) ...[
                      const SizedBox(width: 10),
                      AnimatedContainer(
                        duration: AppDurations.fast,
                        curve: CinematicCurves.hoverLift,
                        transform: Matrix4.translationValues(
                          _hovered ? 4 : 0,
                          0,
                          0,
                        ),
                        child: Icon(
                          widget.icon,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
