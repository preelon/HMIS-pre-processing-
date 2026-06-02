#This script is prepared to unify multi year service, disease and report
# quality data into a unified version

rm(list=ls())

#libraries
library(tidyverse)
library(lubridate)

# loading the required date
# 1.1  reading multi year service data
service_2012 <- read_csv("data/raw/Jan 2020-Mar 2026-woreda-dashboard/service dat/2012s.csv") |>
  filter(!is.na(woreda))

 service_2013 <- read_csv("data/raw/Jan 2020-Mar 2026-woreda-dashboard/service dat/2013s.csv") |>
  filter(!is.na(woreda))

service_2014 <- read_csv("data/raw/Jan 2020-Mar 2026-woreda-dashboard/service dat/2014s.csv") |>
  filter(!is.na(woreda))

service_2015 <- read_csv("data/raw/Jan 2020-Mar 2026-woreda-dashboard/service dat/2015s.csv") |>
  filter(!is.na(woreda))

service_2016 <- read_csv("data/raw/Jan 2020-Mar 2026-woreda-dashboard/service dat/2016s.csv") |>
  filter(!is.na(woreda))

service_2017 <- read_csv("data/raw/Jan 2020-Mar 2026-woreda-dashboard/service dat/2017s.csv") |>
  filter(!is.na(woreda))

service_2018 <- read_csv("data/raw/Jan 2020-Mar 2026-woreda-dashboard/service dat/2018s.csv") |>
  filter(!is.na(woreda))

# binding the service data into one
service_dat <- bind_rows(service_2012, service_2013, service_2014, service_2015,
                         service_2016, service_2017, service_2018)

# saving the unified service data
saveRDS(service_dat, "data/raw/Jan 2020-Mar 2026-woreda-dashboard/service_dat_2020_to_mar_2026.rds")


# 1.2  reading multi-year disease data
disease_2012 <- read_csv("data/raw/Jan 2020-Mar 2026-woreda-dashboard/disease dat/2012d.csv") |>
  filter(!is.na(woreda))

disease_2013 <- read_csv("data/raw/Jan 2020-Mar 2026-woreda-dashboard/disease dat/2013d.csv") |>
  filter(!is.na(woreda))

disease_2014 <- read_csv("data/raw/Jan 2020-Mar 2026-woreda-dashboard/disease dat/2014d.csv") |>
  filter(!is.na(woreda))

disease_2015 <- read_csv("data/raw/Jan 2020-Mar 2026-woreda-dashboard/disease dat/2015d.csv") |>
  filter(!is.na(woreda))

disease_2016 <- read_csv("data/raw/Jan 2020-Mar 2026-woreda-dashboard/disease dat/2016d.csv") |>
  filter(!is.na(woreda))

disease_2017 <- read_csv("data/raw/Jan 2020-Mar 2026-woreda-dashboard/disease dat/2017d.csv") |>
  filter(!is.na(woreda))

disease_2018 <- read_csv("data/raw/Jan 2020-Mar 2026-woreda-dashboard/disease dat/2018d.csv") |>
  filter(!is.na(woreda))


# binding the disease data into one
disease_dat <- bind_rows(disease_2012, disease_2013, disease_2014, disease_2015,
                         disease_2016, disease_2017, disease_2018)

# saving the unified disease data
saveRDS(disease_dat, "data/raw/Jan 2020-Mar 2026-woreda-dashboard/disease_dat_2020_to_mar_2026.rds")

# 1.2  reading multi-year report data
report_2012 <- read_csv("data/raw/Jan 2020-Mar 2026-woreda-dashboard/report dat/2012r.csv") |>
  filter(!is.na(woreda))

report_2013 <- read_csv("data/raw/Jan 2020-Mar 2026-woreda-dashboard/report dat/2013r.csv") |>
  filter(!is.na(woreda))

report_2014 <- read_csv("data/raw/Jan 2020-Mar 2026-woreda-dashboard/report dat/2014r.csv") |>
  filter(!is.na(woreda))

report_2015 <- read_csv("data/raw/Jan 2020-Mar 2026-woreda-dashboard/report dat/2015r.csv") |>
  filter(!is.na(woreda))

report_2016 <- read_csv("data/raw/Jan 2020-Mar 2026-woreda-dashboard/report dat/2016r.csv") |>
  filter(!is.na(woreda))

report_2017 <- read_csv("data/raw/Jan 2020-Mar 2026-woreda-dashboard/report dat/2017r.csv") |>
  filter(!is.na(woreda))

report_2018 <- read_csv("data/raw/Jan 2020-Mar 2026-woreda-dashboard/report dat/2018r.csv") |>
  filter(!is.na(woreda))


# binding the report quality data into one
report_dat <- bind_rows(report_2012, report_2013, report_2014, report_2015,
                        report_2016, report_2017, report_2018)


# saving the unified report quality data
saveRDS(report_dat, "data/raw/Jan 2020-Mar 2026-woreda-dashboard/report_quality_dat_2020_to_mar_2026.rds")

# -----------------------------END------------------------------------