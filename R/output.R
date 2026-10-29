write_table <- function(x, path, caption, label) {
  print(xtable::xtable(x, digits = 2, caption = caption, label = label),
    file = path, include.rownames = FALSE, comment = FALSE,
    caption.placement = "top", booktabs = TRUE
  )
  writeLines(trimws(readLines(path), which = "right"), path)
}

write_outputs <- function(summary, effects, masks, mask_effect) {
  tasks <- list(
    c("CCES", "Writing", "text_cces", "text_sum_cces", "error_sum_cces"),
    c(
      "CCES", "Parking", "parking_cces",
      "parking_sum_cces", "parking_sum_cces"
    ),
    c("Lucid", "Writing", "text_lucid", "text_sum_lucid", "error_sum_lucid")
  )
  for (task in tasks) {
    x <- summary[summary$study == task[1] & summary$task == task[2], ]
    write_table(
      setNames(
        x[c("party", "treatment", "n", "mean", "median", "se")],
        c("Respondents", "Attributed party", "N", "Mean", "Median", "SE")
      ),
      paste0("tabs/", task[4], ".tex"), paste(task[1], task[2]),
      paste0("tab:", task[5])
    )
    plot <- ggplot2::ggplot(x, ggplot2::aes(party, mean, color = treatment)) +
      ggplot2::geom_pointrange(ggplot2::aes(ymin = lower, ymax = upper),
        position = ggplot2::position_dodge(width = 0.4)
      ) +
      ggplot2::labs(
        x = NULL, y = "Reported count (95% confidence interval)",
        color = "Attributed party"
      ) +
      ggplot2::theme_minimal() +
      ggplot2::theme(legend.position = "bottom")
    for (extension in c("pdf", "png")) {
      ggplot2::ggsave(paste0("figs/", task[3], ".", extension), plot,
        width = 6.5, height = 4, dpi = 200
      )
    }
  }
  write_table(
    setNames(
      masks[c("party", "n", "mean", "median", "se")],
      c("Respondents", "N", "Mean", "Median", "SE")
    ),
    "tabs/masks_sum.tex", "Mask counts capped at 15; never or rarely insincere",
    "tab:trump_sum"
  )

  effect_table <- data.frame(
    Study = effects$study, Task = effects$task,
    Respondents = effects$party, Difference = effects$estimate,
    interval = sprintf("[%.2f, %.2f]", effects$lower, effects$upper)
  )
  names(effect_table)[5] <- "95% CI"
  write_table(
    effect_table, "tabs/effects.tex",
    paste0(
      "Effect of party cues on error counts. Differences are ",
      "out-party minus in-party means within respondent party. ",
      "Intervals are pointwise Welch 95\\% confidence intervals."
    ),
    "tab:effects"
  )
  macros <- character()
  add_macro <- function(name, value, digits = 1) {
    sprintf("\\newcommand{\\%s}{%.*f}", name, digits, value)
  }
  for (i in seq_len(nrow(summary))) {
    x <- summary[i, ]
    prefix <- paste0(x$study, x$task, x$party, x$treatment)
    for (stat in c("mean", "median", "se")) {
      suffix <- paste0(toupper(substr(stat, 1, 1)), substring(stat, 2))
      macros <- c(macros, add_macro(paste0(prefix, suffix), x[[stat]]))
    }
  }
  for (i in seq_len(nrow(masks))) {
    x <- masks[i, ]
    macros <- c(
      macros,
      add_macro(paste0("Masks", x$party, "Mean"), x$mean),
      add_macro(paste0("Masks", x$party, "Se"), x$se)
    )
  }
  macros <- c(
    macros,
    add_macro("MasksDifference", mask_effect$estimate, 2),
    add_macro("MasksLower", mask_effect$lower, 2),
    add_macro("MasksUpper", mask_effect$upper, 2)
  )
  writeLines(macros, "tabs/macros.tex")
  lines <- sprintf(
    "| %s | %s | %s | %.2f | [%.2f, %.2f] |",
    effects$study, effects$task, effects$party,
    effects$estimate, effects$lower, effects$upper
  )
  results <- paste(c(
    "| Study | Task | Respondents | Difference | 95% CI |",
    "|---|---|---|---:|---|", lines
  ), collapse = "\n")
  readme <- readLines("docs/readme_template.md")
  writeLines(sub("RESULTS", results, readme), "readme.md")
}
