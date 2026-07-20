# NUSA Aves

AI-based passive acoustic monitoring for endemic and endangered bird
species in Indonesia and Malaysia. A BirdNET-based classifier identifies
species from short audio clips, packaged here as a self-contained CLI.

Built for BRIN AIDeaNation 2026. The training pipeline (dataset
construction, fine-tuning, MixIT source separation) and published results
are at [github.com/Liamours/Research_Birdsound-Classification_Whisper-Implementation](https://github.com/Liamours/Research_Birdsound-Classification_Whisper-Implementation).

## Quick start

```
docker build -f server/Dockerfile -t nusa-aves .
docker run --rm nusa-aves samples/black_hornbill.wav
```

No setup beyond Docker — the model and a few sample clips are bundled in
the image. See [server/README.md](server/README.md) for classifying your
own audio and running without Docker.

## Contents

- **[model/](model/)** — the deployed classifier and how it was evaluated.
- **[species/](species/)** — the 219 species the model recognizes, with
  endangerment and endemic-region status.
- **[server/](server/)** — the inference CLI.

## Results

Fine-tuned on 12,511 recordings across 219 endemic and endangered species
from Indonesia, Malaysia, and Borneo. Macro F1 0.554 (accuracy 0.72) on the
full 219-species test set; Macro F1 0.419 (accuracy 0.661) on the
endangered/endemic subset — a 44.1% improvement over the unmodified
baseline. Field-validated at Bandung Zoo and Zoo Negara Malaysia. Published
as first author at ICITACEE 2025 (IEEE Xplore).
