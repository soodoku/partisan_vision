summarize_outcome <- function(x) {
  observed <- x[!is.na(x)]
  n <- length(observed)
  se <- if (n > 1) stats::sd(observed) / sqrt(n) else NA_real_
  margin <- if (n > 1) stats::qt(0.975, n - 1) * se else NA_real_
  tibble::tibble(
    n_total = length(x), n = n, missing = sum(is.na(x)),
    mean = if (n) mean(observed) else NA_real_,
    median = if (n) stats::median(observed) else NA_real_,
    se = se, lower = mean(observed) - margin, upper = mean(observed) + margin
  )
}

mean_contrast <- function(x, y) {
  x <- x[!is.na(x)]
  y <- y[!is.na(y)]
  fit <- stats::t.test(x, y)
  tibble::tibble(
    estimate = mean(x) - mean(y), se = unname(fit$stderr),
    lower = fit$conf.int[1],
    upper = fit$conf.int[2], p_value = fit$p.value,
    n_out = length(x), n_in = length(y)
  )
}

estimate_effects <- function(data) {
  data |>
    dplyr::filter(party %in% c("Democrat", "Republican")) |>
    dplyr::group_by(study, task, party) |>
    dplyr::group_modify(function(.x, .y) {
      mean_contrast(
        .x$outcome[.x$treatment != .y$party],
        .x$outcome[.x$treatment == .y$party]
      )
    }) |>
    dplyr::ungroup() |>
    dplyr::mutate(p_holm = stats::p.adjust(p_value, method = "holm"))
}
