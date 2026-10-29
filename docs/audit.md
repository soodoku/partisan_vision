# Analysis audit

The audit confirmed two substantive implementation errors: CCES writing outcomes were analyzed as factor ranks, and the MTurk sincerity exclusion was reversed. Parking and Lucid group means reproduce. The revised results concern reported counts in the analyzed samples and do not establish perceptual equivalence.

## Claims and estimands

| Claim | Unit, population, comparison | Assessment |
|---|---|---|
| Party cues affect writing counts | Respondent; unmatched CCES or selected Lucid sample; out-party minus in-party cue, within party | Randomized cue comparison conditional on observation; writing intervals include zero and nontrivial effects. |
| Party cues affect parking counts | Post-election CCES respondent; same within-party contrast | Democratic contrast is positive; pre/post-wave participation limits the analyzed population. |
| Parties see similar numbers of masks | MTurk respondent, pooled waves; Republican minus Democratic report | Observational and dependent on cap and sincerity selection; does not identify effects of party or perceptual equivalence. |
| Effects are generally small | Across heterogeneous tasks and samples | No equivalence margin or test supports this broad claim. |

For each experimental contrast, the purpose is to estimate how an attributed party changes reported counts. Randomized cues make that design reasonable within respondents with observed outcomes; missing assignment logs prevent independent verification of the randomizer. Implementation is now checked against numeric SPSS values and independent Welch arithmetic. Interpretation is limited to cue effects on reports. For MTurk, the purpose is descriptive comparison; party is not randomized, and response capping changes the estimand.

## Verified corrections

| Finding | Original | Corrected |
|---|---|---|
| CCES writing, Democrats / Democratic cue | 9.7 | 8.65 |
| CCES writing, Democrats / Republican cue | 9.9 | 8.92 |
| CCES writing, Republicans / Democratic cue | 8.4 | 7.59 |
| CCES writing, Republicans / Republican cue | 8.1 | 7.07 |
| Observed N, Republicans / Democratic writing cue | 253 | 252 (one missing outcome) |
| MTurk selected sincerity codes | 3–5: some of the time through always | 1–2: never or rarely |
| MTurk capped mean, Democrats | 5.4 (237 respondents) | 3.48 (682 respondents) |
| MTurk capped mean, Republicans | 5.9 (365 respondents) | 4.35 (514 respondents) |
| Republican parking / Democratic cue, manuscript | 8.7 | 8.43 (original table was correct) |
| Figure uncertainty | CCES ±1 SE; Lucid ±2 SE, unlabeled | Student-t 95% intervals, labeled |

The SPSS problem is not a uniform one-unit shift: sparse upper response categories make rank conversion distort both levels and contrasts. Numeric zero is preserved. Legacy scripts also relied on an attached xtable package that they did not consistently load.

## Evidence and sensitivity

`tabs/summary.csv` records group denominators, missingness, means, medians, SEs and intervals. `tabs/effects.csv` reports all six party-by-experiment contrasts and Holm adjustment. Democratic parking remains distinguishable from zero after this adjustment (adjusted p = .0022). `tabs/influence.csv` shows its contrast remains between 2.43 and 2.84 when deleting any single respondent; the original attribution to a few extremes does not follow from comparing medians.

`tabs/sensitivity.csv` evaluates response caps of 10, 15, and 20 alongside uncapped outcomes. Lucid contrasts can change sign after deleting a single extreme report. `tabs/mask_sensitivity.csv` crosses sincerity selection and caps. The uncapped sincere-sample mask contrast is −117.86 with a very wide interval, versus +0.87 after capping at 15. This is a changed outcome definition, not proof that capping recovers truth.

Distinct MTurk response IDs do not establish unique people across waves. There are 18 repeated IP occurrences in the selected sample; retaining the first record per IP produces a capped contrast of 0.92 (95% CI 0.46–1.39). Shared IP addresses can represent different people, so this is a sensitivity check, not automatic deduplication. Wave-specific summaries are also generated.

## Check matrix

| Audit area | Evidence / disposition |
|---|---|
| Denominators and units | Observed outcome denominators; counts remain in original units. |
| Missing versus zero | No replacement of missing outcomes by zero; one missing classified CCES writing response. |
| Row conservation / joins | No analytical joins; unique study-task-response keys; pooling checks distinct response IDs. |
| Provenance and consistency | Generated numerical macros, tables, and README share results; obsolete duplicate tables removed. |
| EDA and tails | Mechanical sweeps run on both analytical datasets; extreme mask reports and Lucid influence reported. |
| Construction | SPSS ranks and sincerity corrected; Lucid party mapping confirmed against the provider codebook; see lucid_provenance.md. |
| Estimands | Unmatched unweighted primary CCES, matched weighted description separately; capped and raw outcomes distinguished. |
| Inference | Unequal-variance Welch contrasts; pointwise intervals; Holm family of six experimental contrasts. No bootstrap or generated-outcome uncertainty. |
| Design / measurement | Randomized cue effects distinguished from nonrandom party comparisons. Reports do not identify perceptual mechanisms. |
| Baseline plausibility | Baseline distributions and zero counts checked. No validated scoring key or independent visible-mask count establishes accuracy of reports. |
| Registration | OSF registration retrieved through registrations API. Dated 2021-11-01, after 2020 fieldwork; no claim of prospective registration. |
| Generalizability | No national representativeness claim for unmatched or convenience samples. |
| Other econometric designs | No IV, RD, DiD, panel causal estimator, mediation, or treatment-on-treated calculation; inapplicable. |
| Dose, indices, mechanisms | Binary cues and single-item outcomes; dose/index decomposition inapplicable. Mechanism not measured. |
| External benchmarks / companion studies | No comparable ground-truth counting benchmark verified; no quantitative external validation claimed. |

## Unresolved evidence

The supplied Lucid instrument omits embedded party-code definitions, but the provider codebook recovered through the companion know_pgap_cues project confirms the mapping. See lucid_provenance.md. Assignment logs and a validated scoring key are unavailable in the repository. The two MTurk waves have unique response IDs but no verified stable person identifier. These limits prevent certifying every design assertion as independently verified.

## Validation

The pipeline has local lint and regression tests, clean-session execution, generated numerical provenance, and PDF compilation. Tests check observed denominators, zero preservation, SPSS numeric values, sincerity coding, and independent Welch calculations. The provenance sweep flags only color constants as orphan numbers; its filename ambiguity means it is not itself a proof of correctness. Generated result inputs provide the stronger guard.

The OSF record was retrieved from https://api.osf.io/v2/registrations/rqj8u/ on 2026-10-29. Haven import semantics follow https://haven.tidyverse.org/reference/read_spss.html; style follows https://style.tidyverse.org/.

`tabs/registered_checks.csv` reports party interactions and continuous pre-election affective-polarization moderation in both CCES samples. Models use HC3 intervals and fixed team weights. Continuous moderation is an exploratory implementation of the registration’s unspecified polarization subgroups; survey-design uncertainty beyond supplied weights is not identified.
