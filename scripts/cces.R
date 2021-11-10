# Partisan Vision

# set dir.
setwd(githubdir)
setwd("partisan_vision/")
# Load libs
library(tidyverse)
library(car)
library(dplyr)
library(xtable)

# Read in data
cces <- foreign::read.spss("data/UCM_CES2020_Unweighted_Data.sav", to.data.frame = T)

cces %>% 
  group_by(pid3lean, Error_split) %>%
  filter(pid3lean != "            ") %>%
  summarize(avg = mean(as.numeric(AGTErrors), na.rm = T), med = median(as.numeric(AGTErrors), na.rm = T), n = n())

cces %>% 
  group_by(pid3lean, UCMParking_split) %>%
  filter(!is.na(UCMParking_split)) %>%
  filter(pid3lean != "            ") %>%
  summarize(avg = mean(as.numeric(UCMParking), na.rm = T), med = median(as.numeric(UCMParking), na.rm = T), n = n())
