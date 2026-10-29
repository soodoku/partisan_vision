source(file.path("..", "..", "R", "data.R"))
source(file.path("..", "..", "R", "analysis.R"))

testthat::test_that("summaries count observed outcomes and preserve zeros", {
  x <- summarize_outcome(c(0, 2, NA_real_))
  testthat::expect_equal(x$n, 2L)
  testthat::expect_equal(x$missing, 1L)
  testthat::expect_equal(x$mean, 1)
  testthat::expect_equal(x$se, 1)
})

testthat::test_that("Welch contrast agrees with independent arithmetic", {
  x <- c(0, 1, 3, 7)
  y <- c(1, 2, 3)
  result <- mean_contrast(x, y)
  a <- var(x) / length(x)
  b <- var(y) / length(y)
  df <- (a + b)^2 / (a^2 / (length(x) - 1) + b^2 / (length(y) - 1))
  testthat::expect_equal(result$estimate, mean(x) - mean(y))
  testthat::expect_equal(
    result$lower,
    mean(x) - mean(y) - qt(0.975, df) * sqrt(a + b)
  )
})

testthat::test_that("raw SPSS counts are not factor ranks", {
  withr::with_dir(file.path("..", ".."), {
    x <- read_cces()
    cell <- subset(
      x, task == "Writing" & party == "Democrat" & treatment == "Democrat"
    )
    testthat::expect_equal(nrow(cell), 334L)
    testthat::expect_equal(mean(cell$outcome), 2890 / 334)
    testthat::expect_true(any(cell$outcome == 0))
  })
})

testthat::test_that("sincerity selection retains never and rarely responses", {
  withr::with_dir(file.path("..", ".."), {
    x <- read_turk()
    x <- subset(x, sincerity %in% 1:2 & !is.na(party))
    testthat::expect_equal(sum(x$party == "Democrat"), 682L)
    testthat::expect_equal(sum(x$party == "Republican"), 514L)
    testthat::expect_false(anyDuplicated(x$id) > 0)
  })
})
