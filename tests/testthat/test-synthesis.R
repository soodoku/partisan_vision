source(file.path("..", "..", "R", "synthesis.R"))

testthat::test_that("writing synthesis agrees with precision arithmetic", {
  x <- data.frame(
    study = c("CCES", "Lucid"), estimate = c(1, 3), se = c(1, 2),
    n_in = c(20, 30), n_out = c(20, 30)
  )
  result <- pool_effects(x)
  testthat::expect_equal(result$estimate, 1.4)
  testthat::expect_equal(result$se, sqrt(0.8))
  testthat::expect_equal(result$cces_weight, 0.8)
})

testthat::test_that("strength interaction gives parties equal weight", {
  x <- expand.grid(
    party = c("Democrat", "Republican"), out_party = 0:1,
    strong = c(FALSE, TRUE), noise = -2:2
  )
  r <- as.numeric(x$party == "Republican")
  x$treatment <- ifelse(
    x$out_party == 0, as.character(x$party),
    ifelse(r == 1, "Democrat", "Republican")
  )
  x$outcome <- 5 + 3 * r + x$out_party * (1 + 0.5 * r) +
    3 * x$strong + x$out_party * x$strong * (2 - r) + x$noise
  result <- strength_contrasts(x)
  testthat::expect_equal(result$estimate, c(2.75, 1.25, 1.5))
  testthat::expect_equal(result$se[result$contrast == "Difference"], sqrt(1.25))
  testthat::expect_equal(result$n_strong, rep(20L, 3))
})

testthat::test_that("respondent bootstrap retains dependence across tasks", {
  x <- expand.grid(party = c("Democrat", "Republican"), person = 1:100)
  x$id <- paste(x$party, x$person)
  x$study <- "CCES"
  x$task <- "Writing"
  x$treatment <- ifelse(x$person %% 2 == 0, "Democrat", "Republican")
  x$outcome <- (x$person %% 7) + 0.4 * as.numeric(x$party != x$treatment)
  parking <- x
  parking$task <- "Parking"
  parking$outcome <- 2 * x$outcome
  data <- rbind(x, parking)
  # A small independent perturbation prevents a singular covariance matrix.
  data$outcome[data$task == "Parking"] <-
    data$outcome[data$task == "Parking"] +
    (data$person[data$task == "Parking"] %% 3)
  result <- standardized_synthesis(data, draws = 300L, seed = 42L)
  v <- result$covariance
  testthat::expect_gt(
    stats::cov2cor(v)["CCES_Writing_Democrat", "CCES_Parking_Democrat"], 0.8
  )
  testthat::expect_equal(
    v["CCES_Writing_Democrat", "CCES_Writing_Republican"], 0
  )
  weights <- drop(solve(v, rep(1, nrow(v))))
  expected <- sum(weights * result$estimates$estimate) / sum(weights)
  testthat::expect_equal(result$pooled$estimate[1], expected)
  testthat::expect_equal(result$pooled$se[1], sqrt(1 / sum(weights)))
  for (group in result$pooled$group) {
    means <- result$pooled_means[result$pooled_means$group == group, ]
    gap <- means$estimate[means$cue == "Out-party cue"] -
      means$estimate[means$cue == "In-party cue"]
    testthat::expect_equal(
      gap, result$pooled$estimate[result$pooled$group == group]
    )
    testthat::expect_true(all(means$se > 0))
  }
  for (key in result$estimates$key) {
    means <- result$means[result$means$key == key, ]
    gap <- means$estimate[means$cue == "Out-party cue"] -
      means$estimate[means$cue == "In-party cue"]
    testthat::expect_equal(
      gap, result$estimates$estimate[result$estimates$key == key]
    )
  }
})
