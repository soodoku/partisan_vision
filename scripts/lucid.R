# Load libs
library(tidyverse)
library(readr)

# Load dat
uncert <- read_csv("data/lucid/Uncertainty+Effect+replication_January+28,+2023_20.38.zip")

# Filter attn_check
uncert$attn_checkc <- uncert$attn_check == "Extremely interested,Very interested"

# Filter those who consent and not preview and pass the attn check
fin_dat <- uncert[uncert$consent == 'Yes' & uncert$DistributionChannel != "preview" & uncert$attn_checkc, ]

# PID 
fin_dat$dem <- fin_dat$political_party %in% c("1", "2", "3", "6")
fin_dat$rep <- fin_dat$political_party %in% c("5", "8", "9", "10")
fin_dat$dem[fin_dat$rep == FALSE & fin_dat$dem == FALSE] <- NA
fin_dat$rep[fin_dat$rep == FALSE & fin_dat$dem == FALSE] <- NA

fin_dat <- fin_dat %>%
  mutate(pid3 = case_when(
   political_party %in% c("1", "2", "3", "6") ~ "dem",
   political_party %in% c("5", "8", "9", "10") ~ "rep",
   political_party %in% c("4", "7") ~ "ind"
  ))

# Mistakes

fin_dat <- fin_dat %>%
  mutate(mistakes = case_when(
    edit_cond == "r" ~ as.numeric(fin_dat$edit_reps),
    edit_cond == "d" ~ as.numeric(fin_dat$edit_dems)
  ))

### Take out anything over 20/winsorize
fin_dat <- fin_dat %>% 
  mutate(mistakes_r = case_when(
    mistakes >= 20 ~ 20,
    TRUE ~ mistakes
  ))

### Congeniality
fin_dat <- fin_dat %>%
  mutate(edit_cong = case_when(
    pid3 == "dem" & edit_cond == "d" ~ 1,
    pid3 == "rep" & edit_cond == "r" ~ 1,
    TRUE ~ 0
  ))

### Analysis

fin_dat %>% 
  group_by(edit_cong) %>%
  summarize(mean_mis = mean(mistakes), med_mis = median(mistakes))

summary(lm(mistakes ~ edit_cong, data = fin_dat[fin_dat$pid3 != "ind", ]))
summary(lm(mistakes_r ~ edit_cong, data = fin_dat[fin_dat$pid3 != "ind", ]))

