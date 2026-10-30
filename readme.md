# Partisan Vision? Partisan Bias in Simple Visual Evaluations

Carrie Roush, Gaurav Sood, and Alex Theodoridis

[Paper](ms/partisan_vision.pdf)

Randomized party cues in CCES and Lucid test whether party labels change counts of writing errors and poorly parked cars. MTurk mask counts describe party differences, not causal effects of party identification. Estimates describe the analyzed respondents, not a representative national population.

## Results

Out-party minus in-party attributed counts:

| Study | Task | Respondents | Difference | 95% CI |
|---|---|---|---:|---|
| CCES | Parking | Democrat | 2.63 | [1.19, 4.06] |
| CCES | Parking | Republican | 0.34 | [-1.53, 2.21] |
| CCES | Writing | Democrat | 0.26 | [-0.39, 0.92] |
| CCES | Writing | Republican | 0.52 | [-0.33, 1.37] |
| Lucid | Writing | Democrat | 0.43 | [-1.52, 2.39] |
| Lucid | Writing | Republican | 0.71 | [-1.13, 2.56] |

Intervals do not establish equivalence. MTurk results depend on response capping and sincerity selection. See the paper and sensitivity tables.

## Reproduce

Use R 4.6, a LaTeX distribution, and latexmk:

```
make restore
make check
```

`make ci-docker` uses a standard Rocker image. `R/` contains reusable functions; `scripts/99_run_all.R` runs the pipeline. `data/` retains source files, `data/derived/` contains ignored intermediates, and `tabs/` and `figs/` contain generated results. `renv.lock` pins dependencies. README results and manuscript numerical macros are generated together; edit [the template](docs/readme_template.md) rather than the rendered README.

Source survey records contain identifying fields; generated analytical outputs exclude them.

The OSF registration is dated November 2021, after CCES fieldwork in 2020; the paper treats it as a registered analysis description. Lucid party coding is verified against the provider codebook recovered through the companion project.

<!-- adjacent:start -->

## 🔗 Adjacent Repositories

- [soodoku/partisan_heads_2015](https://github.com/soodoku/partisan_heads_2015) — Replication Materials for "The Partisans in our Heads" \(Ahler and Sood, 2015\)
- [soodoku/partisan_pareto](https://github.com/soodoku/partisan_pareto) — Pareto Partisan: Are Partisans Willing to Bite Their Purse To Spite The Main Opposing Party?
- [soodoku/partisan_identity](https://github.com/soodoku/partisan_identity)
- [soodoku/partisan_principled](https://github.com/soodoku/partisan_principled) — Two survey experiments on partisan affect, fair-minded opponents, and biased allies: research note and reproducible analysis.
- [soodoku/partisan_scandal](https://github.com/soodoku/partisan_scandal) — Partisan Scandals

_Powered by [Adjacent](https://github.com/gojiplus/adjacent)_

<!-- adjacent:end -->
