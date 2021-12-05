# Partisan Vision

# set dir.
setwd(githubdir)
setwd("partisan_vision/")
# Load libs
library(tidyverse)
library(car)
library(dplyr)
library(xtable)
library(readr)

## Load data
turk <- read_csv("data/turk/merged_survey_ip_06_29_2020_final.csv")

# Drop people who didn't finish
# turk <- turk %>% filter(!is.na(sincerity))

turk$pid_dem
turk$trump_masks
