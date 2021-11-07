# Pareto Party

# set dir.
setwd(dropboxdir)
setwd("pareto_party/")
# Load libs
library(tidyverse)
library(readstata13)
library(car)
library(dplyr)
library(xtable)

# Read in data
cces <- foreign::read.spss("data/cces/UCM_CES2020_Unweighted_Data.sav", to.data.frame = T)

cces %>% group_by(pid3lean, Error_split) %>%summarize(mean(as.numeric(AGTErrors), na.rm = T))
cces %>% group_by(pid3lean, Error_split) %>%summarize(median(as.numeric(AGTErrors), na.rm = T))
cces %>% group_by(pid3lean, UCMParking_split) %>%summarize(mean(as.numeric(UCMParking), na.rm = T))
cces %>% group_by(pid3lean, UCMParking_split) %>%summarize(median(as.numeric(UCMParking), na.rm = T))

Name:          UCMParking_split
Description:   Parking lot condition
         
          Count   Code   Label
          -----   ----   -----
            160     -1   No Data
            423      1   Democratic Party
            417      2   Republican Party
#Name:          Error_split
#Description:   Error text        
#         Count   Code   Label
#          -----   ----   -----
#            506      1   DEM
#            494      2   REP

Name:          UCMParking
Description:   Bad park job
         
               Numeric Variable - no categories
         
               answered       : 840
               No Data        : 160

Name:          AGTErrors
Description:   Error count
         
               Numeric Variable - no categories
         
               answered       : 999
               skipped        : 1

