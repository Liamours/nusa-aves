# NUSA Aves inference CLI

Standalone CLI, no server required — pick an audio file, get species
predictions. Pipeline is `preprocess -> inference -> postprocess -> output`:

- **preprocess** (`Classifier.preprocess`, in `model.py`) — load audio,
  resample to 48kHz mono, pad/crop to 3s.
- **feature extraction** — no separate step. `CustomClassifier.tflite` is
  BirdNET's embedding extractor and the custom classifier head merged into
  one graph, so it takes raw audio in and gives class scores out directly.
- **inference** (`Classifier.run_inference`) — run the tflite interpreter.
- **postprocess** (`Classifier.postprocess`) — sigmoid the raw logits into
  0-1 confidences, take top-k.
- **output** (`cli.py`) — print as JSON.

Uses `../model/CustomClassifier.tflite` (the same model bundled offline in
`../mobile-user`, which mirrors this pipeline in Dart — see
`mobile-user/lib/services/audio_utils.dart` and `bird_classifier.dart`,
same constants, same preprocess/inference/postprocess split). Output
confidence is sigmoid-applied to the model's raw logits (verified
empirically — the raw tflite output is unbounded, not a 0-1 probability).
The classifier is multi-label (independent per-class sigmoid, not
softmax), so top-k confidences don't sum to 1 — and a species can
legitimately appear twice in the same top-k list with two different
confidence values, since the underlying label file has a couple of
species listed as two separate output classes. Both are real, this isn't
a bug.

## Environment variables

| Variable | Default | |
|---|---|---|
| `NUSA_LOG_LEVEL` | `INFO` | set to `DEBUG` for per-step logs (model load, preprocessing, inference) |
| `NUSA_MODEL_DIR` | `../model` | override if running from somewhere other than `server/` |

`--version` prints the CLI version and exits.

## Docker (build from the repo root, not this folder)

```
docker build -f server/Dockerfile -t nusa-aves .
docker run --rm nusa-aves samples/black_hornbill.wav
```

`samples/` (3 clips, one each for Black Hornbill, Rhinoceros Hornbill, and
Black-throated Wren-Babbler) is baked into the image, so the command above
is fully self-contained — no volume mount, no external files. Verified all
three give correct top-1 species at >0.98 confidence.

To classify your own file instead, mount it in:

```
docker run --rm -v "$(pwd)/clips:/clips" nusa-aves /clips/example.wav
```

On Windows with Git Bash, the `/clips` container-side path gets mangled by
MSYS path translation — prefix the run command with `MSYS_NO_PATHCONV=1` if
you hit a `FileNotFoundError` pointing at a Windows-style path that was
never supposed to exist.

## Without Docker

```
pip install -r requirements.txt
python cli.py <audio_file> [--top-k N]
```

## Output

A JSON array of `{"species": "<Scientific name>_<Common name>", "confidence": 0.0-1.0}`,
highest confidence first. `confidence` is this model's own estimate, not a
calibrated probability — treat >0.9 as a strong match, don't read too much
into small differences between two 0.3-ish scores.

## Self-check (pure logic, no model or audio needed)

```
python test_audio_utils.py
python test_config.py
```

## Troubleshooting

- **`FileNotFoundError` on a Windows-style path that was never supposed to
  exist** — see the `MSYS_NO_PATHCONV` note above.
- **Traceback instead of a clean error** — shouldn't happen; the CLI
  catches classification failures and exits with a one-line error message.
  If you see a raw traceback, that's a bug worth reporting.
- **Want to see what's happening step by step** — `NUSA_LOG_LEVEL=DEBUG`.
