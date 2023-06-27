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
se <- function(x) sd(x, na.rm = T)/sqrt(length(x[!is.na(x)]))

fin_dat %>% 
  group_by(edit_cong) %>%
  summarize(mean_mis = mean(mistakes), 
            med_mis = median(mistakes), 
            n = n(),
            std_error = se(as.numeric(mistakes)))

error <- fin_dat %>% 
  group_by(pid3, edit_cond) %>%
  summarize(mean_mis = mean(mistakes), 
            med_mis = median(mistakes), 
            n = n(),
            std_error = se(as.numeric(mistakes)))

# Table
print(
  xtable(error,
         digits = 1,
         caption = "Average Number of Writing Errors (Lucid)", 
         label = "tab:error_sum_lucid"), 
  include.rownames = FALSE,
  include.colnames = TRUE, 
  floating = TRUE,
  type = "latex", 
  caption.placement = "top",
  table.placement = "!htb",
  file = "tabs/text_sum_lucid.tex")

# Regression
summary(lm(mistakes ~ edit_cong, data = fin_dat[fin_dat$pid3 == "dem", ]))
summary(lm(mistakes_r ~ edit_cong, data = fin_dat[fin_dat$pid3 == "dem", ]))
summary(lm(mistakes ~ edit_cong, data = fin_dat[fin_dat$pid3 == "rep", ]))
summary(lm(mistakes_r ~ edit_cong, data = fin_dat[fin_dat$pid3 == "rep", ]))

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

ggplot(error, aes(x=pid3, y=mean_mis)) + 
  geom_errorbar(
    aes(ymin=mean_mis-2*std_error, ymax=mean_mis+2*std_error, color=edit_cond),
    position = position_dodge(0.3), width = 0.1
  ) + 
  geom_point(aes(color = edit_cond), position = position_dodge(0.3)) +
  xlab(NULL) +
  ylab("Average Number of Writing Errors (Lucid)") + 
  cust_theme + 
  theme(legend.position="bottom") +
  scale_color_manual("Treatment", values = c("#33AAEE", "#EE7777"))
ggsave(file = "figs/text_lucid.pdf")
ggsave(file = "figs/text_lucid.png")

