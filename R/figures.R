experiment_figure <- function(means, effects, pooled, pooled_means) {
  panel_levels <- c(
    "Writing\nCCES", "Writing\nLucid", "Parking\nCCES", "Experiments\nPooled"
  )
  metric_levels <- c(
    "Scaled mean (SD units)", "Standardized difference\n(Hedges' g)"
  )
  means <- dplyr::mutate(means, metric = "Scaled mean (SD units)")
  combined_means <- pooled_means |>
    dplyr::mutate(
      study = "Pooled", task = "Experiments", party = group,
      metric = "Scaled mean (SD units)"
    )
  contrasts <- effects |>
    dplyr::mutate(
      metric = "Standardized difference\n(Hedges' g)", cue = "Difference"
    )
  synthesis <- pooled |>
    dplyr::mutate(
      study = "Pooled", task = "Experiments", party = group,
      metric = "Standardized difference\n(Hedges' g)", cue = "Difference"
    )
  plot_data <- dplyr::bind_rows(means, contrasts, synthesis, combined_means) |>
    dplyr::mutate(
      panel = factor(paste(task, study, sep = "\n"),
        levels = panel_levels
      ),
      party = factor(party,
        levels = c("All partisans", "Republican", "Democrat")
      ),
      metric = factor(metric,
        levels = metric_levels
      )
    )
  ggplot2::ggplot(plot_data, ggplot2::aes(estimate, party, color = cue)) +
    ggplot2::geom_vline(
      data = data.frame(metric = factor(
        "Standardized difference\n(Hedges' g)",
        levels = metric_levels
      )),
      ggplot2::aes(xintercept = 0), linetype = "dashed", color = "grey55"
    ) +
    ggplot2::geom_pointrange(
      ggplot2::aes(xmin = lower, xmax = upper),
      orientation = "y",
      position = ggplot2::position_dodge(width = 0.45), linewidth = 0.5
    ) +
    ggplot2::facet_grid(
      rows = ggplot2::vars(panel), cols = ggplot2::vars(metric),
      scales = "free", switch = "y"
    ) +
    ggplot2::scale_y_discrete(labels = c(
      "Republican" = "Republicans", "Democrat" = "Democrats",
      "All partisans" = "All partisans"
    )) +
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
