import 'package:flutter/material.dart';

/// Tier kecocokan deteksi berdasarkan `accuracyValue` (0-100).
class MatchTier {
  final String label;
  final Color color;
  final Color backgroundColor;

  const MatchTier._(this.label, this.color, this.backgroundColor);

  static MatchTier of(int accuracyValue) {
    if (accuracyValue >= 85) {
      return const MatchTier._(
        'Kecocokan Tinggi',
        Color(0xFF2E7D32),
        Color(0xFFE8F5E9),
      );
    }
    if (accuracyValue >= 60) {
      return const MatchTier._(
        'Kecocokan Sedang',
        Color(0xFFB36B00),
        Color(0xFFFFF3E0),
      );
    }
    return const MatchTier._(
      'Kecocokan Rendah',
      Color(0xFF718096),
      Color(0xFFEDF2F7),
    );
  }
}
