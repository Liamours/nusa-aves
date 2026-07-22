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
}

final DateTime _now = DateTime.now();

/// Katalog spesies contoh (template). Karena app belum punya model ML,
/// setiap rekaman baru selalu "terdeteksi" sebagai `speciesCatalog.first`.
final List<BirdSighting> speciesCatalog = [
  BirdSighting(
    id: 'sp-1',
    name: 'Jalak Bali',
    scientificName: 'Leucopsar rothschildi',
    imageUrl:
        'https://images.unsplash.com/photo-1544604423-f3908f519502?q=80&w=600&auto=format&fit=crop',
    accuracy: '96%',
    accuracyValue: 96,
    recordedAt: _now,
    location: 'Taman Nasional Bali Barat',
    audioDuration: '0:14 / 0:30',
    category: 'Burung Pengicau',
    overview:
        'Jalak Bali adalah burung endemik Pulau Bali dengan bulu putih bersih, ujung sayap dan ekor hitam, serta kulit biru di sekitar mata. Populasinya di alam liar sangat terbatas dan menjadikannya salah satu burung paling terancam punah di dunia.',
    isEndemic: true,
    endangeredStatus: 'Kritis',
    temperature: '29°C',
    weatherCondition: 'Cerah, Angin Sepoi',
  ),
  BirdSighting(
    id: 'sp-2',
    name: 'Elang Jawa',
    scientificName: 'Nisaetus bartelsi',
    imageUrl:
        'https://images.unsplash.com/photo-1552728089-57bdde30beb3?q=80&w=600&auto=format&fit=crop',
    accuracy: '91%',
    accuracyValue: 91,
    recordedAt: _now.subtract(const Duration(hours: 3)),
    location: 'Taman Nasional Gunung Halimun Salak',
    audioDuration: '0:08 / 0:15',
    category: 'Burung Pemangsa',
    overview:
        'Elang Jawa adalah burung pemangsa endemik Pulau Jawa yang menjadi salah satu ikon konservasi Indonesia. Dikenal dengan jambul khas di kepalanya, elang ini hidup di hutan hujan pegunungan dan populasinya terus menyusut akibat kerusakan habitat.',
    isEndemic: true,
    endangeredStatus: 'Genting',
    temperature: '22°C',
    weatherCondition: 'Berawan, Tenang',
  ),
  BirdSighting(
    id: 'sp-3',
    name: 'Merak Hijau',
    scientificName: 'Pavo muticus',
    imageUrl:
        'https://images.unsplash.com/photo-1552728089-57bdde30beb3?q=80&w=600&auto=format&fit=crop',
    accuracy: '78%',
    accuracyValue: 78,
    recordedAt: _now.subtract(const Duration(days: 1, hours: 2)),
    location: 'Taman Nasional Baluran',
    audioDuration: '0:10 / 0:25',
    category: 'Burung Darat',
    overview:
        'Merak Hijau adalah salah satu burung terbesar dan paling mencolok di Asia Tenggara, dengan bulu hijau kebiruan mengilap dan bulu penutup ekor jantan yang panjang dan indah. Populasinya di Jawa terus menurun akibat perburuan dan hilangnya habitat.',
    isEndemic: false,
    endangeredStatus: 'Genting',
    temperature: '31°C',
    weatherCondition: 'Cerah, Panas',
  ),
  BirdSighting(
    id: 'sp-4',
    name: 'Cucak Rawa',
    scientificName: 'Pycnonotus zeylanicus',
    imageUrl:
        'https://images.unsplash.com/photo-1522858547137-f1dcec554f55?q=80&w=600&auto=format&fit=crop',
    accuracy: '65%',
    accuracyValue: 65,
    recordedAt: _now.subtract(const Duration(days: 2, hours: 5)),
    location: 'Rawa Gambut Kalimantan',
    audioDuration: '0:04 / 0:12',
    category: 'Burung Pengicau',
    overview:
        'Cucak Rawa dikenal karena suara kicaunya yang merdu dan bervariasi, membuatnya populer sebagai burung kicau peliharaan. Sayangnya, penangkapan liar besar-besaran membuat populasinya di alam menyusut drastis dalam beberapa dekade terakhir.',
    isEndemic: false,
    endangeredStatus: 'Kritis',
    temperature: '27°C',
    weatherCondition: 'Lembap, Berawan',
  ),
];

/// Data contoh awal yang mengisi riwayat sebelum ada rekaman baru dari user.
final List<BirdSighting> sampleSightings = List.of(speciesCatalog);
