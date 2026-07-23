# AGENTS.md

Orientation for any coding agent (or human) working in this repo. Read
this first — it tells you what exists, who owns what, and where the
deeper docs are.

## What this is

NUSA Aves: a BirdNET-based classifier for 219 endemic/endangered bird
species (Indonesia, Malaysia, Borneo), submitted to BRIN AIDeaNation 2026.
See the top-level [README.md](README.md) for the project pitch and
results.

## Structure and ownership

| Path | What | Owner / status |
|---|---|---|
| `model/` | Deployed classifier + evaluation evidence | stable, see `model/CATALOG.md` |
| `species/` | 219-species reference data (names, status, descriptions) | stable, see `species/README.md`; 2 rows (`Chrysocolaptes lucidus`, `Pitta guajana`) intentionally blank — real taxonomy ambiguity, not a gap |
| `server/` | Python inference CLI, Dockerized | active, has tests + CI — see `DEVELOPMENT.md` |
| `mobile-user/` | Flutter app | **separate owner (Ihsan), separate toolchain.** It ports `server/`'s pipeline to Dart deliberately (see `mobile-user/lib/services/audio_utils.dart` and `bird_classifier.dart` — same constants, same preprocess/inference/postprocess split, kept in sync manually, not shared code). Don't edit this directory, its CI, or its docs unless explicitly asked — treat it the same as a teammate's code in a shared repo, not something to refactor or restructure uninvited. |

`.github/workflows/` has CI (`ci.yml`, runs on `server/`/`model/`/`species/`
changes) and a tag-triggered release pipeline (`release.yml`). Both are
scoped to `server/` — they don't build or test `mobile-user/`.

## Commands (server/ only)

```bash
cd server
pip install -r requirements.txt
python test_audio_utils.py && python test_config.py   # fast, no model needed
python cli.py samples/black_hornbill.wav                # needs ../model/
docker build -f Dockerfile -t nusa-aves ..              # from repo root
```

Full detail: [DEVELOPMENT.md](DEVELOPMENT.md).

## Conventions

- No comments explaining *what* — names carry that. Comments only for
  non-obvious *why* (a hidden constraint, a workaround, a surprising fact
  — e.g. `model.py`'s docstring on why there's no feature-extraction step).
- Pure logic (no I/O, no model) → `audio_utils.py`/`config.py`, gets a test.
  I/O and model state → `model.py`/`cli.py`, verified via the Docker smoke
  test in CI instead of mocking the model.
- Don't add a dependency for what stdlib already does.
- Semantic versioning (`server/config.py`'s `VERSION`); tag `vX.Y.Z` to
  trigger a release.
- Commits and pushes to `github.com/Liamours/nusa-aves` should not
  mention AI assistance — an explicit, standing preference for this repo.

## Provenance worth knowing

- Model weights are tracked via Git LFS (`model/CustomClassifier.tflite`,
  ~50MB); also mirrored as a direct-download GitHub release
  (`model-b-v1`) so pulling them doesn't burn LFS bandwidth.
- `species/species-descriptions.csv` is 200 rows from `external/birdApp`
  (a prior reference app, path outside this repo) plus 17 rows filled in
  by research — every image URL was link-checked and 13 dead/stale ones
  were replaced. See `species/README.md` for the full provenance and the
  2 deliberately-blank rows.
- The published research (200 species, ICITACEE 2025) and what's actually
  deployed here (219 species, unpublished MixIT continuation) are
  different — see the top-level README's Results section before quoting
  numbers.
