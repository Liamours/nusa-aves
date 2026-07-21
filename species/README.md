# Species information

- **[species-list-219.csv](species-list-219.csv)** — every species the model
  was trained to recognize (the 219-species target list, plus "Human speech"
  as a negative/noise class in some checkpoint variants — see
  [../model/CATALOG.md](../model/CATALOG.md)). Columns: scientific name,
  common name, IUCN-style endangerment category, and endemic-to-Malaysia /
  endemic-to-Indonesia flags. `-` means assessed and not applicable (not
  threatened / not endemic there); `not in reference data` (7 of 219 rows)
  means the team's endangerment/endemic reference table didn't cover that
  species — left blank rather than guessed. 18 species carry a threat
  category (12 Vulnerable, 5 Endangered, 1 Critically Endangered — updated
  2026-07-20: `Otus alfredi` corrected from Endangered to Vulnerable after
  cross-checking Wikipedia, Avibase, and Birds of the World, which all
  currently agree on Vulnerable); 25 are flagged endemic to Malaysia or
  Indonesia.
- **[detail_list-endangered_endemic.xlsx](detail_list-endangered_endemic.xlsx)** —
  a curated highlight of the 29 most notable endangered/endemic species from
  that list, used for the proposal's headline numbers.
- **[species-descriptions.csv](species-descriptions.csv)** — common names
  (English/Indonesian/Malay), a short description, an image URL, and two
  reference links (Avibase, Birds of the World / eBird) per species. 200 of
  219 rows extracted from `external/birdApp`'s `classification_dict.dart`
  (the previous bird app); the remaining 19 filled in by manual research
  against Wikipedia/Avibase/Birds of the World/eBird (`data_source: manual
  research`), except 2 left as `not available` — see below.
  `external/birdApp`'s README claims an MIT license but the repo has no
  actual LICENSE file — worth confirming before treating that 200-species
  portion as freely reusable.

  Every `image_url` was link-checked (2026-07-20). 13 were dead or rejected
  by Wikimedia's current thumbnail-size policy (pre-existing issues in the
  birdApp source data, not introduced here) and replaced with a working
  Wikimedia Commons image of the same species — those rows are marked
  `(image URL replaced, original was dead/rejected)` in `data_source`. The
  rest were confirmed live, though Wikimedia's aggressive rate-limiting
  during the check means a small number of untouched rows weren't
  re-verified with full certainty.

  **Two rows intentionally left blank — real taxonomic ambiguity, not a
  research gap:**
  - `Chrysocolaptes lucidus` — under current taxonomy (IOC, Avibase) this
    binomial refers strictly to the Philippines-endemic "Buff-spotted
    Flameback," unrelated to Indonesia/Malaysia/Borneo. The
    Sumatra/Java/Borneo population this project actually means is now
    classified as *Chrysocolaptes guttacristatus* ("Greater Flameback"),
    which already exists as its own separate label in
    `../model/CustomClassifier_Labels.txt`. Needs a decision on whether
    this target-species entry is a legacy/duplicate label before writing
    a description under it.
  - `Pitta guajana` — after a 2010 split this binomial now refers
    specifically to the Javan Banded Pitta (Java/Bali only). But the
    original training data folder names reference "ssp. irenae," the
    Malay Peninsula/Sumatra subspecies — which under current taxonomy is
    a different, already-separately-labeled species, *Hydrornis irena*
    ("Malayan Banded Pitta"). Whether this target-species entry means the
    Javan species or is a legacy label for the Malayan one needs checking
    against the original training metadata before writing a description.

The deployed model's raw output space is larger still (6,744 labels — the
219 custom species plus BirdNET's global species set); see
`../model/CustomClassifier_Labels.txt`.
