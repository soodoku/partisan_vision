source("R/data.R")
source("R/analysis.R")
source("R/output.R")
dir.create("data/derived", showWarnings = FALSE)
experiments <- dplyr::bind_rows(read_cces(), read_lucid()) |>
  dplyr::filter(
    party %in% c("Democrat", "Republican", "Independent"),
    !is.na(treatment)
  )
summary <- experiments |>
  dplyr::group_by(study, task, party, treatment) |>
  dplyr::group_modify(~ summarize_outcome(.x$outcome)) |>
  dplyr::ungroup()
effects <- estimate_effects(experiments)
turk <- read_turk()
masks <- turk |>
  dplyr::filter(sincerity %in% c(1, 2), !is.na(party)) |>
  dplyr::mutate(outcome = pmin(outcome, 15))
mask_summary <- masks |>
  dplyr::group_by(party) |>
  dplyr::group_modify(~ summarize_outcome(.x$outcome)) |>
  dplyr::ungroup()
mask_effect <- mean_contrast(
  masks$outcome[masks$party == "Republican"],
  masks$outcome[masks$party == "Democrat"]
)
sensitivity <- dplyr::bind_rows(lapply(c(10, 15, 20, Inf), function(cap) {
  estimate_effects(dplyr::mutate(experiments, outcome = pmin(outcome, cap))) |>
    dplyr::mutate(cap = cap)
}))
samples <- c("all", "sincere", "legacy")
mask_sensitivity <- dplyr::bind_rows(lapply(samples, function(sample) {
  x <- switch(sample,
    all = turk,
    sincere = dplyr::filter(turk, sincerity %in% 1:2),
    legacy = dplyr::filter(turk, sincerity %in% 3:5)
  )
  dplyr::bind_rows(lapply(c(10, 15, 20, Inf), function(cap) {
    mean_contrast(
      pmin(x$outcome[which(x$party == "Republican")], cap),
      pmin(x$outcome[which(x$party == "Democrat")], cap)
    ) |>
      dplyr::mutate(sample = sample, cap = cap)
  }))
}))
weighted <- read_cces(TRUE) |>
  dplyr::filter(party != "", !is.na(treatment), !is.na(outcome)) |>
  dplyr::group_by(task, party, treatment) |>
  dplyr::summarise(
    n = dplyr::n(),
    mean = stats::weighted.mean(outcome, weight), .groups = "drop"
  )
for (name in c(
  "summary", "effects", "mask_summary", "mask_effect",
  "sensitivity", "mask_sensitivity", "weighted"
)) {
  readr::write_csv(get(name), paste0("tabs/", name, ".csv"))
}
saveRDS(
  list(experiments = experiments, masks = masks), "data/derived/analysis.rds"
)
write_outputs(summary, effects, mask_summary, mask_effect)

source("scripts/05_diagnostics.R")

source("scripts/06_registered_checks.R")
