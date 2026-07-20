# Model catalog

Inventory of every trained checkpoint from the team's research work, for
deciding what's worth pulling into this repo. Everything here is BirdNET
v2.4 transfer learning unless noted. Deployed pick is `CustomClassifier.tflite`
in this folder (Model B, see [experiments/](experiments/)); everything else
stays in the research working copy, not shipped in this repo.

`CustomClassifier.tflite` (50MB) is tracked via [Git LFS](https://git-lfs.com/)
in this repo — `git lfs install` once per machine, then clone/pull as normal.
If you just need the weights without cloning (or you're out of LFS bandwidth),
grab them directly from the [model-b-v1 release](https://github.com/Liamours/nusa-aves/releases/tag/model-b-v1) —
regular GitHub file hosting, no LFS quota involved.

## Species classifiers (BirdNET v2.4 fine-tune)

Two checkpoint flavors exist per training run:

- **Finetuned** ("Append" mode) — keeps BirdNET's ~6,522 global species
  classes and appends the custom ones, so the label file (and output layer)
  is ~6,700+ long. Larger file (~51MB) but understands non-target species too.
  This is the flavor we ship.
- **Retrained** ("Replace" mode) — custom classes only (~210-220 labels),
  smaller file (~25MB), no knowledge of species outside the target list.

All paths below are locations in the team's research working copy, **not**
folders in this repo — only Model B is actually shipped here.

| Version | Research-copy location (external, not shipped) | Flavor | Labels | Size | Trained | Recipe |
|---|---|---|---|---|---|---|
| 200-label | `model-200_labels/model_200/inference/models/Append.tflite` | Finetuned | 6,722 | 51M | 2025-03-16 | lr=0.001, no focal loss |
| 211-label | `model-200_labels/model_211/model Finetuned/model.tflite` | Finetuned | 6,734 | 51M | 2025-10-12 | lr=0.001 |
| 211-label | `model-200_labels/model_211/model Retrained/model.tflite` | Retrained | 212 | 25M | 2025-10-12 | lr=0.001 |
| 211-label (dup) | `model-211_labels/model Finetuned/model.tflite` | Finetuned | 6,734 | 51M | 2025-10-12 | lr=0.001 |
| 211-label (dup) | `model-211_labels/model Retrained/model.tflite` | Retrained | 212 | 25M | 2025-10-12 | lr=0.001 |
| birdnet-251012 | `model-birdnet-251012/model Finetuned/CustomClassifier.tflite` | Finetuned | 6,734 | 51M | 2025-10-10 | lr=0.001 — bundled in app-mobile's older assets |
| birdnet-251012 | `model-birdnet-251012/model Retrained/CustomClassifier.tflite` | Retrained | 212 | 25M | 2025-10-11 | lr=0.001 |
| 219-label, train | `model-219/model-old/train/Fine-Tuned/CustomClassifier.tflite` | Finetuned | 6,742 | 51M | 2026-01-24 | lr=0.0001, focal loss param added (disabled) |
| 219-label, train | `model-219/model-old/train/Retrain/CustomClassifier.tflite` | Retrained | 220 | 25M | 2026-01-25 | lr=0.0001 |
| 219-label, train_augmented | `model-219/model-old/train_augmented/Fine-Tuned/CustomClassifier.tflite` | Finetuned | 6,742 | 51M | 2026-01-24 | lr=0.0001, augmented data |
| 219-label, train_augmented | `model-219/model-old/train_augmented/Retrain/CustomClassifier.tflite` | Retrained | 220 | 25M | 2026-01-25 | lr=0.0001, augmented data |
| 219-label, Model A | `model-219/model-inference-260206/model_a/CustomClassifier.tflite` | Finetuned | 6,742 | 51M | 2026-01-24 | lr=0.0001 |
| **219-label, Model B — shipped here** | **this folder**: `CustomClassifier.tflite` + `_Labels.txt` / `_Params.csv` / `_sample_counts.csv` | Finetuned | 6,744 | 51M | 2026-02-06 | lr=0.0001, retrain of A on 2 more classes |

Model A vs B: McNemar's test on the MixIT (source-separated) subset shows B
wins significantly (χ²=14.06, p=0.0002, 0 losses); ties on the ORI subset.
Details in [experiments/mcnemar-test.ipynb](experiments/mcnemar-test.ipynb).

Hyperparameter recipe is otherwise constant across every run: BirdNET V2.4
base, hidden units=0 (linear probe head), dropout=0, batch size=32, center
crop. The 219-label runs added `audio_speed` and focal-loss params to the
config format (focal loss itself left disabled in every run seen).

## Species/config lists

Shipped in this repo:

| File | What it is |
|---|---|
| `species/detail_list-endangered_endemic.xlsx` | 29 curated endangered/endemic species with IUCN status + endemic region, used in the proposal's headline numbers |
| `CustomClassifier_Labels.txt` | Full 6,744-label list actually baked into the deployed model |

Research-copy only, not shipped here:

| Location | What it is |
|---|---|
| `model-219/label_matching/label-219.txt` / `label-birdnet.txt` / `label-219-updated.xlsx` | Maps the 219 custom species to their BirdNET global-label equivalents |
| `model-219/data-endangered_endemic/` | Per-species audio folders for the same 29-species subset |

## Other checkpoints (research-copy only, not species classifiers, not shipped here)

- **Binary bird/no-bird gate** — `model-binary_birdsound/model/*.pth`
  (PyTorch, 4 checkpoint variants: best-F1, best-recall, latest, lowest-loss).
  Best val F1 0.977, test F1 0.875 (test accuracy 0.919, precision 0.793,
  recall 0.977). A pre-filter, not used by the current pipeline.
- **Whisper-encoder baseline** — `model-200_labels/Whisper Classifier/output/model_best.pth`.
  Superseded baseline approach (Whisper audio encoder + classifier head,
  pre-dates the BirdNET fine-tuning approach); explains the "Whisper" in
  the public GitHub repo's name even though the deployed model doesn't use it.

## Not catalogued here

Raw training/eval datasets (several hundred MB to GB per folder) and
training source code — the public GitHub repo already covers the training
pipeline; only trained artifacts are tracked above.
