experiment_figure <- function(summary, effects) {
  means <- summary |>
    dplyr::filter(party %in% c("Democrat", "Republican")) |>
    dplyr::mutate(
      metric = "Mean reported count", estimate = mean,
      cue = ifelse(party == treatment, "In-party cue", "Out-party cue"),
      position = ifelse(party == "Democrat", 2, 1) +
        ifelse(cue == "In-party cue", 0.14, -0.14)
    )
  contrasts <- effects |>
    dplyr::mutate(
      metric = "Out-party minus in-party", cue = "Difference",
      position = ifelse(party == "Democrat", 2, 1)
    )
  plot_data <- dplyr::bind_rows(means, contrasts) |>
    dplyr::mutate(
      panel = factor(paste(task, study, sep = "\n"),
        levels = c("Writing\nCCES", "Writing\nLucid", "Parking\nCCES")
      ),
      metric = factor(metric,
        levels = c("Mean reported count", "Out-party minus in-party")
      )
    )
  ggplot2::ggplot(plot_data, ggplot2::aes(estimate, position, color = cue)) +
    ggplot2::geom_vline(
      data = data.frame(metric = "Out-party minus in-party"),
      ggplot2::aes(xintercept = 0), linetype = "dashed", color = "grey55"
    ) +
    ggplot2::geom_segment(
      ggplot2::aes(x = lower, xend = upper, yend = position),
      linewidth = 0.6
    ) +
    ggplot2::geom_point(size = 2.4) +
    ggplot2::facet_grid(
      rows = ggplot2::vars(panel), cols = ggplot2::vars(metric),
      scales = "free_x", switch = "y"
    ) +
    ggplot2::scale_y_continuous(
      breaks = c(1, 2), labels = c("Republicans", "Democrats"),
      limits = c(0.55, 2.45)
    ) +
    ggplot2::scale_color_manual(
      values = c(
        "In-party cue" = "#0072B2", "Out-party cue" = "#D55E00",
        "Difference" = "#222222"
      ),
      breaks = c("In-party cue", "Out-party cue")
    ) +
    ggplot2::labs(x = NULL, y = NULL, color = NULL) +
    ggplot2::theme_minimal(base_size = 11) +
    ggplot2::theme(
      text = ggplot2::element_text(color = "grey10"),
      legend.position = "bottom", panel.grid.minor = ggplot2::element_blank(),
      panel.grid.major.y = ggplot2::element_blank(),
      strip.placement = "outside",
      strip.text.y.left = ggplot2::element_text(angle = 0, face = "bold"),
      strip.text.x = ggplot2::element_text(face = "bold"),
      panel.spacing = grid::unit(1, "lines")
    )
}
