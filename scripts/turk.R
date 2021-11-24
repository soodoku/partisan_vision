# Partisan Vision

# set dir.
setwd(githubdir)
setwd("partisan_vision/")
# Load libs
library(tidyverse)
library(car)
library(dplyr)
library(xtable)
library(readr)

## Load data
turk <- read_csv("turk_06_29_2020/merged_survey_ip_06_29_2020_final.csv")

# Drop people who didn't finish
# turk <- turk %>% filter(!is.na(sincerity))

# Rename
rename wedliketounderstandhowyouthinkva self_econ
rename v31 self_unemployment
rename v32 self_inflation

# 7-point party ID
gen pid7 = .
replace pid7 = 1 if pid_dem == "1"
replace pid7 = 2 if pid_dem == "2"
replace pid7 = 3 if pid_ind == "2"
replace pid7 = 4 if pid_ind == "3"
replace pid7 = 5 if pid_ind == "1"
replace pid7 = 6 if pid_rep == "2"
replace pid7 = 7 if pid_rep == "1"	
label define pid7_lbl 1 "Strong Democrat" 2 "Weak Democrat" 3 "Leaning Democrat" 4 "Independent" 5 "Leaning Republican" 6 "Weak Republican" 7 "Strong Republican", replace
label values pid7 pid7_lbl

*3-point party ID
recode pid7 (1/3=1)(4=2)(5/7=3), gen(pid3)
label define pid3_lbl 1 "Democratic" 2 "Independent" 3 "Republican", replace
label values pid3 pid3_lbl

*Democratic dummy for comparing Dems and Reps
gen dem_rep = .
replace dem_rep = 1 if pid3 == 1
replace dem_rep = 0 if pid3 == 3
label define dem_rep_lbl 0 "Republican" 1 "Democrat", replace
label values dem_rep dem_rep_lbl

***********************
**CODING FOR TROLLING**
***********************
	
*low-incidence screeners

destring sleep prosthetic blind deaf gang_resp gang_fam, replace

gen troll_sleep=0
replace troll_sleep=1 if sleep=="1"|sleep=="5"
tab troll_sleep

gen troll_prosthetic=1 if prosthetic=="TRUE"
replace troll_prosthetic=0 if prosthetic=="FALSE"
tab troll_prosthetic

gen troll_blind=1 if blind=="TRUE"
replace troll_blind=0 if blind=="FALSE"
tab troll_blind

gen troll_deaf=1 if deaf=="TRUE"
replace troll_deaf=0 if deaf=="FALSE"
tab troll_deaf

gen troll_gang=1 if gang_resp=="TRUE"
replace troll_gang=0 if gang_resp=="FALSE"
tab troll_gang

gen troll_famgang=1 if gang_fam=="TRUE"
replace troll_famgang=0 if gang_fam=="FALSE"
tab troll_famgang

tab troll_sleep 

egen troll_index = rowtotal(troll_sleep troll_prosthetic troll_blind troll_deaf troll_gang troll_famgang)
gen troll = 0
replace troll = 1 if troll_index > 1
	tab troll
*30.07 % of the sample is marked as a troll

*how many people self-report as providing insincere responses?
destring sincerity, replace
tab sincerity
recode sincerity (1/3 = 0) (4/5 = 1), gen(insincere)
tab insincere
*14.37% admit to responding non-seriously 

*correlation between answering sincerely and troll index
corr troll_index sincerity
tab insincere troll, col chi

***********************
**CODING FOR BAD IPs**
***********************

tab blacklisted
*6.72% show up on a blacklist

tab missing_ip
*no missing IPs

tab duplicated
*5.39% are duplicated

tab foreign_ip
*1.13% are foreign IPs
gen foreign_ip_corrected=1 if foreign_ip=="TRUE"
replace foreign_ip_corrected=0 if foreign_ip=="FALSE"
tab foreign_ip_corrected

**********
***DATE***
**********
		
gen date_ok=0
replace date_ok=1 if date=="06 29 2020"|date=="06.29.2020"|date=="06\29\2020"|date=="06\30\2020" ///
	|date=="6/29/20"|date=="6/29/2020."|date=="6/29/20209"|date=="6/29/2020`"|date=="60/29/2020" ///
	|date=="ju/26/2020"|date=="june/29/20"|date=="o6/29/2020" | date=="16/29/2020"
tab date_ok
*so 24.82% of respondents entered the date incorrectly

*okay, what about those who wrote DD/MM/YYYY
gen date_poss_foreign = 0
replace date_poss_foreign = 1 if date == "20/06/2020" | date == "28.06.2020" | date == "28/06/2020" | date == "28/6/2020" ///
	|date == " 29 06 2020" | date ==  "29-06-2020" | date == "29-Jun-20" | date == "29.06 2020" | date == "29.06.2020" ///
	|date == "29/06/2020"| date == "29/6/2020" | date == " 29/6/2020." | date == "29\06\2020" | date == "29|06|2020" ///
	|date == "30/06/2020"
tab date_poss_foreign 
*geez, 20.03% of the sample is possibly comprised of foreigners

*okay, how many people wrote a nonsensical response to the date question?
gen inattentive = 1
replace inattentive = 0 if date_ok==1|date_poss_foreign==1
tab inattentive
*4.79%

* Plotting time to completion against writing date/foreign IP
twoway kdensity duration if date_ok == 1 || kdensity duration if date_ok == 0, ///
	ytitle("Density") xt("Survey duration, in seconds") /// 
	xline(900, lc(black) lp(dot)) ///
	text(0.00195 1600 "Target time = 15 minutes") ///
	legend(label(1 "Date formatted MM/DD/YYYY") label(2 "Date formatted otherwise"))
ksmirnov durationinseconds, by(date_ok)

************************************************************
***CREATING UPPER AND LOWER BOUND ESTIMATES OF BAD ACTORS***
************************************************************

*creating a variable that combines trolling and weird IPs ("lower bound")
gen combined_troll_1=.
replace combined_troll_1 = 1 if funny_ip == "TRUE" | troll == 1
replace combined_troll_1 = 0 if funny_ip == "FALSE" & troll == 0
tab combined_troll_1
*okay, so 37.99% of data is suspicious using this measure

*creating a variable that combines trolling, weird IP, and weirdly written date 
gen combined_troll_2=.
replace combined_troll_2=1 if funny_ip=="TRUE" |troll==1|date_poss_foreign==1
replace combined_troll_2=0 if funny_ip=="FALSE" & troll==0 & date_poss_foreign==0
tab combined_troll_2
*44.64% of respondents are suspicious using this measure

*creating a variable that combines trolling, weird IP, weirdly written date, or inattentive (nonsensical date write-in)
gen combined_troll_3=.
replace combined_troll_3=1 if funny_ip=="TRUE" |troll==1|date_poss_foreign==1|inattentive==1
replace combined_troll_3=0 if funny_ip=="FALSE"  & troll==0 & date_poss_foreign==0 & inattentive==0
tab combined_troll_3
*46.17% marked as suspicious here


