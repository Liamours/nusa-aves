import 'package:flutter/material.dart';
import '../models/bird_sighting.dart';
import 'home_screen.dart';
import 'audio_detection_screen.dart';
import 'history_screen.dart';
import 'history_detail_screen.dart';
import 'detection_result_screen.dart';
import '../widgets/custom_navbar.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;
  late List<BirdSighting> _sightings;

  @override
  void initState() {
    super.initState();
    _sightings = List.of(sampleSightings);
  }

  void _addSighting(BirdSighting sighting) {
    setState(() => _sightings = [sighting, ..._sightings]);
  }

  void _navigateToHistoryDetail(BirdSighting sighting) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => HistoryDetailScreen(sighting: sighting),
      ),
    );
  }

  void _navigateToDetectionResult(BirdSighting sighting) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DetectionResultScreen(sighting: sighting),
      ),
    );
  }

  void _onSightingDetected(BirdSighting sighting) {
    _addSighting(sighting);
    _navigateToDetectionResult(sighting);
  }

  void _goToHistoryTab() {
    setState(() => _currentIndex = 2);
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      HomeScreen(
        sightings: _sightings,
        onSelectSighting: _navigateToDetectionResult,
        onViewAll: _goToHistoryTab,
      ),
      AudioDetectionScreen(
        onSightingDetected: _onSightingDetected,
      ),
      HistoryScreen(
        sightings: _sightings,
        onSelectSighting: _navigateToHistoryDetail,
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFC),
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: CustomNavbar(
        selectedIndex: _currentIndex,
        onItemTapped: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
