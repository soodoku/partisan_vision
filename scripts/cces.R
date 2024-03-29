# Partisan Vision

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

# Analysis
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
            std_error = se(as.numeric(UCMParking)))
# Regressions

with(cces[cces$pid3lean == "Democrat    ", ], summary(lm(as.numeric(AGTErrors) ~ Error_split)))
with(cces[cces$pid3lean == "Democrat    ", ], summary(lm(as.numeric(UCMParking) ~ UCMParking_split)))

# Plot
cust_theme <- theme_bw() +
  theme(panel.grid.major  = element_line(color="#e7e7e7",  linetype = "dotted"),
    panel.grid.minor =  element_blank(),
    axis.title   = element_text(size = 10, color = "#555555"),
    axis.text    = element_text(size = 8, color = "#555555"),
    axis.ticks.y = element_blank(),
    axis.title.x = element_text(vjust = -1),
    axis.title.y = element_text(vjust = 1),
    axis.ticks.x = element_line(color = "#e7e7e7",  linetype = "dotted", size = .2),
    plot.margin = unit(c(0, 1, .5, .5), "cm"))

ggplot(parking, aes(x=pid3lean, y=avg)) + 
  geom_errorbar(
    aes(ymin=avg-std_error, ymax=avg+std_error, color=UCMParking_split),
    position = position_dodge(0.3), width = 0.1
  ) + 
  geom_point(aes(color = UCMParking_split), position = position_dodge(0.3)) +
  xlab(NULL) +
  ylab("Average Number of Parking Errors") + 
  cust_theme + 
  theme(legend.position="bottom") +
  scale_color_manual("Treatment", values = c("#33AAEE", "#EE7777"))
ggsave(file = "figs/parking_cces.pdf")
ggsave(file = "figs/parking_cces.png")

ggplot(error, aes(x=pid3lean, y=avg)) + 
    geom_errorbar(
      aes(ymin=avg-std_error, ymax=avg+std_error, color=Error_split),
      position = position_dodge(0.3), width = 0.1
      ) + 
    geom_point(aes(color = Error_split), position = position_dodge(0.3)) +
    xlab(NULL) +
    ylab("Average Number of Writing Errors") + 
    cust_theme + 
    theme(legend.position="bottom") +
    scale_color_manual("Treatment", values = c("#33AAEE", "#EE7777"))
ggsave(file = "figs/text_cces.pdf")
ggsave(file = "figs/text_cces.png")

# Tables
print(
    xtable(error,
         digits = 1,
         caption = "Average Number of Writing Errors (CCES)", 
         label = "tab:error_sum_cces"), 
      include.rownames = FALSE,
      include.colnames = TRUE, 
      floating = TRUE,
      type = "latex", 
      caption.placement = "top",
      table.placement = "!htb",
      file = "tabs/text_sum_cces.tex")

print(
    xtable(parking,
         digits = 1,
         caption = "Average Number of Parking Errors", 
         label = "tab:parking_sum_cces"), 
      include.rownames = FALSE,
      include.colnames = TRUE, 
      floating = TRUE,
      type = "latex", 
      caption.placement = "top",
      table.placement = "!htb",
      file = "tabs/parking_sum_cces.tex")
