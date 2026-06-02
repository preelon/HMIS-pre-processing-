# This script is prepared to change the datasets
# into long vesrion

rm(list=ls())

#libraries
library(tidyverse)
library(lubridate)

# reading the required data
# 1. disease data
df_species <- read_csv("data/raw/April 2026 hmis/disease_dat_april2026.csv")

# 2. service data
df_service <- read_csv("data/raw/April 2026 hmis/service_dat_april2026.csv")

# 3. report data
df_report <- read_csv("data/raw/April 2026 hmis/report_dat_april2026.csv")

# -------------------------------------------------------------------
# 1. standardizing the names of the variable names in the df_species and 
#keeping only cols we need for the work
df_species <- df_species |>
  rename(period = periodname,
         region = orgunitlevel2,
         zone= orgunitlevel3,
         woreda= orgunitlevel4)

# renaming a column with IPD/OPD observations to department
dept_col <- names(df_species)[sapply(df_species, function(x) {
  any(as.character(x) %in% c("IPD", "OPD"))
})]

names(df_species)[names(df_species) == dept_col] <- "department"

# renaming a column with Mortality/Morbidity observations to outcome
outcome_col <- names(df_species)[sapply(df_species, function(x) {
  any(as.character(x)  %in% c("Mortality", "Morbidity"))
})]

names(df_species)[names(df_species) == outcome_col] <- "outcome"


# 2. changing disease data to long format
df_species_long <- df_species |>
  pivot_longer(cols = matches("ESV|B50"),
               names_to = "data_type",
               values_to = "value")

# keeping only the cols we need for further analysis
df_species_long <- df_species_long |>
  select(region, zone, woreda, period, department, outcome, data_type, value)

# -----------------------------------------------------------------------
# 2. standardizing the names of the variable names in the df_sevice and 
#keeping only cols we need for the work
df_service <- df_service |>
  rename(period = periodname,
         region = orgunitlevel2,
         zone= orgunitlevel3,
         woreda= orgunitlevel4)


# changing the service data to long format
df_service_long <- df_service |>
  pivot_longer(cols = contains("RDT"),
               names_to = "data_type",
               values_to = "value")

# keeping only the cols we need in the df_service_long for further analysis
df_service_long <- df_service_long |>
  select(region, zone, woreda, period, data_type, value)

#-------------------------------------------------------------------------
# 3. standardizing the names of the variable names in the df_report and 
#keeping only cols we need for the work
df_report <- df_report |>
  rename(period = periodname,
         region = orgunitlevel2,
         zone= orgunitlevel3,
         woreda= orgunitlevel4)

# renaming a column automatically as facility_type based on the observations
fac_type_col <- names(df_report)[sapply(df_report, function(x){
  any(as.character(x) %in% c("Clinics", "Health Centers", "Health Post", "Hospitals"))
})]


names(df_report)[names(df_report) == fac_type_col] <- "facility_type"


# changing the report data to long format
df_report_long <- df_report |>
  pivot_longer(cols = matches("NCD|NTD"),
               names_to = "data_type",
               values_to = "value")

# keeping only the cols we need in the df_service_long for further analysis
df_report_long <- df_report_long |>
  select(region, zone, woreda, period,facility_type, data_type, value)

# -----------------------------------------------------------------------

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
saveRDS(combined_hmis, "data/raw/April 2026 hmis/combined-hmis-apr_2026.rds")

