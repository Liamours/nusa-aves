# Developing NUSA Aves

Scope: `model/`, `species/`, `server/`. `mobile-user/` is a separate Flutter
app with its own toolchain and owner — this doc doesn't cover it.

## Layout

```
model/    deployed classifier + evaluation evidence (model/CATALOG.md)
species/  219-species reference data (species/README.md)
server/   the inference CLI — this is what has tests/CI
```

## server/ internals

```
config.py            env-var config (log level, model dir, version)
audio_utils.py        pure array logic: pad/crop, sigmoid, top-k ranking
model.py               Classifier: preprocess -> inference -> postprocess
cli.py                  argparse entrypoint, logging setup, error handling
test_audio_utils.py    tests for audio_utils.py (no model needed)
test_config.py          tests for config.py env-var overrides
samples/                3 bundled clips used for the CI smoke test
```

## Running things locally

```bash
cd server
pip install -r requirements.txt
python test_audio_utils.py && python test_config.py   # pure-logic tests, fast
python cli.py samples/black_hornbill.wav               # needs ../model/ present
NUSA_LOG_LEVEL=DEBUG python cli.py samples/black_hornbill.wav --top-k 3
```

Docker (build from the repo root, not `server/`):

```bash
docker build -f server/Dockerfile -t nusa-aves .
docker run --rm nusa-aves samples/black_hornbill.wav
```

## CI

`.github/workflows/ci.yml` runs on any push/PR touching `server/`,
`model/`, or `species/`:
- `unit-tests` — the two pure-logic test files, no model or Docker needed
- `docker-build` — builds the real image and runs a smoke test against a
  bundled sample, asserting the top prediction and confidence — this is
  what would have caught the sigmoid bug from early development (raw
  logits printed as "confidence" instead of a 0-1 probability)

## Releasing

Tag `vX.Y.Z` and push the tag. `.github/workflows/release.yml` builds the
image, smoke-tests it, pushes to `ghcr.io/<owner>/nusa-aves:vX.Y.Z` and
`:latest`, and creates a GitHub release with auto-generated notes. Bump
`VERSION` in `server/config.py` to match before tagging.

## Adding a species description

Edit `species/species-descriptions.csv` directly (plain CSV, one row per
species). See `species/README.md` for the two rows still open
(`Chrysocolaptes lucidus`, `Pitta guajana`) and why they're blocked on a
taxonomy decision rather than a missing description.

## Conventions

- No comments explaining *what* code does — names should carry that.
  Comments only for non-obvious *why* (see `model.py`'s module docstring
  for an example: why there's no separate feature-extraction step).
- Pure logic (no I/O, no model) goes in `audio_utils.py` and gets a test.
  I/O and model state stay in `model.py`/`cli.py`, tested via the Docker
  smoke test instead of mocking the model.
- Don't add a dependency for what stdlib already does (see: `logging`
  instead of a framework, `argparse --version` instead of a versioning
  library).
