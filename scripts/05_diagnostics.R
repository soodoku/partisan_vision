source("R/data.R")
source("R/analysis.R")
x <- readRDS("data/derived/analysis.rds")$experiments
influence <- x |>
  dplyr::filter(party %in% c("Democrat", "Republican")) |>
  dplyr::group_by(study, task, party) |>
  dplyr::group_modify(function(.x, .y) {
    out <- .x$outcome[.x$treatment != .y$party]
    own <- .x$outcome[.x$treatment == .y$party]
    out <- out[!is.na(out)]
    own <- own[!is.na(own)]
    estimates <- c(
      (sum(out) - out) / (length(out) - 1) - mean(own),
      mean(out) - (sum(own) - own) / (length(own) - 1)
    )
    tibble::tibble(minimum = min(estimates), maximum = max(estimates))
  }) |>
  dplyr::ungroup()
readr::write_csv(influence, "tabs/influence.csv")
turk <- read_turk() |>
  dplyr::filter(sincerity %in% 1:2, !is.na(party)) |>
  dplyr::mutate(outcome = pmin(outcome, 15))
ip_sample <- turk[!duplicated(turk$ip) | is.na(turk$ip), ]
ip_effect <- mean_contrast(
  ip_sample$outcome[ip_sample$party == "Republican"],
  ip_sample$outcome[ip_sample$party == "Democrat"]
)
readr::write_csv(ip_effect, "tabs/mask_ip_sensitivity.csv")
wave_summary <- turk |>
  dplyr::group_by(wave, party) |>
  dplyr::group_modify(~ summarize_outcome(.x$outcome)) |>
  dplyr::ungroup()
readr::write_csv(wave_summary, "tabs/mask_waves.csv")
readr::write_csv(x, "data/derived/experiments.csv")
readr::write_csv(dplyr::select(turk, -ip), "data/derived/masks.csv")
