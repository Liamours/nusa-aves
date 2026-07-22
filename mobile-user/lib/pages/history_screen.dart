import 'package:flutter/material.dart';

import '../models/bird_sighting.dart';
import '../utils/indo_date.dart';
import '../utils/match_tier.dart';
import '../widgets/audio_waveform.dart';

class HistoryScreen extends StatefulWidget {
  final List<BirdSighting> sightings;
  final Function(BirdSighting)? onSelectSighting;

  const HistoryScreen({
    super.key,
    required this.sightings,
    this.onSelectSighting,
  });

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final Set<String> _selectedStatuses = {};
  bool _endemicOnly = false;

  bool get _hasActiveFilter => _selectedStatuses.isNotEmpty || _endemicOnly;

  bool _matchesFilter(BirdSighting sighting) {
    if (_selectedStatuses.isNotEmpty &&
        !_selectedStatuses.contains(sighting.endangeredStatus)) {
      return false;
    }
    if (_endemicOnly && !sighting.isEndemic) return false;
    return true;
  }

  Map<String, List<BirdSighting>> _groupByDay(List<BirdSighting> list) {
    final sorted = List<BirdSighting>.of(list)
      ..sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
    final Map<String, List<BirdSighting>> groups = {};
    for (final sighting in sorted) {
      final key = formatRelativeDay(sighting.recordedAt);
      groups.putIfAbsent(key, () => []).add(sighting);
    }
    return groups;
  }

  void _openFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Filter Riwayat',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1A202C),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setSheetState(() {
                            _selectedStatuses.clear();
                            _endemicOnly = false;
                          });
                          setState(() {});
                        },
                        child: const Text('Reset'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'STATUS TERANCAM PUNAH',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF718096),
                    ),
                  ),
                  ...endangeredStatuses.map((status) {
                    final isSelected = _selectedStatuses.contains(status);
                    return CheckboxListTile(
                      value: isSelected,
                      onChanged: (checked) {
                        setSheetState(() {
                          if (checked == true) {
                            _selectedStatuses.add(status);
                          } else {
                            _selectedStatuses.remove(status);
                          }
                        });
                        setState(() {});
                      },
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                      activeColor: const Color(0xFF2E7D32),
                      title: Text(
                        status,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A202C),
                        ),
                      ),
                    );
                  }),
                  const Divider(height: 24),
                  CheckboxListTile(
                    value: _endemicOnly,
                    onChanged: (checked) {
                      setSheetState(() => _endemicOnly = checked ?? false);
                      setState(() {});
                    },
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    activeColor: const Color(0xFF2E7D32),
                    title: const Text(
                      'Hanya spesies endemik',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A202C),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF193322),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Terapkan',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = widget.sightings.where(_matchesFilter).toList();
    final groups = _groupByDay(filtered);

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar Header
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
              child: Center(
                child: Text(
                  'birdApp',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1A202C),
                    letterSpacing: -0.8,
                  ),
                ),
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),

                    // Search Bar with Filter Icon
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFFE2E8F0),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Cari riwayat Anda...',
                          hintStyle: const TextStyle(
                            color: Color(0xFFA0AEC0),
                            fontSize: 15,
                          ),
                          prefixIcon: const Icon(
                            Icons.search_rounded,
                            color: Color(0xFF718096),
                            size: 22,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              Icons.tune_rounded,
                              color: _hasActiveFilter
                                  ? const Color(0xFF2E7D32)
                                  : const Color(0xFF718096),
                              size: 20,
                            ),
                            onPressed: _openFilterSheet,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    if (groups.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 60),
                        child: Center(
                          child: Text(
                            'Belum ada riwayat yang cocok dengan filter ini.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF718096),
                            ),
                          ),
                        ),
                      ),

                    for (final entry in groups.entries) ...[
                      Text(
                        entry.key,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1A202C),
                        ),
                      ),
                      const SizedBox(height: 14),
                      for (final sighting in entry.value) ...[
                        _buildHistoryCard(sighting: sighting),
                        const SizedBox(height: 14),
                      ],
                      const SizedBox(height: 14),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryCard({required BirdSighting sighting}) {
    final tier = MatchTier.of(sighting.accuracyValue);
    final isLowConf = sighting.accuracyValue < 60;

    return GestureDetector(
      onTap: () {
        if (widget.onSelectSighting != null) {
          widget.onSelectSighting!(sighting);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(14),
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
              child: sighting.isAudioOnly
                  ? Container(
                      width: 76,
                      height: 76,
                      color: const Color(0xFF1B3B2B),
                      child: const Center(
                        child: AudioWaveform(
                          heights: [8, 18, 12, 24, 14, 20, 10],
                          barWidth: 3,
                          spacing: 2.5,
                        ),
                      ),
                    )
                  : Image.network(
                      sighting.imageUrl,
                      width: 76,
                      height: 76,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 76,
                          height: 76,
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
                      Icon(
                        sighting.isAudioOnly
                            ? Icons.mic_rounded
                            : Icons.more_vert_rounded,
                        color: sighting.isAudioOnly
                            ? const Color(0xFFFFB84D)
                            : const Color(0xFFA0AEC0),
                        size: 20,
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    sighting.scientificName,
                    style: const TextStyle(
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                      color: Color(0xFF718096),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Icon(
                              sighting.isAudioOnly
                                  ? Icons.access_time_rounded
                                  : Icons.location_on_outlined,
                              size: 14,
                              color: const Color(0xFF718096),
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                sighting.isAudioOnly
                                    ? formatIndonesianTime(sighting.recordedAt)
                                    : sighting.location,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF718096),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: isLowConf
                              ? const Color(0xFFEDF2F7)
                              : tier.backgroundColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            if (!isLowConf) ...[
                              const Text('🌱 ', style: TextStyle(fontSize: 10)),
                            ],
                            Text(
                              isLowConf
                                  ? '? Keyakinan Rendah'
                                  : sighting.accuracy,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: isLowConf
                                    ? const Color(0xFF4A5568)
                                    : tier.color,
                              ),
                            ),
                          ],
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
