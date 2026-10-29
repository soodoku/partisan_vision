write_table <- function(x, path, caption, label) {
  print(xtable::xtable(x, digits = 2, caption = caption, label = label),
    file = path, include.rownames = FALSE, comment = FALSE,
    caption.placement = "top"
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
      x[c("party", "treatment", "n", "mean", "median", "se")],
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
    masks[c("party", "n", "mean", "median", "se")],
    "tabs/masks_sum.tex", "Mask counts capped at 15; never or rarely insincere",
    "tab:trump_sum"
  )
  write_table(
    effects[c("study", "task", "party", "estimate", "lower", "upper")],
    "tabs/effects.tex",
    "Out-party minus in-party counts; Welch 95\\% intervals",
    "tab:effects"
  )
  lines <- vapply(seq_len(nrow(effects)), function(i) {
    x <- effects[i, ]
    sprintf(
      "%s %s, %s respondents: %.2f (95%% CI %.2f to %.2f).",
      x$study, tolower(x$task), x$party, x$estimate, x$lower, x$upper
    )
  }, character(1))
  mask_line <- sprintf(
    paste0(
      "MTurk Republican minus Democratic capped mask count: ",
      "%.2f (95%% CI %.2f to %.2f)."
    ),
    mask_effect$estimate, mask_effect$lower, mask_effect$upper
  )
  writeLines(c(lines, mask_line), "tabs/results.txt")
  tex <- gsub("%", "\\%",
    paste(c(lines, mask_line), collapse = "\n\n"),
    fixed = TRUE
  )
  writeLines(tex, "tabs/results.tex")
  readme <- readLines("docs/readme_template.md")
  writeLines(
    sub("RESULTS", paste(c(lines, mask_line), collapse = "\n\n"), readme),
    "readme.md"
  )
}
