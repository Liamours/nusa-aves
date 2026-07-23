import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:tflite_flutter/tflite_flutter.dart';

import 'audio_utils.dart';
import 'species_repository.dart';

/// Dart mirror of `server/model.py`'s `Classifier`. Same pipeline —
/// preprocess -> inference -> postprocess — and the same reasoning applies:
/// `CustomClassifier.tflite` already bakes BirdNET's embedding extractor and
/// the custom classifier head into one graph, so it takes raw audio in and
/// gives class scores out with no separate feature-extraction step. Output
/// is pre-sigmoid logits, multi-label (independent per-class sigmoid, not
/// softmax) — top-k confidences don't sum to 1, that's expected.
class BirdClassifier {
  static const _modelAsset = 'assets/model/CustomClassifier.tflite';
  static const _labelsAsset = 'assets/model/CustomClassifier_Labels.txt';
  static const sampleRate = 48000;
  static const clipSeconds = 3.0;
  static const targetLength = 144000; // sampleRate * clipSeconds

  BirdClassifier._();
  static final BirdClassifier instance = BirdClassifier._();

  Interpreter? _interpreter;
  List<String>? _labels;

  Future<void> ensureLoaded() async {
    if (_interpreter != null) return;

    final modelBytes = await rootBundle.load(_modelAsset);
    _interpreter = Interpreter.fromBuffer(
      modelBytes.buffer.asUint8List(modelBytes.offsetInBytes, modelBytes.lengthInBytes),
    );

    final labelsText = await rootBundle.loadString(_labelsAsset);
    _labels = labelsText
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();

    await SpeciesRepository.instance.ensureLoaded();
  }

  /// Loads a WAV file, resamples to [sampleRate] mono if needed, and
  /// pads/crops to exactly [targetLength] samples (matches `pad_or_crop` in
  /// the Python reference).
  Future<Float32List> preprocess(String audioPath) async {
    final bytes = await File(audioPath).readAsBytes();
    final decoded = decodeWav(bytes);
    final resampled = decoded.sampleRate == sampleRate
        ? decoded.samples
        : resampleLinear(decoded.samples, decoded.sampleRate, sampleRate);
    return padOrCrop(resampled, targetLength);
  }

  /// BirdNET-style custom classifiers take input shape `[1, targetLength]`
  /// (batch of one raw audio clip) and give `[1, numClasses]` logits back —
  /// confirmed against this model via `getInputTensor`/`getOutputTensor`
  /// rather than assumed, since a wrong shape here fails silently as
  /// garbage predictions, not a crash.
  Float32List runInference(Float32List features) {
    final interpreter = _interpreter!;
    final numClasses = interpreter.getOutputTensor(0).shape.last;

    final input = [features];
    final output = [List<double>.filled(numClasses, 0.0)];

    interpreter.run(input, output);
    return Float32List.fromList(output.first);
  }

  List<Prediction> postprocess(Float32List logits, int topK) {
    return topKPredictions(sigmoid(logits), _labels!, topK);
  }

  /// Runs the full pipeline and returns the top [topK] species with their
  /// display metadata joined in from [SpeciesRepository].
  Future<List<ClassifiedSighting>> classifyFile(
    String audioPath, {
    int topK = 5,
  }) async {
    await ensureLoaded();
    final features = await preprocess(audioPath);
    final logits = runInference(features);
    final predictions = postprocess(logits, topK);

    return predictions.map((p) {
      final info = SpeciesRepository.instance.lookup(p.label);
      final scientificName = p.label.split('_').first;
      return ClassifiedSighting(
        scientificName: scientificName,
        confidence: p.confidence,
        species: info,
      );
    }).toList();
  }
}

/// One classifier prediction, joined with its display metadata — everything
/// [BirdSighting] needs except the recording-specific fields (id, path,
/// timestamp), which the caller fills in.
class ClassifiedSighting {
  final String scientificName;
  final double confidence;
  final SpeciesInfo species;

  const ClassifiedSighting({
    required this.scientificName,
    required this.confidence,
    required this.species,
  });
}
