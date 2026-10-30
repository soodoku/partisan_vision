pool_effects <- function(x) {
  stopifnot(nrow(x) > 1L, all(is.finite(x$se)), all(x$se > 0))
  precision <- 1 / x$se^2
  weights <- precision / sum(precision)
  estimate <- sum(weights * x$estimate)
  se <- sqrt(1 / sum(precision))
  q <- sum(precision * (x$estimate - estimate)^2)
  tibble::tibble(
    estimate = estimate, se = se,
    lower = estimate - stats::qnorm(0.975) * se,
    upper = estimate + stats::qnorm(0.975) * se,
    k = nrow(x), n = sum(x$n_in + x$n_out),
    cces_weight = sum(weights[x$study == "CCES"]),
    q = q, q_df = nrow(x) - 1L,
    q_p = stats::pchisq(q, nrow(x) - 1L, lower.tail = FALSE)
  )
}

strength_contrasts <- function(x) {
  x <- x |>
    dplyr::filter(
      party %in% c("Democrat", "Republican"),
      !is.na(outcome), !is.na(treatment), !is.na(strong)
    ) |>
    dplyr::mutate(
      out_party = as.numeric(party != treatment),
      strong = as.numeric(strong),
      republican = as.numeric(party == "Republican")
    )
  cells <- with(x, table(out_party, strong, republican))
  stopifnot(identical(dim(cells), c(2L, 2L, 2L)), all(cells > 1))
  fit <- stats::lm(outcome ~ out_party * strong * republican, data = x)
  covariance <- sandwich::vcovHC(fit, type = "HC3")
  coefficients <- stats::coef(fit)
  other <- difference <- stats::setNames(
    rep(0, length(coefficients)), names(coefficients)
  )
  other["out_party"] <- 1
  other["out_party:republican"] <- 0.5
  difference["out_party:strong"] <- 1
  difference["out_party:strong:republican"] <- 0.5
  contrasts <- list(
    Strong = other + difference, Other = other, Difference = difference
  )
  dplyr::bind_rows(lapply(names(contrasts), function(name) {
    weights <- contrasts[[name]]
    estimate <- sum(weights * coefficients)
    se <- sqrt(drop(t(weights) %*% covariance %*% weights))
    df <- stats::df.residual(fit)
    margin <- stats::qt(0.975, df) * se
    tibble::tibble(
      contrast = name, estimate = estimate, se = se,
      lower = estimate - margin, upper = estimate + margin,
      p_value = 2 * stats::pt(-abs(estimate / se), df),
      n_strong = sum(x$strong == 1), n_other = sum(x$strong == 0),
      minimum_cell_n = min(cells)
    )
  }))
}

standardized_synthesis <- function(data, draws = 5000L, seed = 20261029L) {
  withr::local_seed(seed)
  data <- data |>
    dplyr::filter(
      party %in% c("Democrat", "Republican"),
      !is.na(treatment), !is.na(outcome)
    )
  strata <- split(data, interaction(data$study, data$party, drop = TRUE))
  estimates <- list()
  bootstrap <- list()
  for (stratum in strata) {
    ids <- unique(stratum$id)
    counts <- stats::rmultinom(
      draws, length(ids), rep(1 / length(ids), length(ids))
    )
    for (task in unique(stratum$task)) {
      x <- stratum[stratum$task == task, ]
      stopifnot(!anyDuplicated(x$id))
      arms <- lapply(c(TRUE, FALSE), function(out_party) {
        z <- x[(x$party != x$treatment) == out_party, ]
        w <- counts[match(z$id, ids), , drop = FALSE]
        n <- colSums(w)
        total <- drop(crossprod(z$outcome, w))
        squares <- drop(crossprod(z$outcome^2, w))
        list(
          n = n, mean = total / n,
          sd = sqrt(pmax(0, (squares - total^2 / n) / (n - 1))),
          original_n = nrow(z), original_mean = mean(z$outcome),
          original_sd = stats::sd(z$outcome)
        )
      })
      out <- arms[[1]]
      own <- arms[[2]]
      original <- metafor::escalc(
        measure = "SMD", m1i = out$original_mean, m2i = own$original_mean,
        sd1i = out$original_sd, sd2i = own$original_sd,
        n1i = out$original_n, n2i = own$original_n
      )
      draws_g <- metafor::escalc(
        measure = "SMD", m1i = out$mean, m2i = own$mean,
        sd1i = out$sd, sd2i = own$sd, n1i = out$n, n2i = own$n
      )$yi
      stopifnot(all(is.finite(draws_g)))
      key <- paste(x$study[1], task, x$party[1], sep = "_")
      estimates[[key]] <- tibble::tibble(
        key = key, study = x$study[1], task = task, party = x$party[1],
        estimate = as.numeric(original$yi),
        n_out = out$original_n, n_in = own$original_n
      )
      bootstrap[[key]] <- draws_g
    }
  }
  estimates <- dplyr::bind_rows(estimates)
  bootstrap <- do.call(cbind, bootstrap)
  covariance <- stats::cov(bootstrap)
  independent <- outer(estimates$study, estimates$study, "!=") |
    outer(estimates$party, estimates$party, "!=")
  covariance[independent] <- 0
  estimates$se <- sqrt(diag(covariance))
  estimates$lower <- estimates$estimate - stats::qnorm(0.975) * estimates$se
  estimates$upper <- estimates$estimate + stats::qnorm(0.975) * estimates$se
  pooled <- dplyr::bind_rows(lapply(
    c("All partisans", "Democrat", "Republican"), function(group) {
      use <- if (group == "All partisans") {
        rep(TRUE, nrow(estimates))
      } else {
        estimates$party == group
      }
      v <- covariance[use, use, drop = FALSE]
      fit <- metafor::rma.mv(estimates$estimate[use], V = v)
      weights <- drop(solve(v, rep(1, sum(use))))
      weights <- weights / sum(weights)
      tibble::tibble(
        group = group, estimate = as.numeric(fit$b), se = fit$se,
        lower = fit$ci.lb, upper = fit$ci.ub,
        k = sum(use),
        cces_weight = sum(weights[estimates$study[use] == "CCES"]),
        q = fit$QE, q_p = fit$QEp, draws = draws, seed = seed
      )
    }
  ))
  list(estimates = estimates, covariance = covariance, pooled = pooled)
}
