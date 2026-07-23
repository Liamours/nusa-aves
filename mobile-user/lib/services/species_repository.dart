import 'package:csv/csv.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'database_service.dart';

/// Display metadata for one species, joined from the two bundled CSVs.
/// The classifier only gives a scientific name + confidence — this is what
/// turns that into something the UI (category pills, overview card, endemic
/// badge) can actually show.
class SpeciesInfo {
  final String commonName;
  final String overview;
  final String imageUrl;
  final bool isEndemic;
  final String endangeredStatus;

  const SpeciesInfo({
    required this.commonName,
    required this.overview,
    required this.imageUrl,
    required this.isEndemic,
    required this.endangeredStatus,
  });
}

/// One row of the `species` SQLite table — the raw, un-transformed data
/// (unlike [SpeciesInfo], which is already resolved for display:
/// Indonesian name preferred, endemic flags collapsed to one bool, status
/// mapped to Indonesian labels). Used by catalog/stats queries that need
/// the real IUCN category or per-country endemic flags separately, and
/// can't be answered by lookup()'s in-memory Map alone — see
/// mobile-user/DATABASE.md.
class SpeciesRecord {
  final String scientificName;
  final String commonEnglish;
  final String commonIndonesian;
  final String description;
  final String imageUrl;
  final String endangermentCategory;
  final bool isEndemicMalaysia;
  final bool isEndemicIndonesia;
  final String sourceUrl1;
  final String sourceUrl2;

  const SpeciesRecord({
    required this.scientificName,
    required this.commonEnglish,
    required this.commonIndonesian,
    required this.description,
    required this.imageUrl,
    required this.endangermentCategory,
    required this.isEndemicMalaysia,
    required this.isEndemicIndonesia,
    required this.sourceUrl1,
    required this.sourceUrl2,
  });

  Map<String, Object?> toMap() => {
        'scientific_name': scientificName,
        'common_english': commonEnglish,
        'common_indonesian': commonIndonesian,
        'description': description,
        'image_url': imageUrl,
        'endangerment_category': endangermentCategory,
        'is_endemic_malaysia': isEndemicMalaysia ? 1 : 0,
        'is_endemic_indonesia': isEndemicIndonesia ? 1 : 0,
        'source_url_1': sourceUrl1,
        'source_url_2': sourceUrl2,
      };

  factory SpeciesRecord.fromMap(Map<String, Object?> map) => SpeciesRecord(
        scientificName: map['scientific_name'] as String,
        commonEnglish: map['common_english'] as String? ?? '',
        commonIndonesian: map['common_indonesian'] as String? ?? '',
        description: map['description'] as String? ?? '',
        imageUrl: map['image_url'] as String? ?? '',
        endangermentCategory: map['endangerment_category'] as String,
        isEndemicMalaysia: (map['is_endemic_malaysia'] as int) == 1,
        isEndemicIndonesia: (map['is_endemic_indonesia'] as int) == 1,
        sourceUrl1: map['source_url_1'] as String? ?? '',
        sourceUrl2: map['source_url_2'] as String? ?? '',
      );
}

/// Loads and joins `species-descriptions.csv` (overview/image/common names)
/// and `species-list-219.csv` (endemic + endangerment status) by scientific
/// name. Only the 219 target species have entries in either file — BirdNET's
/// ~6,500 other global labels fall back to a generic [SpeciesInfo].
class SpeciesRepository {
  SpeciesRepository._();
  static final SpeciesRepository instance = SpeciesRepository._();

  Map<String, SpeciesInfo>? _bySpeciesKey;

  Future<void> ensureLoaded() async {
    if (_bySpeciesKey != null) return;

    final descriptionRows = await _loadCsv('assets/species/species-descriptions.csv');
    final listRows = await _loadCsv('assets/species/species-list-219.csv');

    final descriptions = _indexByColumn(descriptionRows, 'scientific_name');
    final endangerment = _indexByColumn(listRows, 'scientific_name');

    final keys = {...descriptions.keys, ...endangerment.keys};
    final map = <String, SpeciesInfo>{};
    final records = <SpeciesRecord>[];
    for (final key in keys) {
      final desc = descriptions[key];
      final list = endangerment[key];

      final commonName = (desc?['common_indonesian'] ?? '').trim().isNotEmpty
          ? desc!['common_indonesian']!
          : (desc?['common_english'] ?? list?['common_name'] ?? key);

      map[key] = SpeciesInfo(
        commonName: commonName,
        overview: (desc?['description'] ?? '').trim().isNotEmpty
            ? desc!['description']!
            : 'Belum ada deskripsi lokal untuk spesies ini.',
        imageUrl: desc?['image_url'] ?? '',
        isEndemic: _isYes(list?['endemic_malaysia']) || _isYes(list?['endemic_indonesia']),
        endangeredStatus: _mapEndangermentStatus(list?['endangerment_category']),
      );

      records.add(SpeciesRecord(
        scientificName: desc?['scientific_name'] ?? list?['scientific_name'] ?? key,
        commonEnglish: desc?['common_english'] ?? '',
        commonIndonesian: desc?['common_indonesian'] ?? '',
        description: desc?['description'] ?? '',
        imageUrl: desc?['image_url'] ?? '',
        endangermentCategory: list?['endangerment_category'] ?? 'Not Evaluated',
        isEndemicMalaysia: _isYes(list?['endemic_malaysia']),
        isEndemicIndonesia: _isYes(list?['endemic_indonesia']),
        sourceUrl1: desc?['source_url_1'] ?? '',
        sourceUrl2: desc?['source_url_2'] ?? '',
      ));
    }
    _bySpeciesKey = map;

    // Seed the queryable SQLite table once. lookup() above never touches
    // this — it stays synchronous, reading only the in-memory map, so
    // existing callers (BirdClassifier etc.) are unaffected.
    if (await DatabaseService.instance.getSpeciesCount() == 0) {
      await DatabaseService.instance.seedSpecies(records.map((r) => r.toMap()).toList());
    }
  }

  /// All 219 species, for a catalog/browse screen. Independent of anything
  /// the user has recorded.
  Future<List<SpeciesRecord>> getAllSpecies() async {
    final rows = await DatabaseService.instance.getAllSpecies();
    return rows.map(SpeciesRecord.fromMap).toList();
  }

  /// Species filtered by real IUCN category — 'Least Concern', 'Vulnerable',
  /// 'Endangered', 'Critically Endangered', or 'not in reference data'.
  Future<List<SpeciesRecord>> getSpeciesByStatus(String endangermentCategory) async {
    final rows = await DatabaseService.instance.getSpeciesByStatus(endangermentCategory);
    return rows.map(SpeciesRecord.fromMap).toList();
  }

  /// [birdnetLabel] is in BirdNET's `"Scientific name_Common Name"` format,
  /// as it appears in CustomClassifier_Labels.txt.
  SpeciesInfo lookup(String birdnetLabel) {
    final map = _bySpeciesKey;
    assert(map != null, 'call ensureLoaded() before lookup()');

    final parts = birdnetLabel.split('_');
    final scientificName = parts.first;
    final labelCommonName = parts.length > 1 ? parts.skip(1).join('_') : birdnetLabel;

    final info = map?[scientificName.toLowerCase()];
    if (info != null) return info;

    return SpeciesInfo(
      commonName: labelCommonName,
      overview: 'Spesies ini belum ada dalam basis data 219 target spesies lokal.',
      imageUrl: '',
      isEndemic: false,
      endangeredStatus: 'Risiko Rendah',
    );
  }

  String _mapEndangermentStatus(String? raw) {
    switch (raw) {
      case 'Critically Endangered':
        return 'Kritis';
      case 'Endangered':
        return 'Genting';
      case 'Vulnerable':
        return 'Rentan';
      default:
        // Covers 'Least Concern' and 'not in reference data' (unmatched
        // species) alike — the app's status enum has no "unknown" tier,
        // so both fall back to the lowest-risk label.
        return 'Risiko Rendah';
    }
  }

  bool _isYes(String? raw) => raw?.trim().toLowerCase() == 'yes';

  Future<List<List<dynamic>>> _loadCsv(String assetPath) async {
    final raw = await rootBundle.loadString(assetPath);
    return csv.decode(raw);
  }

  /// Turns CSV rows into `scientific_name (lowercased) -> {column: value}`,
  /// looking up columns by header name so this doesn't break if a column
  /// gets reordered upstream.
  Map<String, Map<String, String>> _indexByColumn(
    List<List<dynamic>> rows,
    String keyColumn,
  ) {
    if (rows.isEmpty) return {};
    final header = rows.first.map((c) => c.toString()).toList();
    final keyIndex = header.indexOf(keyColumn);
    if (keyIndex == -1) return {};

    final result = <String, Map<String, String>>{};
    for (final row in rows.skip(1)) {
      if (row.length <= keyIndex) continue;
      final key = row[keyIndex].toString().trim().toLowerCase();
      if (key.isEmpty) continue;
      final rowMap = <String, String>{};
      for (var i = 0; i < header.length && i < row.length; i++) {
        rowMap[header[i]] = row[i].toString();
      }
      result[key] = rowMap;
    }
    return result;
  }
}
