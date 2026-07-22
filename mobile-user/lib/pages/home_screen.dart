import 'package:flutter/material.dart';

import '../models/bird_sighting.dart';
import '../utils/indo_date.dart';
import '../utils/match_tier.dart';

class HomeScreen extends StatelessWidget {
  final List<BirdSighting> sightings;
  final Function(BirdSighting)? onSelectSighting;
  final VoidCallback? onViewAll;

  const HomeScreen({
    super.key,
    required this.sightings,
    this.onSelectSighting,
    this.onViewAll,
  });

  String _frequentSpecies() {
    if (sightings.isEmpty) return '-';
    final counts = <String, int>{};
    for (final s in sightings) {
      counts[s.name] = (counts[s.name] ?? 0) + 1;
    }
    return counts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  }

  @override
  Widget build(BuildContext context) {
    final recent = List<BirdSighting>.of(sightings)
      ..sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
    final recentDiscoveries = recent.take(2).toList();
    final speciesCount = sightings.map((s) => s.name).toSet().length;

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              const Text(
                'Halo, Penjelajah!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A202C),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Siap untuk menjelajah?',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF718096),
                ),
              ),
              const SizedBox(height: 28),

              // Your Impact Section
              const Text(
                'Statistik Anda',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A202C),
                ),
              ),
              const SizedBox(height: 14),

              // Total Recordings Card (Full Width)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(
                          Icons.mic_none_rounded,
                          color: Color(0xFF2E7D32),
                          size: 18,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Total Rekaman',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${sightings.length}',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1A202C),
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Two Grid Cards: Species & Frequent
              Row(
                children: [
                  Expanded(
                    child: _buildImpactSubCard(
                      icon: Icons.menu_book_rounded,
                      title: 'Spesies',
                      value: '$speciesCount',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildImpactSubCard(
                      icon: Icons.swap_horiz_rounded,
                      title: 'Terbanyak',
                      value: _frequentSpecies(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Recent Discoveries Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Penemuan Terbaru',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A202C),
                    ),
                  ),
                  GestureDetector(
                    onTap: onViewAll,
                    child: const Text(
                      'Lihat Semua',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Recent Discoveries Items
              if (recentDiscoveries.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Text(
                    'Belum ada penemuan. Mulai rekam suara burung di tab Deteksi.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF718096),
                    ),
                  ),
                )
              else
                for (final sighting in recentDiscoveries) ...[
                  _buildDiscoveryCard(sighting: sighting),
                  const SizedBox(height: 12),
                ],
              const SizedBox(height: 4),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImpactSubCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: const Color(0xFF4A5568),
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF718096),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1A202C),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildDiscoveryCard({
    required BirdSighting sighting,
  }) {
    final tier = MatchTier.of(sighting.accuracyValue);

    return GestureDetector(
      onTap: () {
        if (onSelectSighting != null) {
          onSelectSighting!(sighting);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                sighting.imageUrl,
                width: 72,
                height: 72,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 72,
                    height: 72,
                    color: const Color(0xFFE2E8F0),
                    child: const Icon(
                      Icons.pets,
                      color: Color(0xFF718096),
                      size: 32,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          sighting.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A202C),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: tier.backgroundColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          sighting.accuracy,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: tier.color,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        size: 13,
                        color: Color(0xFF718096),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        formatRelativeDayTime(sighting.recordedAt),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF718096),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: Color(0xFF718096),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          sighting.location,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF718096),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
