# NUSA Aves — repo

Local working copy for the BRIN AIDeaNation 2026 submission. Full training
pipeline (dataset build, fine-tuning, MixIT source separation) is public at
[github.com/Liamours/Research_Birdsound-Classification_Whisper-Implementation](https://github.com/Liamours/Research_Birdsound-Classification_Whisper-Implementation)
and isn't duplicated here — this repo holds what's needed to run and demo
the system.

- **[model/](model/)** — the deployable classifier (Model B, chosen over
  Model A: statistically better on McNemar's test, no losses — see
  [model/experiments/](model/experiments/)) plus the comparison evidence.
  Full inventory of every checkpoint on the research drive, and why this
  one was picked, is in [model/CATALOG.md](model/CATALOG.md).
- **[species/](species/)** — full 219-species target list with endangerment
  category and endemic-country flags, plus the curated 29-species highlight
  behind the proposal's headline claims. See [species/README.md](species/README.md).
- **[server/](server/)** — inference CLI, packaged with Docker.
- **[app-mobile/](app-mobile/)** — Ihsan and Luqman's scope, intentionally empty here.
