# Partisan Vision

# set dir.
setwd(githubdir)
setwd("partisan_vision/")
# Load libs
library(tidyverse)
library(knitr)
library(readr)
library(magrittr)

## Load data
turk <- read_csv("data/turk/merged_survey_ip_06_29_2020_final.csv")

# Analyze PID --- PID 7 is missing
# table(turk$pid_3...Selected.Choice)
# table(turk$pid_3...Other..please.specify....Text)

turk %<>% mutate(pid_dem_l = case_when(pid_dem == "1" ~ "democrat",
                                       pid_dem == "2" ~ "republican")) 

turk %>% 
  group_by(pid_dem_l) %>% 
  summarize(p_25 = quantile(trump_masks, probs = .25, na.rm = T), 
            p_50 = quantile(trump_masks, probs = .25, na.rm = T), 
            p_75 = quantile(trump_masks, probs = .75, na.rm = T), 
            n = n())


# See if filtering on sincere respondents changes anything --- NO

# Drop people who didn't finish
turk <- turk %>% filter(!is.na(sincerity))

turk %>% 
  group_by(pid_dem_l) %>% 
  summarize(p_25 = quantile(trump_masks, probs = .25, na.rm = T), 
            p_50 = quantile(trump_masks, probs = .25, na.rm = T), 
            p_75 = quantile(trump_masks, probs = .75, na.rm = T), 
            n = n())


