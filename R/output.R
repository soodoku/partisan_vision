write_table <- function(x, path, caption, label) {
  print(xtable::xtable(x, digits = 2, caption = caption, label = label),
    file = path, include.rownames = FALSE, comment = FALSE,
    caption.placement = "top", booktabs = TRUE
  )
  writeLines(trimws(readLines(path), which = "right"), path)
}

write_outputs <- function(summary, effects, masks, mask_effect) {
  tasks <- list(
    c("CCES", "Writing", "text_sum_cces", "error_sum_cces"),
    c("CCES", "Parking", "parking_sum_cces", "parking_sum_cces"),
    c("Lucid", "Writing", "text_sum_lucid", "error_sum_lucid")
  )
  for (task in tasks) {
    x <- summary[summary$study == task[1] & summary$task == task[2], ]
    write_table(
      setNames(
        x[c("party", "treatment", "n", "mean", "median", "se")],
        c("Respondents", "Attributed party", "N", "Mean", "Median", "SE")
      ),
      paste0("tabs/", task[3], ".tex"), paste(task[1], task[2]),
      paste0("tab:", task[4])
    )
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
      "Effect of party cues on reported counts. Differences are ",
      "out-party minus in-party means within respondent party. ",
      "Writing counts refer to errors in a passage; parking counts refer to ",
      "poorly parked cars. ",
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
  for (i in seq_len(nrow(effects))) {
    x <- effects[i, ]
    prefix <- paste0(x$study, x$task, x$party)
    macros <- c(
      macros,
      add_macro(paste0(prefix, "Difference"), x$estimate, 2),
      add_macro(paste0(prefix, "DifferenceSe"), x$se, 2)
    )
  }
  for (i in seq_len(nrow(masks))) {
    x <- masks[i, ]
    macros <- c(
      macros,
      add_macro(paste0("Masks", x$party, "Mean"), x$mean),
      add_macro(paste0("Masks", x$party, "Se"), x$se),
      add_macro(paste0("Masks", x$party, "Median"), x$median)
    )
  }
  macros <- c(
    macros,
    add_macro("MasksDifference", mask_effect$estimate, 2),
    add_macro("MasksDifferenceSe", mask_effect$se, 2),
    add_macro("MasksLower", mask_effect$lower, 2),
    add_macro("MasksUpper", mask_effect$upper, 2)
  )
  writeLines(macros, "tabs/macros.tex")
}

write_readme <- function(results, template = "docs/readme_template.md",
                         path = "readme.md") {
  current <- readLines(path)
  start <- which(current == "<!-- adjacent:start -->")
  end <- which(current == "<!-- adjacent:end -->")
  if (length(start) != 1L || length(end) != 1L || start >= end) {
    stop("README must contain one ordered pair of Adjacent markers")
  }
  body <- sub("RESULTS", results, readLines(template))
  writeLines(c(body, "", current[start:end]), path)
}
