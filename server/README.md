# NUSA Aves inference CLI

Identifies bird species from an audio clip using `../model/CustomClassifier.tflite`
(the same model bundled offline in `../app-mobile`). Preprocessing (48kHz
mono, 3s clips) matches the mobile app's `AudioProcessor`. Output confidence
is sigmoid-applied to the model's raw logits (verified empirically — the raw
tflite output is unbounded, not a 0-1 probability). The classifier is
multi-label (independent per-class sigmoid, not softmax), so top-k
confidences don't sum to 1 — and a species can legitimately appear twice in
the same top-k list with two different confidence values, since the
underlying label file has a couple of species listed as two separate output
classes. Both are real, this isn't a bug.

Verified working end-to-end against held-out clips (Docker build + run,
correct top-1 species at >0.98 confidence for Black Hornbill, Black-throated
Wren-Babbler, and Rhinoceros Hornbill test clips).

## Docker (build from the repo root, not this folder)

```
docker build -f server/Dockerfile -t nusa-aves .
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

## Self-check (pure logic, no model or audio needed)

```
python test_audio_utils.py
```
