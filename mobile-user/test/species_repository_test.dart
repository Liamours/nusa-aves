import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:frontend/services/species_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  test('ensureLoaded seeds the species table with all 219 species', () async {
    await SpeciesRepository.instance.ensureLoaded();
    final all = await SpeciesRepository.instance.getAllSpecies();
    expect(all.length, 219);
  });

  test('getSpeciesByStatus filters correctly', () async {
    await SpeciesRepository.instance.ensureLoaded();
    final vulnerable = await SpeciesRepository.instance.getSpeciesByStatus('Vulnerable');
    expect(vulnerable, isNotEmpty);
    for (final species in vulnerable) {
      expect(species.endangermentCategory, 'Vulnerable');
    }
  });

  test('lookup still works synchronously after ensureLoaded', () async {
    await SpeciesRepository.instance.ensureLoaded();
    final info = SpeciesRepository.instance.lookup('Anthracoceros malayanus_Black Hornbill');
    expect(info.commonName, isNotEmpty);
  });
}
