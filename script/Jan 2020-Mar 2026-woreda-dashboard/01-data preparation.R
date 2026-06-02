# This script is prepared to change the datasets
# into long vesrion

rm(list=ls())

#libraries
library(tidyverse)
library(lubridate)

# reading the required data
# 1. disease data
df_species <- readRDS("data/raw/Jan 2020-Mar 2026-woreda-dashboard/disease_dat_2020_to_mar_2026.rds")

# 2. service data
df_service <- readRDS("data/raw/Jan 2020-Mar 2026-woreda-dashboard/service_dat_2020_to_mar_2026.rds")

# 3. report data
df_report <- readRDS("data/raw/Jan 2020-Mar 2026-woreda-dashboard/report_quality_dat_2020_to_mar_2026.rds")

# 2. changing disease data to long format
df_species_long <- df_species |>
  pivot_longer(cols = matches("ESV|B50"),
               names_to = "data_type",
               values_to = "value")


# changing the service data to long format
df_service_long <- df_service |>
  pivot_longer(cols = contains("RDT"),
               names_to = "data_type",
               values_to = "value")

# changing the report data to long format
df_report_long <- df_report |>
  pivot_longer(cols = matches("NCD|NTD"),
               names_to = "data_type",
               values_to = "value")

# Sanity check: total positives from service data
df_service_long |>
  filter(data_type== "MAL_Slides or RDT Positive")|>
  summarise(total_pos = sum(value, na.rm = T))

# add dept, outcome and facility_type dimensions to service data
df_service_long <- df_service_long |>
  mutate(department = NA_character_,
         outcome = NA_character_,
         facility_type = NA_character_)

# add dept and outcome  dimensions to report data
df_report_long <- df_report_long |>
  mutate(department = NA_character_,
         outcome = NA_character_)


# add facility_type dimension to disease data
df_species_long <- df_species_long |>
  mutate(facility_type = NA_character_)

# create a unified dataset
combined_hmis <- bind_rows(df_species_long, df_service_long, df_report_long)


# check reliability
combined_hmis |>
  filter(data_type == "MAL_Slides or RDT Positive") |>
  summarise(total_pf = sum(value,na.rm = T)) # correct


# saving the combined dataset
saveRDS(combined_hmis, "data/raw/Jan 2020-Mar 2026-woreda-dashboard/combined-hmis-jan-2020-mar-2026.rds")

x <- readRDS("data/raw/Jan 2020-Mar 2026-woreda-dashboard/combined-hmis-jan-2020-mar-2026.rds")

x |>
  filter(data_type == "MAL_Slides or RDT Positive") |>
  summarise(sum(value, na.rm = T))
