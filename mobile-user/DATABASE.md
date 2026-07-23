# Species data: from bundled CSV to a real SQLite table

Proposal, not yet implemented. Written by Rifqi's side after a review of
the current data flow — flagging this for Ihsan/Luqman since it touches
`mobile-user`'s own architecture; nothing here has been coded yet.

## Problem

`species_repository.dart` loads `assets/species/species-list-219.csv` and
`assets/species/species-descriptions.csv` and joins them into an in-memory
`Map<String, SpeciesInfo>` on every app launch. `database_service.dart`'s
`sightings` table stores a **flattened copy** of species info
(`name`, `imageUrl`, `overview`, `isEndemic`, `endangeredStatus`, ...) per
sighting row, not a reference to a shared species table.

This works for the one thing it's used for today: look up *this one*
species right after a detection. It has no path to:
- browsing/searching the full 219-species catalog independent of what's
  been recorded
- any query that spans sightings *and* species together — e.g. "how many
  Vulnerable species have I recorded," "species I've never spotted,"
  "filter my history by endemic status"

Those would currently mean hand-rolling joins in Dart over two different
in-memory structures, instead of one SQL query.

## Proposed solution

Add a `species` table to the same SQLite database `sightings` already
lives in, seeded once from the bundled CSVs — not re-parsed into memory
on every cold start.

```sql
CREATE TABLE species (
  scientific_name TEXT PRIMARY KEY,
  common_english TEXT,
  common_indonesian TEXT,
  description TEXT,
  image_url TEXT,
  endangerment_category TEXT NOT NULL,   -- 'Least Concern', 'Vulnerable', 'Endangered',
                                          -- 'Critically Endangered', 'Not Evaluated'
  is_endemic_malaysia INTEGER NOT NULL,  -- 0/1
  is_endemic_indonesia INTEGER NOT NULL, -- 0/1
  source_url_1 TEXT,
  source_url_2 TEXT
);
```

(`endangerment_category` values assume the `-` → `Least Concern` /
`not in reference data` → `Not Evaluated` rename discussed separately for
`species/species-list-219.csv` — do that CSV-side fix first, since both
consumers benefit from it, not just this table.)

### Seeding

On first launch (or on an app-version bump that changes the schema),
check `SELECT COUNT(*) FROM species`; if empty, read both CSVs from
`rootBundle` once, join by `scientific_name` (same logic
`species_repository.dart` already has), and batch-insert. After that,
`species_repository.dart`'s job shrinks to: query this table instead of
parsing CSV — same public API (`lookup()`, `ensureLoaded()`), different
implementation underneath. Callers (`bird_classifier.dart`,
`detection_result_screen.dart`, etc.) don't need to change.

### What changes for `sightings`

`sightings.scientificName` becomes a real foreign key into `species`
instead of an unrelated column. Keep storing the flattened snapshot
fields too (`name`, `imageUrl`, `overview`, `endangeredStatus`) —
that's still correct: a sighting should remember what was shown to the
user *at that time*, even if `species` data is corrected later. The join
is for new queries (stats, filters), not for replacing history's own
record of what happened.

### What doesn't change

- CSVs stay the source of truth for authoring/editing species data —
  same files, same format, edited the same way.
- No change to `BirdClassifier`, `audio_utils.dart`, or anything in the
  classification pipeline.
- No change to the `sightings` table's existing columns.

## Open question

Is a "browse/filter the full species catalog" or "stats across my
sighting history" feature actually planned? If the app only ever needs
"show me info about the one species I just detected," the current
in-memory-`Map` approach is defensible as-is and this becomes a
lower-priority cleanup rather than something blocking a feature.
