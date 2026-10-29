source("R/data.R")
registered <- dplyr::bind_rows(lapply(c(FALSE, TRUE), function(weighted) {
  raw <- haven::read_sav(paste0(
    "data/cces/UCM_CES2020_",
    if (weighted) "Weighted" else "Unweighted", "_Data.sav"
  ))
  x <- read_cces(weighted)
  row <- match(x$id, as.character(raw$caseid))
  x$affect <- as.numeric(raw$UCMDemTherm[row] - raw$UCMRepTherm[row])
  x$affect <- ifelse(x$party == "Democrat", x$affect, -x$affect)
  x <- x |>
    dplyr::filter(
      party %in% c("Democrat", "Republican"),
      !is.na(treatment), !is.na(outcome)
    ) |>
    dplyr::mutate(
      out_party = as.numeric(party != treatment),
      republican = as.numeric(party == "Republican")
    )
  dplyr::bind_rows(lapply(unique(x$task), function(task) {
    z <- x[x$task == task, ]
    models <- list(
      party = stats::lm(outcome ~ out_party * republican, z, weights = weight),
      affect = stats::lm(outcome ~ out_party * affect + republican,
        z,
        weights = weight
      )
    )
    dplyr::bind_rows(lapply(names(models), function(name) {
      fit <- models[[name]]
      covariance <- sandwich::vcovHC(fit, type = "HC3")
      se <- sqrt(diag(covariance))
      margin <- stats::qt(0.975, stats::df.residual(fit)) * se
      tibble::tibble(
        sample = if (weighted) "Matched weighted" else "Unmatched",
        task = task, model = name, term = names(stats::coef(fit)),
        estimate = stats::coef(fit), se = se,
        lower = stats::coef(fit) - margin,
        upper = stats::coef(fit) + margin,
        n = stats::nobs(fit)
      )
    }))
  }))
}))
readr::write_csv(registered, "tabs/registered_checks.csv")
