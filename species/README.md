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
  category (11 Vulnerable, 6 Endangered, 1 Critically Endangered); 25 are
  flagged endemic to Malaysia or Indonesia.
- **[detail_list-endangered_endemic.xlsx](detail_list-endangered_endemic.xlsx)** —
  a curated highlight of the 29 most notable endangered/endemic species from
  that list, used for the proposal's headline numbers.

The deployed model's raw output space is larger still (6,744 labels — the
219 custom species plus BirdNET's global species set); see
`../model/CustomClassifier_Labels.txt`.
