# Source data

Original files are retained unchanged in cces/, lucid/, turk/, and treats/.
CCES contains 1,427 unmatched and 1,000 matched records; teamweight belongs to the matched sample. The matched cases are a subset of unmatched cases. Writing was measured before the election and parking afterward. The pipeline does not impute responses for people not observed in the later wave.

Lucid is a Qualtrics CSV archive containing two metadata rows, excluded by explicit consent and attention criteria. Its provider party codes are documented in lucid/party_codebook.csv; see ../docs/lucid_provenance.md for the companion-project provenance. MTurk pools two survey extracts with distinct response IDs; shared IPs are examined only in a sensitivity check. The supplied sincerity question codes never/rarely as 1/2.

Raw files contain respondent identifiers. Derived analytical CSVs are ignored by Git, and only aggregate results are published by the pipeline. No new respondent-level exports are added to the repository. Source checksums are in sources.sha256.
