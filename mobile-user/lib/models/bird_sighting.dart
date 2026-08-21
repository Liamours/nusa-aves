/// Daftar status konservasi (skala IUCN, label Bahasa Indonesia) yang bisa
/// dipilih di filter History.
const List<String> endangeredStatuses = [
  'Punah',
  'Kritis',
  'Genting',
  'Rentan',
  'Hampir Terancam',
  'Risiko Rendah',
];

class BirdSighting {
  final String id;
  final String name;
  final String scientificName;
  final String imageUrl;
  final String accuracy;
  final int accuracyValue;
  final DateTime recordedAt;
  final String location;
  final String audioDuration;
  final bool isAudioOnly;
  final String category;
  final String overview;
  final bool isEndemic;
  final String endangeredStatus;
  final String temperature;
  final String weatherCondition;

  /// Path file rekaman audio asli di perangkat (hasil rekam mic).
  /// `null` untuk data contoh bawaan yang tidak punya rekaman asli.
  final String? audioFilePath;

  const BirdSighting({
    required this.id,
    required this.name,
    required this.scientificName,
    required this.imageUrl,
    required this.accuracy,
    required this.accuracyValue,
    required this.recordedAt,
    required this.location,
    required this.audioDuration,
    this.isAudioOnly = false,
    required this.category,
    required this.overview,
    required this.isEndemic,
    required this.endangeredStatus,
    required this.temperature,
    required this.weatherCondition,
    this.audioFilePath,
  });

  BirdSighting copyWith({
    String? id,
    DateTime? recordedAt,
    String? audioFilePath,
    bool? isAudioOnly,
  }) {
    return BirdSighting(
      id: id ?? this.id,
      name: name,
      scientificName: scientificName,
      imageUrl: imageUrl,
      accuracy: accuracy,
      accuracyValue: accuracyValue,
      recordedAt: recordedAt ?? this.recordedAt,
      location: location,
      audioDuration: audioDuration,
      isAudioOnly: isAudioOnly ?? this.isAudioOnly,
      category: category,
      overview: overview,
      isEndemic: isEndemic,
      endangeredStatus: endangeredStatus,
      temperature: temperature,
      weatherCondition: weatherCondition,
      audioFilePath: audioFilePath ?? this.audioFilePath,
    );
  }

  Map<String, Object?> toMap() => {
        'id': id,
        'name': name,
        'scientificName': scientificName,
        'imageUrl': imageUrl,
        'accuracy': accuracy,
        'accuracyValue': accuracyValue,
        'recordedAt': recordedAt.millisecondsSinceEpoch,
        'location': location,
        'audioDuration': audioDuration,
        'isAudioOnly': isAudioOnly ? 1 : 0,
        'category': category,
        'overview': overview,
        'isEndemic': isEndemic ? 1 : 0,
        'endangeredStatus': endangeredStatus,
        'temperature': temperature,
        'weatherCondition': weatherCondition,
        'audioFilePath': audioFilePath,
      };

  factory BirdSighting.fromMap(Map<String, Object?> map) => BirdSighting(
        id: map['id'] as String,
        name: map['name'] as String,
        scientificName: map['scientificName'] as String,
        imageUrl: map['imageUrl'] as String,
        accuracy: map['accuracy'] as String,
        accuracyValue: map['accuracyValue'] as int,
        recordedAt: DateTime.fromMillisecondsSinceEpoch(map['recordedAt'] as int),
        location: map['location'] as String,
        audioDuration: map['audioDuration'] as String,
        isAudioOnly: (map['isAudioOnly'] as int) == 1,
        category: map['category'] as String,
        overview: map['overview'] as String,
        isEndemic: (map['isEndemic'] as int) == 1,
        endangeredStatus: map['endangeredStatus'] as String,
        temperature: map['temperature'] as String,
        weatherCondition: map['weatherCondition'] as String,
        audioFilePath: map['audioFilePath'] as String?,
      );
}

final DateTime _now = DateTime.now();

/// Katalog spesies contoh (template), diambil dari 4 baris nyata di
/// assets/species/species-descriptions.csv (bukan data karangan) supaya
/// nama, foto, dan status konservasinya konsisten dengan basis data
/// 219 spesies yang dipakai SpeciesRepository. Karena app belum punya
/// model ML, setiap rekaman baru selalu "terdeteksi" sebagai
/// `speciesCatalog.first`.
final List<BirdSighting> speciesCatalog = [
  BirdSighting(
    id: 'sp-1',
    name: 'Enggang Cula',
    scientificName: 'Buceros rhinoceros',
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/thumb/6/6f/Buceros_rhinoceros_-Singapore_Zoo_-pair-8a.jpg/1920px-Buceros_rhinoceros_-Singapore_Zoo_-pair-8a.jpg',
    accuracy: '96%',
    accuracyValue: 96,
    recordedAt: _now,
    location: 'Taman Nasional Bali Barat',
    audioDuration: '0:14 / 0:30',
    category: 'Burung Enggang',
    overview:
        'Rhinoceros Hornbill adalah enggang besar berbulu hitam mengilap dengan ekor putih berpita gelap, ditemukan di hutan dataran rendah hingga perbukitan Kalimantan, Sumatra, Jawa, dan Semenanjung Malaya. Paruhnya besar berwarna oranye terang dengan tanduk mencolok di atasnya.',
    isEndemic: false,
    endangeredStatus: 'Rentan',
    temperature: '29°C',
    weatherCondition: 'Cerah, Angin Sepoi',
  ),
  BirdSighting(
    id: 'sp-2',
    name: 'Elang-ular Bido',
    scientificName: 'Spilornis cheela',
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/9/9f/Crested_Serpent-Eagle.jpg',
    accuracy: '91%',
    accuracyValue: 91,
    recordedAt: _now.subtract(const Duration(hours: 3)),
    location: 'Taman Nasional Gunung Halimun Salak',
    audioDuration: '0:08 / 0:15',
    category: 'Burung Pemangsa',
    overview:
        'Elang-ular Bido adalah elang besar dengan jambul gelap berujung putih, wajah dan mata kuning telanjang, serta bagian bawah tubuh cokelat kemerahan berbintik putih. Ditemukan di kawasan berhutan lebat di seluruh Asia tropis dan masih cukup umum di habitat yang sesuai.',
    isEndemic: false,
    endangeredStatus: 'Risiko Rendah',
    temperature: '22°C',
    weatherCondition: 'Berawan, Tenang',
  ),
  BirdSighting(
    id: 'sp-3',
    name: 'Merak Kerdil',
    scientificName: 'Polyplectron malacense',
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/3/33/BxZ_Polyplectron_malacense_00.jpg',
    accuracy: '78%',
    accuracyValue: 78,
    recordedAt: _now.subtract(const Duration(days: 1, hours: 2)),
    location: 'Taman Nasional Baluran',
    audioDuration: '0:10 / 0:25',
    category: 'Burung Darat',
    overview:
        'Malayan Peacock-Pheasant adalah unggas berbulu cokelat kusam dengan bintik mata hijau-biru mengilap di bagian atas tubuh dan jambul mengarah ke depan. Hidup di hutan hujan dataran rendah Semenanjung Malaya, bergerak diam-diam, dan berstatus Terancam Punah.',
    isEndemic: false,
    endangeredStatus: 'Genting',
    temperature: '31°C',
    weatherCondition: 'Cerah, Panas',
  ),
  BirdSighting(
    id: 'sp-4',
    name: 'Paok Hijau',
    scientificName: 'Pitta sordida',
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/thumb/6/6e/Hooded_Pitta%2C_crop.jpg/960px-Hooded_Pitta%2C_crop.jpg',
    accuracy: '65%',
    accuracyValue: 65,
    recordedAt: _now.subtract(const Duration(days: 2, hours: 5)),
    location: 'Rawa Gambut Kalimantan',
    audioDuration: '0:04 / 0:12',
    category: 'Burung Pengicau',
    overview:
        'Hooded Pitta adalah burung hutan mencolok dengan tubuh hijau zamrid, kepala hitam, perut bawah merah delima, bercak sayap biru pucat, dan garis mahkota cokelat hangat. Hidup di berbagai habitat berhutan mulai dari hutan lebat hingga perkebunan.',
    isEndemic: false,
    endangeredStatus: 'Risiko Rendah',
    temperature: '27°C',
    weatherCondition: 'Lembap, Berawan',
  ),
];

/// Data contoh awal yang mengisi riwayat sebelum ada rekaman baru dari user.
final List<BirdSighting> sampleSightings = List.of(speciesCatalog);
