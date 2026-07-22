import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import '../models/bird_sighting.dart';
import '../utils/indo_date.dart';
import '../widgets/audio_waveform.dart';

class HistoryDetailScreen extends StatefulWidget {
  final BirdSighting sighting;

  const HistoryDetailScreen({
    super.key,
    required this.sighting,
  });

  @override
  State<HistoryDetailScreen> createState() => _HistoryDetailScreenState();
}

class _HistoryDetailScreenState extends State<HistoryDetailScreen> {
  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;

  BirdSighting get sighting => widget.sighting;

  @override
  void initState() {
    super.initState();
    _player.onPlayerComplete.listen((_) {
      if (mounted) setState(() => _isPlaying = false);
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _togglePlayback() async {
    final path = sighting.audioFilePath;
    if (path == null) return;

    if (_isPlaying) {
      await _player.pause();
      setState(() => _isPlaying = false);
    } else {
      await _player.play(DeviceFileSource(path));
      setState(() => _isPlaying = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFC),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Full Bleed Top Hero Image with Floating Circular Back Button
            Stack(
              children: [
                SizedBox(
                  height: 320,
                  width: double.infinity,
                  child: Image.network(
                    sighting.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: const Color(0xFFE2E8F0),
                      child: const Icon(Icons.pets, size: 64),
                    ),
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16, top: 8),
                    child: CircleAvatar(
                      backgroundColor: Colors.white.withValues(alpha: 0.85),
                      radius: 22,
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_back_rounded,
                          color: Color(0xFF1A202C),
                          size: 22,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Content Body Container
            Transform.translate(
              offset: const Offset(0, -20),
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFF7FAFC),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 24.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title & Accuracy Badge Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                sighting.name,
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF1A202C),
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                sighting.scientificName,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontStyle: FontStyle.italic,
                                  color: Color(0xFF718096),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.check_circle_rounded,
                                size: 14,
                                color: Color(0xFF2E7D32),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${sighting.accuracy} Cocok',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF2E7D32),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Audio Player Card
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
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
                          GestureDetector(
                            onTap: sighting.audioFilePath == null
                                ? null
                                : _togglePlayback,
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: sighting.audioFilePath == null
                                    ? const Color(0xFFA0AEC0)
                                    : const Color(0xFF193322),
                              ),
                              child: Icon(
                                _isPlaying
                                    ? Icons.pause_rounded
                                    : Icons.play_arrow_rounded,
                                color: Colors.white,
                                size: 26,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      sighting.audioDuration.split(' / ').first,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF1A202C),
                                      ),
                                    ),
                                    Text(
                                      sighting.audioDuration.split(' / ').last,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF718096),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                const AudioWaveform(
                                  heights: [
                                    8,
                                    18,
                                    12,
                                    26,
                                    14,
                                    20,
                                    10,
                                    24,
                                    16,
                                    28,
                                    12,
                                    20,
                                    8,
                                    14
                                  ],
                                  activeColor: Color(0xFFD98E32),
                                  inactiveColor: Color(0xFFE2E8F0),
                                  activeIndex: 6,
                                  barWidth: 3.5,
                                  spacing: 2.5,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Description Section
                    const Text(
                      'Deskripsi',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1A202C),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      sighting.overview,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.55,
                        color: Color(0xFF4A5568),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Endemik & Status Konservasi
                    Row(
                      children: [
                        Expanded(
                          child: _buildDetailCard(
                            icon: Icons.public_rounded,
                            label: 'ENDEMIK',
                            value: sighting.isEndemic ? 'Ya' : 'Tidak',
                            subValue: '',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildDetailCard(
                            icon: Icons.warning_amber_rounded,
                            label: 'STATUS KONSERVASI',
                            value: sighting.endangeredStatus,
                            subValue: '',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Detection Details Section
                    const Text(
                      'Detail Deteksi',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1A202C),
                      ),
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: _buildDetailCard(
                            icon: Icons.calendar_today_outlined,
                            label: 'DIREKAM PADA',
                            value: formatIndonesianDate(sighting.recordedAt),
                            subValue: formatIndonesianTime(sighting.recordedAt),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildDetailCard(
                            icon: Icons.thermostat_outlined,
                            label: 'KONDISI',
                            value: sighting.temperature,
                            subValue: sighting.weatherCondition,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),

                    // Action Buttons: Share & Delete
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {},
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side: const BorderSide(
                                color: Color(0xFFCBD5E0),
                                width: 1.2,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(26),
                              ),
                              backgroundColor: Colors.white,
                            ),
                            icon: const Icon(
                              Icons.share_outlined,
                              color: Color(0xFF1A202C),
                              size: 18,
                            ),
                            label: const Text(
                              'Bagikan',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1A202C),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              backgroundColor: const Color(0xFFFFEAEA),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(26),
                              ),
                            ),
                            icon: const Icon(
                              Icons.delete_outline_rounded,
                              color: Color(0xFFE53E3E),
                              size: 18,
                            ),
                            label: const Text(
                              'Hapus',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFE53E3E),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard({
    required IconData icon,
    required String label,
    required String value,
    required String subValue,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
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
              Icon(icon, color: const Color(0xFF718096), size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF718096),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1A202C),
            ),
          ),
          if (subValue.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              subValue,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF718096),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
