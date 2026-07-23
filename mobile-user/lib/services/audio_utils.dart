import 'dart:math' as math;
import 'dart:typed_data';

/// Dart mirror of `server/audio_utils.py`, plus WAV decoding (Python's side
/// gets that for free from librosa; here it's hand-rolled since decoding a
/// canonical PCM WAV is a fixed 44-ish byte header, not worth a dependency).
class DecodedAudio {
  final Float32List samples;
  final int sampleRate;

  const DecodedAudio(this.samples, this.sampleRate);
}

/// Parses a PCM WAV file (as produced by `record`'s `AudioEncoder.wav`) into
/// normalized mono float32 samples. Scans chunks after the RIFF/WAVE header
/// instead of assuming a fixed 44-byte offset, since some encoders insert
/// extra chunks (e.g. LIST) before `data`.
DecodedAudio decodeWav(Uint8List bytes) {
  final data = ByteData.sublistView(bytes);
  if (bytes.length < 12 ||
      String.fromCharCodes(bytes.sublist(0, 4)) != 'RIFF' ||
      String.fromCharCodes(bytes.sublist(8, 12)) != 'WAVE') {
    throw const FormatException('Not a RIFF/WAVE file');
  }

  int? sampleRate;
  int? numChannels;
  int? bitsPerSample;
  int? dataOffset;
  int? dataLength;

  var offset = 12;
  while (offset + 8 <= bytes.length) {
    final chunkId = String.fromCharCodes(bytes.sublist(offset, offset + 4));
    final chunkSize = data.getUint32(offset + 4, Endian.little);
    final bodyStart = offset + 8;

    if (chunkId == 'fmt ') {
      numChannels = data.getUint16(bodyStart + 2, Endian.little);
      sampleRate = data.getUint32(bodyStart + 4, Endian.little);
      bitsPerSample = data.getUint16(bodyStart + 14, Endian.little);
    } else if (chunkId == 'data') {
      dataOffset = bodyStart;
      dataLength = chunkSize;
    }

    // Chunks are word-aligned: odd sizes get a padding byte.
    offset = bodyStart + chunkSize + (chunkSize.isOdd ? 1 : 0);
  }

  if (sampleRate == null || numChannels == null || bitsPerSample == null || dataOffset == null) {
    throw const FormatException('WAV file missing fmt or data chunk');
  }
  if (bitsPerSample != 16) {
    throw FormatException('Unsupported bits per sample: $bitsPerSample (expected 16)');
  }

  final end = math.min(dataOffset + dataLength!, bytes.length);
  final sampleCount = (end - dataOffset) ~/ (2 * numChannels);
  final mono = Float32List(sampleCount);

  for (var i = 0; i < sampleCount; i++) {
    var sum = 0;
    for (var ch = 0; ch < numChannels; ch++) {
      final byteIndex = dataOffset + (i * numChannels + ch) * 2;
      sum += data.getInt16(byteIndex, Endian.little);
    }
    mono[i] = (sum / numChannels) / 32768.0;
  }

  return DecodedAudio(mono, sampleRate);
}

/// Simple linear-interpolation resample. Only exercised as a defensive
/// fallback — recording is configured to capture at [targetRate] directly,
/// so this path shouldn't normally run.
Float32List resampleLinear(Float32List samples, int fromRate, int toRate) {
  if (fromRate == toRate || samples.isEmpty) return samples;
  final outLength = (samples.length * toRate / fromRate).round();
  final out = Float32List(outLength);
  for (var i = 0; i < outLength; i++) {
    final srcPos = i * fromRate / toRate;
    final srcIndex = srcPos.floor();
    final frac = srcPos - srcIndex;
    final a = samples[srcIndex.clamp(0, samples.length - 1)];
    final b = samples[(srcIndex + 1).clamp(0, samples.length - 1)];
    out[i] = a + (b - a) * frac;
  }
  return out;
}

Float32List padOrCrop(Float32List audio, int targetLength) {
  if (audio.length < targetLength) {
    final padded = Float32List(targetLength);
    padded.setRange(0, audio.length, audio);
    return padded;
  }
  return Float32List.sublistView(audio, 0, targetLength);
}

Float32List sigmoid(Float32List logits) {
  final out = Float32List(logits.length);
  for (var i = 0; i < logits.length; i++) {
    out[i] = 1 / (1 + math.exp(-logits[i]));
  }
  return out;
}

class Prediction {
  final String label;
  final double confidence;

  const Prediction(this.label, this.confidence);
}

List<Prediction> topKPredictions(Float32List scores, List<String> labels, int k) {
  final indices = List<int>.generate(scores.length, (i) => i)
    ..sort((a, b) => scores[b].compareTo(scores[a]));
  return indices
      .take(k)
      .map((i) => Prediction(labels[i], scores[i].toDouble()))
      .toList();
}
