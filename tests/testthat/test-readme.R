source(file.path("..", "..", "R", "output.R"))

testthat::test_that("README regeneration preserves Adjacent recommendations", {
  directory <- withr::local_tempdir()
  template <- file.path(directory, "template.md")
  path <- file.path(directory, "readme.md")
  block <- c(
    "<!-- adjacent:start -->", "Related repository", "<!-- adjacent:end -->"
  )
  writeLines(c("Title", "RESULTS"), template)
  writeLines(c("Old results", "", block), path)
  write_readme("Updated results", template, path)
  testthat::expect_identical(
    readLines(path), c("Title", "Updated results", "", block)
  )
  write_readme("Updated results", template, path)
  testthat::expect_identical(
    readLines(path), c("Title", "Updated results", "", block)
  )
})

testthat::test_that("malformed markers cannot erase existing README content", {
  directory <- withr::local_tempdir()
  template <- file.path(directory, "template.md")
  path <- file.path(directory, "readme.md")
  writeLines("RESULTS", template)
  writeLines("Existing content", path)
  testthat::expect_error(
    write_readme("New", template, path), "Adjacent markers"
  )
  testthat::expect_identical(readLines(path), "Existing content")
})
