source("R/synthesis.R")
writing <- effects[effects$task == "Writing", ]
pooled <- dplyr::bind_rows(lapply(
  c("All partisans", "Democrat", "Republican"), function(group) {
    x <- if (group == "All partisans") {
      writing
    } else {
      writing[writing$party == group, ]
    }
    dplyr::mutate(pool_effects(x), group = group, .before = 1)
  }
))
readr::write_csv(pooled, "tabs/pooled_writing.csv")
heterogeneity <- experiments |>
  dplyr::filter(party %in% c("Democrat", "Republican")) |>
  dplyr::group_by(study, task) |>
  dplyr::group_modify(~ strength_contrasts(.x)) |>
  dplyr::ungroup()
interactions <- heterogeneity |>
  dplyr::filter(contrast == "Difference") |>
  dplyr::mutate(p_holm = stats::p.adjust(p_value, "holm"))
readr::write_csv(heterogeneity, "tabs/strength_contrasts.csv")
readr::write_csv(interactions, "tabs/strength_interactions.csv")
strength_cells <- experiments |>
  dplyr::filter(party %in% c("Democrat", "Republican")) |>
  dplyr::group_by(study, task, party, strong, treatment) |>
  dplyr::group_modify(~ summarize_outcome(.x$outcome)) |>
  dplyr::ungroup()
readr::write_csv(strength_cells, "tabs/strength_cells.csv")

write_table(
  data.frame(
    Respondents = pooled$group, Difference = pooled$estimate, SE = pooled$se,
    `95% CI` = sprintf("[%.2f, %.2f]", pooled$lower, pooled$upper),
    `CCES weight (%)` = 100 * pooled$cces_weight, check.names = FALSE
  ),
  "tabs/pooled_writing.tex",
  paste0(
    "Exploratory fixed-effect synthesis of writing contrasts. ",
    "Differences are out-party minus in-party error counts. ",
    "Inverse-variance weights combine independent study-by-party contrasts; ",
    "intervals use the normal approximation."
  ),
  "tab:pooled_writing"
)
strength_table <- interactions |>
  dplyr::select(study, task, estimate, se, lower, upper, p_holm)
for (group in c("Strong", "Other")) {
  z <- heterogeneity[heterogeneity$contrast == group, ]
  stopifnot(identical(z$study, strength_table$study))
  stopifnot(identical(z$task, strength_table$task))
  strength_table[[group]] <- sprintf("%.2f (%.2f)", z$estimate, z$se)
}
write_table(
  data.frame(
    Study = strength_table$study, Task = strength_table$task,
    Strong = strength_table$Strong, Other = strength_table$Other,
    Difference = strength_table$estimate,
    `95% CI` = sprintf(
      "[%.2f, %.2f]", strength_table$lower, strength_table$upper
    ),
    `Adjusted p` = strength_table$p_holm, check.names = FALSE
  ),
  "tabs/strength_interactions.tex",
  paste0(
    "Exploratory moderation by partisan strength. Strong and Other columns ",
    "report out-party minus in-party effects, with HC3 standard errors ",
    "in parentheses. Other includes weak partisans and leaners. Each effect ",
    "gives Democrats and Republicans equal weight. Difference is the ",
    "strong-partisan effect minus the other-partisan effect, with a ",
    "95\\% interval. Holm adjustment covers the three interaction tests."
  ),
  "tab:strength"
)
macros <- character()
for (i in seq_len(nrow(pooled))) {
  prefix <- paste0("PooledWriting", gsub(" ", "", pooled$group[i]))
  for (stat in c("estimate", "se", "lower", "upper")) {
    suffix <- paste0(toupper(substr(stat, 1, 1)), substring(stat, 2))
    macros <- c(macros, sprintf(
      "\\newcommand{\\%s%s}{%.2f}", prefix, suffix, pooled[[stat]][i]
    ))
  }
}
macros <- c(macros, sprintf(
  "\\newcommand{\\PooledWritingCCESWeight}{%.0f}",
  100 * pooled$cces_weight[pooled$group == "All partisans"]
))
for (i in seq_len(nrow(interactions))) {
  x <- interactions[i, ]
  prefix <- paste0("Strength", x$study, x$task)
  for (stat in c("estimate", "se", "lower", "upper")) {
    suffix <- paste0(toupper(substr(stat, 1, 1)), substring(stat, 2))
    macros <- c(macros, sprintf(
      "\\newcommand{\\%s%s}{%.2f}", prefix, suffix, x[[stat]]
    ))
  }
}
writeLines(macros, "tabs/synthesis_macros.tex")
