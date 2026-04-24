import 'package:flutter/material.dart';

/// Centralized color palette for the cinematic portfolio theme.
final class AppColors {
  const AppColors._();

  // ─── Base (dark) ────────────────────────────────────────────────────
  static const background = Color(0xFF050505);
  static const backgroundDark = Color(0xFF020202);
  static const backgroundLight = Color(0xFF0D0D0D);
  static const backgroundHover = Color(0xFF141414);

  // ─── Text hierarchy (dark) ──────────────────────────────────────────
  static const textBright = Color(0xFFF8FAFC);
  static const textPrimary = Color(0xFFCBD5E1);
  static const textSecondary = Color(0xFF64748B);
  static const white = Color(0xFFFFFFFF);

  // ─── Scene: Hero — Professional Navy ────────────────────────────────
  static const heroGradient1 = Color(0xFF020617);
  static const heroGradient2 = Color(0xFF0F172A);
  static const heroGradient3 = Color(0xFF1E293B);
  static const heroAccent = Color(0xFF0EA5E9);

  // ─── Scene: About — Professional Slate ──────────────────────────────
  static const aboutGradient1 = Color(0xFF0F172A);
  static const aboutGradient2 = Color(0xFF1E293B);
  static const aboutGradient3 = Color(0xFF334155);
  static const aboutAccent = Color(0xFF38BDF8);

  // ─── Scene: Experience — Emerald Slate ──────────────────────────────
  static const expGradient1 = Color(0xFF020617);
  static const expGradient2 = Color(0xFF064E3B);
  static const expGradient3 = Color(0xFF022C22);
  static const expAccent = Color(0xFF10B981);

  // ─── Scene: Projects — Crimson Slate ────────────────────────────────
  static const projGradient1 = Color(0xFF020617);
  static const projGradient2 = Color(0xFF450620);
  static const projGradient3 = Color(0xFF881337);
  static const projAccent = Color(0xFFF43F5E);

  // ─── Scene: Contact — Pure Executive ────────────────────────────────
  static const contactGradient1 = Color(0xFF020617);
  static const contactGradient2 = Color(0xFF0A0A0A);
  static const contactGradient3 = Color(0xFF171717);
  static const contactAccent = Color(0xFFF1F5F9);

  // ─── Semantic aliases ──────────────────────────────────────────────
  static const accent = heroAccent;
  static const accentMuted = Color(0x1A06B6D4);
  static const primary = accent;
  static const surface = backgroundLight;
  static const surfaceVariant = backgroundLight;
}
