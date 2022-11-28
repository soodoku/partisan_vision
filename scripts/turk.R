# Partisan Vision

# set dir.
setwd(githubdir)
setwd("partisan_vision/")
# Load libs
library(tidyverse)
library(knitr)
library(readr)
library(magrittr)
library(boot)

## Load data
turk_1 <- read_csv("data/turk/merged_survey_ip_06_29_2020_final.csv")
turk_2 <- read_csv("data/turk/merged_survey_ip_07_12_2020_final.csv")

turk_1_sub <- turk_1[, c("pid_3...Selected.Choice", "pid_dem", "pid_ind", "pid_rep", "trump_masks", "sincerity")]
turk_2_sub <- turk_2[, c("pid_3...Selected.Choice", "pid_dem", "pid_ind", "pid_rep", "trump_masks", "sincerity")]

turk <- rbind(turk_1_sub, turk_2_sub)

# Recode PID
turk %<>% 
  mutate(pid7 = case_when(
  pid_dem == 1 ~ 1,
  pid_dem == 2 ~ 2,
  pid_ind == 2 ~ 3,
  pid_ind == 3 ~ 4,
  pid_ind == 1 ~ 5,
  pid_rep == 2 ~ 6,
  pid_rep == 1 ~ 7
))

turk %<>% mutate(pid_dem_l = case_when(pid7 %in% c(1, 2, 3) ~ "democrat",
                                       pid7 %in% c(5, 6, 7) ~ "republican",
                                       pid7 %in% (4) ~ "independent")) 


medianFunc <- function(x,i){median(x[i])}

masks <- turk %>% 
  group_by(pid_dem_l) %>% 
  filter(!is.na(pid_dem_l)) %>%
  summarize(p_25 = quantile(trump_masks, probs = .25, na.rm = T), 
            p_50 = quantile(trump_masks, probs = .25, na.rm = T), 
            p_75 = quantile(trump_masks, probs = .75, na.rm = T), 
            n = n(), 
            std_error = medianFunc(as.numeric(trump_masks)))

# See if filtering on sincere respondents changes anything --- NO

# Drop people who didn't finish
turk_sincere <- turk %>% 
  filter(!is.na(sincerity) & sincerity > 2)

masks_sincere <- turk_sincere %>% 
  group_by(pid_dem_l) %>% 
  summarize(p_25 = quantile(trump_masks, probs = .25, na.rm = T), 
            p_50 = quantile(trump_masks, probs = .25, na.rm = T), 
            p_75 = quantile(trump_masks, probs = .75, na.rm = T), 
            n = n(),
            std_error = medianFunc(as.numeric(trump_masks)))

print(
  xtable(masks,
         digits = 1,
         caption = "Number of People Wearing Masks", 
         label = "tab:trump_sum"), 
  include.rownames = FALSE,
  include.colnames = TRUE, 
  floating = TRUE,
  type = "latex", 
  caption.placement = "top",
  table.placement = "!htb",
  file = "tabs/masks_sum.tex")

kable(masks)
