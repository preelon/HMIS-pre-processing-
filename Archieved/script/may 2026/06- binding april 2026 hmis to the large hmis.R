# this script is prepared to bind the previously cleaned 7 years hmis to 
# the april 2026 hhmis

rm(list = ls())

#libraries
library(tidyverse)
library(lubridate)

# reading the required dataset
# 1. readinng the 7 year cleaned hmis
hmis_large <- readRDS("Archieved/data/processed/april 2026/upto_apr_2026_hmis_for_app.rds")

hmis_large |>
  filter(efy==2018)|>
  distinct(month_year)

# 2. read the cleaned april 2026 hmis
hmis_may_2026 <- readRDS("Archieved/data/processed/may 2026/may_2026_hmis_woreda_cleaning_completed.rds")

# binding the two dats
integrated_hmis <- bind_rows(hmis_large, hmis_may_2026)

# saving the binded dataset for the next step
saveRDS(integrated_hmis, "Archieved/data/processed/may 2026/upto_may_2026_hmis_for_app.rds")
