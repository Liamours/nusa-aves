# Species information

- **[species-list-219.csv](species-list-219.csv)** — every species the model
  was trained to recognize (the 219-species target list, plus "Human speech"
  as a negative/noise class in some checkpoint variants — see
  [../model/CATALOG.md](../model/CATALOG.md)). Columns: scientific name,
  common name, IUCN-style endangerment category, and endemic-to-Malaysia /
  endemic-to-Indonesia flags. `endangerment_category` uses real IUCN
  category names, including `Least Concern` (194 of 219 rows, updated
  2026-07-23 — this used to be a bare `-`, which conflated "assessed and
  confirmed not threatened" with "we have no data"; it's genuinely Least
  Concern, cross-referenced against official IUCN Red List exports, not a
  placeholder). The two endemic columns still use `-` for "assessed and
  not endemic there" (a real result, not missing data) since there's no
  equivalent ambiguity for a plain yes/no flag. `not in reference data` (7
  of 219 rows, all three columns) means the team's reference table didn't
  cover that species at all — left blank rather than guessed. 18 species
  carry a threat category (12 Vulnerable, 5 Endangered, 1 Critically
  Endangered — updated 2026-07-20: `Otus alfredi` corrected from
  Endangered to Vulnerable after cross-checking Wikipedia, Avibase, and
  Birds of the World, which all currently agree on Vulnerable); 25 are
  flagged endemic to Malaysia or Indonesia.
- **[detail_list-endangered_endemic.xlsx](detail_list-endangered_endemic.xlsx)** —
  a curated highlight of the 29 most notable endangered/endemic species from
  that list, used for the proposal's headline numbers.
- **[species-descriptions.csv](species-descriptions.csv)** — common names
  (English/Indonesian/Malay), a short description, an image URL, and two
  reference links (Avibase, Birds of the World / eBird) per species. 200 of
  219 rows extracted from `classification_dict.dart` in a prior reference
  app ("birdApp" — not part of this repo, not published anywhere public
  as of this writing); the remaining 19 filled in by manual research
  against Wikipedia/Avibase/Birds of the World/eBird, including
  `Chrysocolaptes lucidus` and `Pitta guajana` — see below
  (`data_source: manual research`). That source app's own README claims
  an MIT license but it has no actual LICENSE file — worth confirming
  with its author before treating the 200-species portion as freely
  reusable.

  Every `image_url` was link-checked (2026-07-20). 13 were dead or rejected
  by Wikimedia's current thumbnail-size policy (pre-existing issues in the
  birdApp source data, not introduced here) and replaced with a working
  Wikimedia Commons image of the same species — those rows are marked
  `(image URL replaced, original was dead/rejected)` in `data_source`. The
  rest were confirmed live, though Wikimedia's aggressive rate-limiting
  during the check means a small number of untouched rows weren't
  re-verified with full certainty.

  **Two species that map to a name already used elsewhere in this
  project's taxonomy:**
  - `Chrysocolaptes lucidus` — same species as *Chrysocolaptes
    guttacristatus* ("Greater Flameback"), under the older, broader
    taxonomy that once covered the whole complex. That name isn't one of
    the 219 target species itself (only in the raw 6,744-label BirdNET
    space), so this row carries freshly researched, sourced content about
    the species directly.
  - `Pitta guajana` — same species as *Hydrornis irena* ("Malayan Banded
    Pitta," already one of the 219 target species) — the original
    training data folder names for this label reference "ssp. irenae,"
    the exact subspecies later split out as *Hydrornis irena*. This row
    reuses that species' content.

  Neither inference was checked against the full original training
  audio/metadata (inaccessible when this was resolved) — only against
  one filename each and general taxonomic history. Treat both rows as
  "best guess, clearly labeled," not verified fact.

The deployed model's raw output space is larger still (6,744 labels — the
219 custom species plus BirdNET's global species set); see
`../model/CustomClassifier_Labels.txt`.
