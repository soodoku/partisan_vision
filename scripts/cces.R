# Partisan Vision

# set dir.
setwd(githubdir)
setwd("partisan_vision/")
# Load libs
library(tidyverse)
library(car)
library(dplyr)
library(xtable)
library(ggplot2)

# se
se <- function(x) sd(x, na.rm = T)/sqrt(length(x[!is.na(x)]))

# Read in data
cces <- foreign::read.spss("data/cces/UCM_CES2020_Unweighted_Data.sav", to.data.frame = T)

error <- cces %>% 
  group_by(pid3lean, Error_split) %>%
  filter(pid3lean != "            ") %>%
  summarize(avg = mean(as.numeric(AGTErrors), na.rm = T), 
            med = median(as.numeric(AGTErrors), na.rm = T), 
            n = n(),
            std_error = se(as.numeric(AGTErrors)))

parking <- cces %>% 
  group_by(pid3lean, UCMParking_split) %>%
  filter(!is.na(UCMParking_split)) %>%
  filter(pid3lean != "            ") %>%
  summarize(avg = mean(as.numeric(UCMParking), na.rm = T),
            med = median(as.numeric(UCMParking), na.rm = T),
            n = n(),
            std_error = se(as.numeric(AGTErrors)))

print(
    xtable(error,
         digits = 1,
         caption = "Average Number of Errors", 
         label = "tab:error_sum"), 
      include.rownames = FALSE,
      include.colnames = TRUE, 
      floating = TRUE,
      type = "latex", 
      caption.placement = "bottom",
      table.placement = "!htb",
      file = "tabs/error_sum.tex")

print(
    xtable(parking,
         digits = 1,
         caption = "Average Number of Errors", 
         label = "tab:error_sum"), 
      include.rownames = FALSE,
      include.colnames = TRUE, 
      floating = TRUE,
      type = "latex", 
      caption.placement = "bottom",
      table.placement = "!htb",
      file = "tabs/parking_sum.tex")


