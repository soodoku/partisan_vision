# Lucid party coding and survey context

The same January 2023 survey is analyzed in `finite-sample/know_pgap_cues`, a Carrie Roush collaboration. Its source manifest records SHA-256 `b18cfda2ca1658a2ac1551f80b64030255d784530bac85ed9e140719ac0920e8`, exactly matching this repository's ZIP.

The companion project identifies the author-held provider demographic codebook in `notnews/extreme_recall_2023/data/lucid/demographic-codebook.csv`. The party rows have been extracted without modification to `data/lucid/party_codebook.csv`, with a derived party-group column. The original codebook SHA-256 is `458eb2a21f9e540005c053e48633f09160881267510b8b6955c273a94f367f57`.

Democratic codes are 1, 2, 3, and 6; Republican codes are 5, 8, 9, and 10; codes 4 and 7 are nonpartisan. Codes 6 and 8 are other-party respondents who lean toward a major party. This independently confirms the original script's mapping. No Lucid estimates change from this verification.

The questionnaire includes racial/religious partisan-composition questions and economic party-cue questions before the error-count task. Those prompts can prime partisan interpretation; this study does not identify the cue effect without that preceding context. The attention check precedes the writing task. The companion study's full-sample primary analysis addresses a different outcome; we retain the original writing study's screened sample and document that choice.
