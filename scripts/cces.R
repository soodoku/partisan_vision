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

# hidden republicans among ind. to interpret

parking <- cces %>% 
  group_by(pid3lean, UCMParking_split) %>%
  filter(!is.na(UCMParking_split)) %>%
  filter(pid3lean != "            ") %>%
  summarize(avg = mean(as.numeric(UCMParking), na.rm = T),
            med = median(as.numeric(UCMParking), na.rm = T),
            n = n(),
            std_error = se(as.numeric(UCMParking)))

cust_theme <- theme_minimal() +
  theme(panel.grid.major   = element_line(color="#e7e7e7",  linetype = "dotted"),
    panel.grid.minor =  element_blank(),
    legend.position  = "none",
    axis.title   = element_text(size = 10, color = "#555555"),
    axis.text    = element_text(size = 8, color = "#555555"),
    axis.ticks.y = element_blank(),
    axis.title.x = element_text(vjust = -1),
    axis.title.y = element_text(vjust = 1),
    axis.ticks.x = element_line(color = "#e7e7e7",  linetype = "dotted", size = .2),
    plot.margin = unit(c(0, 1, .5, .5), "cm"))

ggplot(parking, aes(x=pid3lean, y=avg, fill=UCMParking_split)) + 
    geom_bar(position=position_dodge(), stat="identity") +
    geom_errorbar(aes(ymin=avg-std_error, ymax=avg+std_error), width=.2, position=position_dodge(.9)) + 
    cust_theme
ggsave(file = "figs/parking.pdf")

ggplot(error, aes(x=pid3lean, y=avg, fill=Error_split)) + 
    geom_bar(position=position_dodge(), stat="identity") +
    geom_errorbar(aes(ymin=avg-std_error, ymax=avg+std_error), width=.2, position=position_dodge(.9)) + 
    cust_theme
ggsave(file = "figs/error.pdf")



print(
    xtable(error,
         digits = 1,
         caption = "Average Number of Errors", 
         label = "tab:error_sum"), 
      include.rownames = FALSE,
      include.colnames = TRUE, 
      floating = TRUE,
      type = "latex", 
      caption.placement = "top",
      table.placement = "!htb",
      file = "tabs/error_sum.tex")

print(
    xtable(parking,
         digits = 1,
         caption = "Average Number of Errors", 
         label = "tab:parking_sum"), 
      include.rownames = FALSE,
      include.colnames = TRUE, 
      floating = TRUE,
      type = "latex", 
      caption.placement = "top",
      table.placement = "!htb",
      file = "tabs/parking_sum.tex")


