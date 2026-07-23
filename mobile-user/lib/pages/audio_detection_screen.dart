import 'dart:async';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import '../models/bird_sighting.dart';
import '../services/bird_classifier.dart';
import '../services/database_service.dart';

enum _RecordingState { idle, recording, processing }

class AudioDetectionScreen extends StatefulWidget {
  final Function(BirdSighting)? onSightingDetected;

  const AudioDetectionScreen({super.key, this.onSightingDetected});

  @override
  State<AudioDetectionScreen> createState() => _AudioDetectionScreenState();
}

class _AudioDetectionScreenState extends State<AudioDetectionScreen>
    with SingleTickerProviderStateMixin {
  static const int _maxSeconds = 30;

  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  final AudioRecorder _recorder = AudioRecorder();
  _RecordingState _state = _RecordingState.idle;
  int _elapsedSeconds = 0;
  Timer? _timer;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _timer?.cancel();
    _recorder.dispose();
    super.dispose();
  }

  Future<void> _handleMicTap() async {
    if (_state == _RecordingState.recording) {
      await _stopRecording();
    } else if (_state == _RecordingState.idle) {
      await _startRecording();
    }
  }

  Future<void> _startRecording() async {
    setState(() => _errorMessage = null);

    final hasPermission = await _recorder.hasPermission();
    if (!hasPermission) {
      setState(() {
        _errorMessage =
            'Izin mikrofon diperlukan untuk merekam suara burung.';
      });
      return;
    }

    final dir = await getApplicationDocumentsDirectory();
    final path = '${dir.path}/rec_${DateTime.now().millisecondsSinceEpoch}.wav';

    // WAV/PCM16 mono at the model's native rate, so the classifier can read
    // samples straight off disk with no decode step (see BirdClassifier.preprocess).
    await _recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.wav,
        sampleRate: BirdClassifier.sampleRate,
        numChannels: 1,
      ),
      path: path,
    );
    if (!mounted) return;

    setState(() {
      _state = _RecordingState.recording;
      _elapsedSeconds = 0;
    });
    _pulseController.repeat(reverse: true);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() => _elapsedSeconds++);
      if (_elapsedSeconds >= _maxSeconds) {
        _stopRecording();
      }
    });
  }

  Future<void> _stopRecording() async {
    _timer?.cancel();
    _pulseController
      ..stop()
      ..value = 1.0;

    final path = await _recorder.stop();
    final recordedSeconds = _elapsedSeconds;
    if (!mounted) return;

    setState(() => _state = _RecordingState.processing);

    if (path == null) {
      setState(() {
        _state = _RecordingState.idle;
        _elapsedSeconds = 0;
        _errorMessage = 'Rekaman gagal disimpan, coba lagi.';
      });
      return;
    }

    try {
      final results = await BirdClassifier.instance.classifyFile(path, topK: 1);
      if (!mounted) return;

      final top = results.first;
      final accuracyValue = (top.confidence * 100).round().clamp(0, 100);
      final duration = _formatTimer(recordedSeconds);

      final sighting = BirdSighting(
        id: 'rec-${DateTime.now().millisecondsSinceEpoch}',
        name: top.species.commonName,
        scientificName: top.scientificName,
        imageUrl: top.species.imageUrl,
        accuracy: '$accuracyValue%',
        accuracyValue: accuracyValue,
        recordedAt: DateTime.now(),
        // Lokasi, suhu, dan cuaca butuh integrasi GPS/API cuaca terpisah —
        // di luar cakupan backend model + database ini.
        location: 'Lokasi tidak tersedia',
        audioDuration: '$duration / ${_formatTimer(_maxSeconds)}',
        isAudioOnly: true,
        category: 'Burung',
        overview: top.species.overview,
        isEndemic: top.species.isEndemic,
        endangeredStatus: top.species.endangeredStatus,
        temperature: '-',
        weatherCondition: '-',
        audioFilePath: path,
      );

      await DatabaseService.instance.insertSighting(sighting);
      if (!mounted) return;

      setState(() {
        _state = _RecordingState.idle;
        _elapsedSeconds = 0;
      });

      widget.onSightingDetected?.call(sighting);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _state = _RecordingState.idle;
        _elapsedSeconds = 0;
        _errorMessage = 'Gagal menganalisis rekaman: $e';
      });
    }
  }

  String _formatTimer(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  String get _title {
    switch (_state) {
      case _RecordingState.recording:
        return 'Mendengarkan...';
      case _RecordingState.processing:
        return 'Menganalisis rekaman...';
      case _RecordingState.idle:
        return 'Ketuk untuk Merekam';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar Header
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: Row(
                children: const [
                  Text(
                    'birdApp',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1A202C),
                      letterSpacing: -0.8,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    // Title & Timer
                    Text(
                      _title,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1A202C),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    if (_state != _RecordingState.processing)
                      Text(
                        '${_formatTimer(_elapsedSeconds)} / ${_formatTimer(_maxSeconds)}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF718096),
                        ),
                      ),
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        _errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFE53E3E),
                        ),
                      ),
                    ],
                    const SizedBox(height: 48),

                    // Pulsing Mic Circle Button
                    ScaleTransition(
                      scale: _pulseAnimation,
                      child: GestureDetector(
                        onTap: _handleMicTap,
                        child: Container(
                          width: 170,
                          height: 170,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFE8F8D8),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFC3ED99)
                                    .withValues(alpha: 0.4),
                                blurRadius: 30,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                border: Border.all(
                                  color: const Color(0xFFE8F8D8),
                                  width: 4,
                                ),
                              ),
                              child: Center(
                                child: Container(
                                  width: 96,
                                  height: 96,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xFFFFB84D),
                                  ),
                                  child: _state == _RecordingState.processing
                                      ? const Padding(
                                          padding: EdgeInsets.all(28.0),
                                          child: CircularProgressIndicator(
                                            color: Color(0xFFB36B00),
                                            strokeWidth: 3,
                                          ),
                                        )
                                      : Icon(
                                          _state == _RecordingState.recording
                                              ? Icons.stop_rounded
                                              : Icons.mic_rounded,
                                          color: const Color(0xFFB36B00),
                                          size: 44,
                                        ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      _state == _RecordingState.recording
                          ? 'Ketuk lagi untuk berhenti merekam'
                          : _state == _RecordingState.processing
                              ? ''
                              : 'Rekam suara burung secara langsung dari mikrofon',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF718096),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Better Detection Tip Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFFE2E8F0),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0F7ED),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.lightbulb_outlined,
                              color: Color(0xFF388E3C),
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'Tips Deteksi Lebih Baik',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF1A202C),
                                  ),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  'Pegang perangkat dengan stabil dan arahkan mikrofon ke sumber suara agar rekaman lebih jernih.',
                                  style: TextStyle(
                                    fontSize: 13,
                                    height: 1.45,
                                    color: Color(0xFF718096),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
