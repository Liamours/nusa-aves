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
- **[mobile-user/](mobile-user/)** — a Flutter app that runs the same
  classifier fully offline, on-device.

## Results

Two research phases feed this app — kept separate here since they have
different publication status:

- **Published** (first author, ICITACEE 2025, IEEE Xplore): BirdNET
  fine-tuned on **200** endemic/endangered species from Indonesia,
  Malaysia, and Borneo. Accuracy 76.28%, weighted F1 80.29%, macro F1
  65.90% on the 200-species test set.
- **Unpublished continuation** (**219** species, adds MixIT source
  separation to handle field noise; manuscript in peer review at PeerJ,
  led by a collaborator — not first-authored here): macro F1 improves from
  0.291 to 0.419 (+44.1%) on the endemic/endangered subset once
  MixIT-separated audio is used.

The model shipped in this repo (`model/CustomClassifier.tflite`) is the
**219-species** version — that's a statement about what's deployed, not
about what's published.

Informally field-tested at Bandung Zoo and Zoo Negara Malaysia (mixed
results in high-noise, uncontrolled conditions — not a formal evaluation,
and part of what motivated the MixIT work above).
