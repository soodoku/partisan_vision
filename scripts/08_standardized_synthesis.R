standardized <- standardized_synthesis(experiments)
capped <- lapply(c(10, 15, 20), function(cap) {
  standardized_synthesis(
    dplyr::mutate(experiments, outcome = pmin(outcome, cap))
  )
})
names(capped) <- c("10", "15", "20")
sensitivity_fits <- c(capped, list(Uncapped = standardized))
standardized_sensitivity <- dplyr::bind_rows(lapply(
  names(sensitivity_fits), function(cap) {
    dplyr::mutate(sensitivity_fits[[cap]]$estimates, cap = cap)
  }
))
pooled_sensitivity <- dplyr::bind_rows(lapply(
  names(sensitivity_fits), function(cap) {
    dplyr::mutate(sensitivity_fits[[cap]]$pooled, cap = cap)
  }
))
readr::write_csv(standardized_sensitivity, "tabs/standardized_sensitivity.csv")
readr::write_csv(pooled_sensitivity, "tabs/pooled_sensitivity.csv")
readr::write_csv(standardized$estimates, "tabs/standardized_effects.csv")
readr::write_csv(standardized$pooled, "tabs/pooled_experiments.csv")
readr::write_csv(standardized$means, "tabs/standardized_means.csv")
readr::write_csv(standardized$pooled_means, "tabs/pooled_means.csv")
readr::write_csv(
  tibble::rownames_to_column(
    as.data.frame(standardized$covariance), "contrast"
  ),
  "tabs/standardized_covariance.csv"
)
write_table(
  data.frame(
    Respondents = standardized$pooled$group,
    `Pooled effect (SD)` = standardized$pooled$estimate,
    SE = standardized$pooled$se,
    `95% CI` = sprintf(
      "[%.2f, %.2f]", standardized$pooled$lower, standardized$pooled$upper
    ), check.names = FALSE
  ),
  "tabs/pooled_experiments.tex",
  paste0(
    "Exploratory synthesis of writing and parking experiments. ",
    "Effects are Hedges' g, oriented as out-party minus in-party. ",
    "Generalized least squares uses the covariance estimated from 5,000 ",
    "respondent bootstrap draws within study and respondent party. ",
    "Each CCES respondent's outcomes remain together in each draw. ",
    "Intervals use the normal approximation."
  ),
  "tab:pooled_experiments"
)
macros <- readLines("tabs/synthesis_macros.tex")
lucid_outcomes <- experiments |>
  dplyr::filter(study == "Lucid", party %in% c("Democrat", "Republican"))
macros <- c(macros, sprintf(
  "\\newcommand{\\LucidHundredCount}{%d}",
  sum(lucid_outcomes$outcome == 100, na.rm = TRUE)
))
tail_summary <- experiments |>
  dplyr::filter(party %in% c("Democrat", "Republican"), !is.na(outcome)) |>
  dplyr::group_by(study, task, party, treatment) |>
  dplyr::summarise(
    n = dplyr::n(), median = stats::median(outcome),
    p95 = stats::quantile(outcome, 0.95), maximum = max(outcome),
    above_10 = sum(outcome > 10), above_15 = sum(outcome > 15),
    above_20 = sum(outcome > 20), .groups = "drop"
  )
readr::write_csv(tail_summary, "tabs/response_tails.csv")
robust_overall <- capped[["20"]]$pooled[1, ]
for (stat in c("estimate", "se", "lower", "upper")) {
  suffix <- paste0(toupper(substr(stat, 1, 1)), substring(stat, 2))
  macros <- c(macros, sprintf(
    "\\newcommand{\\CappedPooled%s}{%.2f}", suffix, robust_overall[[stat]]
  ))
}
lucid_sensitivity <- sensitivity |>
  dplyr::filter(study == "Lucid", cap == 20)
for (i in seq_len(nrow(lucid_sensitivity))) {
  for (stat in c("estimate", "se")) {
    suffix <- paste0(toupper(substr(stat, 1, 1)), substring(stat, 2))
    macros <- c(macros, sprintf(
      "\\newcommand{\\CappedLucid%s%s}{%.2f}",
      lucid_sensitivity$party[i], suffix, lucid_sensitivity[[stat]][i]
    ))
  }
}
for (i in seq_len(nrow(standardized$pooled))) {
  prefix <- paste0(
    "PooledExperiments", gsub(" ", "", standardized$pooled$group[i])
  )
  for (stat in c("estimate", "se", "lower", "upper")) {
    suffix <- paste0(toupper(substr(stat, 1, 1)), substring(stat, 2))
    macros <- c(macros, sprintf(
      "\\newcommand{\\%s%s}{%.2f}", prefix, suffix,
      standardized$pooled[[stat]][i]
    ))
  }
}
own_writing <- summary |>
  dplyr::filter(task == "Writing", party == treatment)
macros <- c(
  macros,
  sprintf("\\newcommand{\\WritingOwnMinimum}{%.1f}", min(own_writing$mean)),
  sprintf("\\newcommand{\\WritingOwnMaximum}{%.1f}", max(own_writing$mean))
)
mask_source <- read_turk() |>
  dplyr::filter(sincerity %in% 1:2, party %in% c("Democrat", "Republican"))
macros <- c(macros, sprintf(
  "\\newcommand{\\MaskMaximum}{%s}",
  format(max(mask_source$outcome, na.rm = TRUE),
    big.mark = ",", scientific = FALSE, trim = TRUE
  )
))
writeLines(macros, "tabs/synthesis_macros.tex")

plot <- experiment_figure(
  standardized$means, standardized$estimates, standardized$pooled,
  standardized$pooled_means, capped[["20"]]
)
sensitivity_plot <- standardized_sensitivity |>
  dplyr::mutate(
    panel = factor(paste(task, study),
      levels = c("Writing CCES", "Writing Lucid", "Parking CCES")
    ),
    party = factor(party, levels = c("Democrat", "Republican")),
    cap = factor(cap, levels = c("10", "15", "20", "Uncapped"))
  ) |>
  ggplot2::ggplot(ggplot2::aes(estimate, cap)) +
  ggplot2::geom_vline(xintercept = 0, linetype = "dashed", color = "grey55") +
  ggplot2::geom_pointrange(
    ggplot2::aes(xmin = lower, xmax = upper),
    orientation = "y"
  ) +
  ggplot2::facet_grid(panel ~ party) +
  ggplot2::scale_y_discrete(labels = c(
    "10" = "Cap 10", "15" = "Cap 15", "20" = "Cap 20",
    "Uncapped" = "All responses"
  )) +
  ggplot2::labs(x = "Out-party minus in-party (Hedges' g)", y = NULL) +
  ggplot2::theme_minimal(base_size = 11) +
  ggplot2::theme(panel.grid.minor = ggplot2::element_blank())
pooled_caps <- dplyr::filter(pooled_sensitivity, group == "All partisans")
write_table(
  data.frame(
    `Response cap` = pooled_caps$cap,
    `Pooled effect (SD)` = pooled_caps$estimate, SE = pooled_caps$se,
    `95% CI` = sprintf("[%.2f, %.2f]", pooled_caps$lower, pooled_caps$upper),
    check.names = FALSE
  ),
  "tabs/pooled_sensitivity.tex",
  paste0(
    "Pooled experimental effects under alternative response caps. ",
    "Each cap applies to all study, task, and party groups. ",
    "Standard deviations and synthesis weights are recomputed for each cap; ",
    "all respondents remain in the analysis. Intervals use the ",
    "respondent bootstrap covariance and normal approximation."
  ),
  "tab:pooled_sensitivity"
)
mask_plot <- mask_sensitivity |>
  dplyr::filter(sample == "sincere", is.finite(cap)) |>
  ggplot2::ggplot(ggplot2::aes(estimate, factor(cap))) +
  ggplot2::geom_vline(xintercept = 0, linetype = "dashed", color = "grey55") +
  ggplot2::geom_pointrange(
    ggplot2::aes(xmin = lower, xmax = upper),
    orientation = "y"
  ) +
  ggplot2::scale_y_discrete(labels = function(x) paste("Counts capped at", x)) +
  ggplot2::labs(
    x = "Difference in mask count (Republicans minus Democrats)", y = NULL,
    subtitle = "Same respondents; counts above each cap are set to that cap"
  ) +
  ggplot2::theme_minimal(base_size = 11) +
  ggplot2::theme(panel.grid.minor = ggplot2::element_blank())
for (extension in c("pdf", "png")) {
  ggplot2::ggsave(paste0("figs/experiments.", extension), plot,
    width = 8, height = 6.5, dpi = 200
  )
  ggplot2::ggsave(paste0("figs/response_caps.", extension), sensitivity_plot,
    width = 7, height = 5.5, dpi = 200
  )
  ggplot2::ggsave(paste0("figs/masks.", extension), mask_plot,
    width = 6.5, height = 2.3, dpi = 200
  )
}

lines <- sprintf(
  "| %s | %s | %s | %.2f | [%.2f, %.2f] |",
  effects$study, effects$task, effects$party,
  effects$estimate, effects$lower, effects$upper
)
results <- paste(c(
  "| Study | Task | Respondents | Difference | 95% CI |",
  "|---|---|---|---:|---|", lines
), collapse = "\n")
overall <- standardized$pooled[standardized$pooled$group == "All partisans", ]
synthesis_text <- sprintf(
  paste0(
    "Across writing and parking experiments, the pooled effect is %.2f ",
    "standard deviations (SE %.2f; 95%% CI [%.2f, %.2f]), favoring ",
    "respondents' own party. Inference accounts for repeated CCES ",
    "respondents across tasks using a respondent bootstrap."
  ), overall$estimate, overall$se, overall$lower, overall$upper
)
write_readme(paste(
  synthesis_text,
  paste0(
    "The pooled direction persists with response caps of 10, 15, or 20. ",
    "Lucid's Republican writing contrast is sensitive to extreme responses: ",
    "it is near zero or slightly negative under these caps."
  ),
  "Out-party minus in-party differences in reported counts:",
  results,
  sep = "\n\n"
))
