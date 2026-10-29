read_cces <- function(weighted = FALSE) {
  file <- if (weighted) "Weighted" else "Unweighted"
  x <- haven::read_sav(paste0("data/cces/UCM_CES2020_", file, "_Data.sav"))
  stopifnot(!anyDuplicated(x$caseid))
  make_task <- function(outcome, assignment, task) {
    tibble::tibble(
      id = as.character(x$caseid), study = "CCES", task = task,
      party = trimws(x$pid3lean),
      treatment = c("Democrat", "Republican")[as.integer(x[[assignment]])],
      outcome = as.numeric(x[[outcome]]),
      weight = if (weighted) as.numeric(x$teamweight) else 1
    )
  }
  dplyr::bind_rows(
    make_task("AGTErrors", "Error_split", "Writing"),
    make_task("UCMParking", "UCMParking_split", "Parking")
  )
}

read_lucid <- function() {
  x <- readr::read_csv(Sys.glob("data/lucid/*.zip"),
    col_types = readr::cols(.default = "c"), show_col_types = FALSE
  )
  x <- x |>
    dplyr::filter(
      consent == "Yes", DistributionChannel != "preview",
      attn_check == "Extremely interested,Very interested"
    )
  stopifnot(!anyDuplicated(x$ResponseId))
  tibble::tibble(
    id = x$ResponseId, study = "Lucid", task = "Writing",
    party = lucid_party(x$political_party),
    treatment = dplyr::recode(x$edit_cond, d = "Democrat", r = "Republican"),
    outcome = as.numeric(ifelse(x$edit_cond == "d", x$edit_dems, x$edit_reps)),
    weight = 1
  )
}

read_turk <- function() {
  files <- Sys.glob("data/turk/*.csv")
  x <- dplyr::bind_rows(lapply(files, function(file) {
    x <- readr::read_csv(file, col_types = readr::cols(.default = "c"))
    x$wave <- basename(file)
    x
  }))
  stopifnot(!anyDuplicated(x$Response.ID))
  tibble::tibble(
    id = x$Response.ID, wave = x$wave, ip = x$ip,
    party = dplyr::case_when(
      x$pid_dem %in% c("1", "2") | x$pid_ind == "2" ~ "Democrat",
      x$pid_rep %in% c("1", "2") | x$pid_ind == "1" ~ "Republican",
      x$pid_ind == "3" ~ "Independent"
    ),
    sincerity = as.numeric(x$sincerity), outcome = as.numeric(x$trump_masks)
  )
}

lucid_party <- function(code) {
  code <- as.integer(code)
  stopifnot(all(is.na(code) | code %in% 1:10))
  dplyr::case_when(
    code %in% c(1, 2, 3, 6) ~ "Democrat",
    code %in% c(5, 8, 9, 10) ~ "Republican",
    code %in% c(4, 7) ~ "Independent"
  )
}
