# Partisan Vision? Partisan Bias in Simple Visual Evaluations

Carrie Roush, Gaurav Sood, and Alex Theodoridis

[Paper](ms/partisan_vision.pdf) · [Audit](docs/audit.md)

Randomized party cues in CCES and Lucid test whether attributed authorship changes reported error counts. MTurk mask counts describe party differences, not causal effects of party identification. Estimates describe the analyzed respondents, not a representative national population.

## Results

Out-party minus in-party attributed counts:

CCES parking, Democrat respondents: 2.63 (95% CI 1.19 to 4.06).

CCES parking, Republican respondents: 0.34 (95% CI -1.53 to 2.21).

CCES writing, Democrat respondents: 0.26 (95% CI -0.39 to 0.92).

CCES writing, Republican respondents: 0.52 (95% CI -0.33 to 1.37).

Lucid writing, Democrat respondents: 0.43 (95% CI -1.52 to 2.39).

Lucid writing, Republican respondents: 0.71 (95% CI -1.13 to 2.56).

MTurk Republican minus Democratic capped mask count: 0.87 (95% CI 0.41 to 1.33).

Intervals do not establish equivalence. MTurk results depend on response capping and sincerity selection. See the paper and sensitivity tables.

## Reproduce

Use R 4.6, a LaTeX distribution, and latexmk:

```
make restore
make check
```

`make ci-docker` uses a standard Rocker image. `R/` contains reusable functions; `scripts/99_run_all.R` runs the pipeline. `data/` retains source files, `data/derived/` contains ignored intermediates, and `tabs/` and `figs/` contain generated results. `renv.lock` pins dependencies. README results and manuscript results are generated together; edit this template rather than the rendered README.

The audit distinguishes confirmed errors from changed estimands and unavailable evidence. Source survey records contain identifying fields; generated analytical outputs exclude them.

The OSF registration is dated November 2021, after CCES fieldwork in 2020; the paper treats it as a registered analysis description. Lucid party-code documentation remains unresolved.
