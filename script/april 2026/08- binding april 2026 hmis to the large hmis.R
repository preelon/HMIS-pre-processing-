# this script is prepared to bind the previously cleaned 7 years hmis to 
# the april 2026 hhmis

rm(list = ls())

#libraries
library(tidyverse)
library(lubridate)

# reading the required dataset
# 1. readinng the 7 year cleaned hmis
hmis_large <- readRDS("data/processed/jan 2020-mar 2026/clean_hmis_2020_2026.rds")

# 2. read the cleaned april 2026 hmis
hmis_apr_2026 <- readRDS("data/processed/april 2026/clean_apr_2026.rds")

# binding the two dats
binded_hmis <- bind_rows(hmis_large, hmis_apr_2026)

# saving the binded dataset for app use
saveRDS(binded_hmis, "data/processed/april 2026/upto_apr_2026_hmis_for_app.rds")
