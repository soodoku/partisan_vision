# Partisan Vision

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
            p_50 = quantile(trump_masks, probs = .50, na.rm = T), 
            p_75 = quantile(trump_masks, probs = .75, na.rm = T), 
            n = n(), 
            std_error = sd(as.numeric(trump_masks))/sqrt(n()))

# See if filtering on sincere respondents changes anything --- NO

summary(turk$trump_masks)
quantile(turk$trump_masks, probs = seq(.1, .9, by = .1), na.rm = T)

# Drop people who didn't finish
turk_sincere <- turk %>% 
  filter(!is.na(sincerity) & sincerity > 2) %>%
  mutate(trump_masks_r = case_when(
    trump_masks >= 15 ~ 15,
    TRUE ~ trump_masks
  ))

masks_sincere <- turk_sincere %>% 
  group_by(pid_dem_l) %>% 
  summarize(p_25 = quantile(trump_masks_r, probs = .25, na.rm = T), 
            p_50 = quantile(trump_masks_r, probs = .50, na.rm = T), 
            p_75 = quantile(trump_masks_r, probs = .75, na.rm = T), 
            n = n(),
            mean = mean(trump_masks_r, na.rm = T),
            std_error = round(sd(as.numeric(trump_masks_r))/sqrt(n()), 1))

print(
  xtable(masks_sincere,
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

kable(masks_sincere)
