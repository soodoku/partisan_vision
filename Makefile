.PHONY: restore analysis paper lint format test check ci-docker
restore:
	Rscript --vanilla -e 'if (!requireNamespace("renv", quietly = TRUE)) install.packages("renv", repos = "https://cloud.r-project.org"); renv::load(); renv::restore(prompt = FALSE)'
analysis:
	Rscript --vanilla -e 'renv::load(); source("scripts/99_run_all.R")'
paper: analysis
	cd ms && latexmk -pdf -interaction=nonstopmode -halt-on-error partisan_vision.tex
format:
	Rscript --vanilla -e 'renv::load(); styler::cache_deactivate(); for (d in c("R", "scripts", "tests")) styler::style_dir(d)'
lint:
	Rscript --vanilla -e 'renv::load(); x <- unlist(lapply(c("R", "scripts", "tests"), lintr::lint_dir), recursive = FALSE); print(x); quit(status = as.integer(length(x) > 0))'
test: analysis
	Rscript --vanilla -e 'renv::load(); testthat::test_dir("tests/testthat", stop_on_failure = TRUE)'
check: paper lint test
ci-docker:
	docker run --rm -v "$(CURDIR):/project" -w /project rocker/verse:4.6.0 bash -c 'Rscript -e '''install.packages("renv")''' && make restore check'
