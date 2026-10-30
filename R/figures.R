experiment_figure <- function(means, effects, pooled, pooled_means, capped) {
  panel_levels <- c(
    "Writing\nCCES", "Writing\nLucid", "Parking\nCCES", "Experiments\nPooled"
  )
  metric_levels <- c(
    "Mean (SD units)\nAll responses", "Hedges' g\nAll responses",
    "Hedges' g\nCounts capped at 20"
  )
  means <- dplyr::mutate(means, metric = metric_levels[1])
  combined_means <- pooled_means |>
    dplyr::mutate(
      study = "Pooled", task = "Experiments", party = group,
      metric = metric_levels[1]
    )
  contrasts <- effects |>
    dplyr::mutate(
      metric = metric_levels[2], cue = "Difference"
    )
  synthesis <- pooled |>
    dplyr::mutate(
      study = "Pooled", task = "Experiments", party = group,
      metric = metric_levels[2], cue = "Difference"
    )
  capped_effects <- dplyr::bind_rows(
    capped$estimates,
    dplyr::mutate(capped$pooled,
      study = "Pooled", task = "Experiments", party = group
    )
  ) |>
    dplyr::mutate(metric = metric_levels[3], cue = "Difference")
  bounds <- range(c(
    contrasts$lower, contrasts$upper, capped_effects$lower, capped_effects$upper
  ))
  effect_limits <- expand.grid(
    estimate = bounds, metric = factor(metric_levels[2:3], metric_levels)
  )
  plot_data <- dplyr::bind_rows(
    means, contrasts, synthesis, combined_means, capped_effects
  ) |>
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
    ggplot2::geom_blank(
      data = effect_limits, ggplot2::aes(x = estimate), inherit.aes = FALSE
    ) +
    ggplot2::geom_vline(
      data = data.frame(metric = factor(
        metric_levels[2:3],
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
