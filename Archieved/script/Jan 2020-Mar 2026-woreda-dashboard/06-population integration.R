rm(list = ls())

# This script is prepared to integrate population data to the cleaned 
# HMIS data

# libraries
library(tidyverse)
library(lubridate)
library(janitor) 
library(sf)


# reading the required data
hmis <- readRDS("data/processed/jan 2020-mar 2026/jan_2020_mar_2026_hmis_woreda_cleaning_completed.rds")
#----------------------------------------------------------------------------
# because I used the kebele level shapefile for geographic cleaning
# I also should use the same sf for pop integration.However the keb level
#sf don't have pop_2022 column,so the below steps are what i followed 
#to prepare kebele level sf region & zone reference with pop_2022

# 2. Shape file
#geo_lookup_1082 <- read_csv("data/processed/eth_shape_file_updated.csv") |>
 # group_by(region, zone) |>
  #summarise(pop_2022 = sum(pop_2022, na.rm = T), .groups = "drop")


#geo_lookup_keb <- read_csv("data/processed/eth-kebele-names-shapefile-clean.csv") |>
 # distinct(region, zone)

# lets join the 2 datasets to get the pop_22 col on the keb shape file
#geo_lookup <- geo_lookup_keb |>
 # left_join(geo_lookup_1082, by = c("region", "zone"))

# There are NA values for 4 zones (because of name d/ce in the 2 shape files)
# lets correct them manually
#geo_lookup <- geo_lookup |>
 # mutate(pop_2022 = case_when(zone == "Dire Dawa" ~ 520998,
  #                            zone == "Shager City" ~ 1085361,
   #                           zone == "Itang Special" ~ 54022,
    #                          zone == "West Omo" ~ 252658,
     #                         TRUE ~ pop_2022))
# check if there are NA pop_22 values
#geo_lookup|>
  #filter(is.na(pop_2022)) # 0

# lets save that shapefile for future use
#write_csv(geo_lookup , "data/processed/shapefile reconciled for woreda and kebele sf.csv")
#-------------------------------------------------------------------------
# read the shape file
geo_lookup_with_geom <- readRDS("data/eth-admin3-v1082-clean-id.rds")


# creating a data frame of geographic reference from the sf

geo_lookup <- readRDS("data/eth-admin3-v1082-clean-id.rds")|>
  st_drop_geometry()
  

# lets project population number for the years 2017-2025 based on 
# 2022 pop number in the sf
geo_lookup_long <- geo_lookup |>
  mutate(pop_2021= round(pop_2022*(1.0266^-1),0),
         pop_2020= round(pop_2021*(1.0266^-1),0),
         pop_2019= round(pop_2020*(1.0266^-1),0),
         pop_2018= round(pop_2019*(1.0266^-1),0),
         pop_2017= round(pop_2018*(1.0266^-1),0),
         pop_2023= round(pop_2022*(1.0266^1),0),
         pop_2024= round(pop_2023*(1.0266^1),0),
         pop_2025= round(pop_2024*(1.0266^1),0),
         pop_2026= round(pop_2025*(1.0266^1),0),
         pop_2027= round(pop_2026*(1.0266^1),0),
         pop_2028= round(pop_2027*(1.0266^1),0),
         pop_2029= round(pop_2028*(1.0266^1),0),
         pop_2030= round(pop_2029*(1.0266^1),0))|>
  pivot_longer(cols= starts_with("pop"), 
               names_to = "year", 
               values_to = "population") |>
  mutate(year = as.numeric(gsub("pop_", "", year))) 

# saving this geo look up wit population utto 2030 for future use
#write_csv(geo_lookup_long,"data/eth-admin3-v1082-clean-id_with_pop_2030.csv")

# aggregating the shapefile pop
geo_lookup_long_agg <- geo_lookup_long |>
  group_by(region, zone, woreda, year) |>
  summarise(population = sum(population = sum(population, na.rm = T)),
            ,.groups = "drop"
            )


# aggregating.groups = # aggregating the hmis
hmis_agg <- hmis |>
  group_by(region, zone,woreda,facility_type, eth_month,eth_year, greg_date,
           greg_month, greg_year,department, outcome,data_type) |>
  summarise(value= sum(value, na.rm = T),.groups = "drop")

#joining population data to the hmis
hmis_pop_data_integrated <- hmis_agg |>
  left_join(
    geo_lookup_long_agg, by= c("region", "zone","woreda", 
                               "greg_year" = "year")
  )

# lets re-check if there are unmatched zones
data.frame(zones= unique(hmis_agg$zone)) |>
  filter(is.na(zones%in%geo_lookup$zone)) #0

# lets re-check if there are unmatched woredas
data.frame(woreda= unique(hmis_agg$woreda)) |>
  filter(is.na(woreda%in%geo_lookup$woreda)) #0

# checking the national population number to see it is an acceptable number
hmis_pop_data_integrated |>
  distinct(region, zone, greg_year, population)|>
  group_by(greg_year) |>
  summarise(national_pop = sum(population, na.rm = TRUE)) #110500338



# selecting only cols i want going forward
hmis_pop_data_integrated <- hmis_pop_data_integrated |>
  select(region, zone, woreda,facility_type, greg_date, greg_month, 
         greg_year, department, outcome, data_type, value, population)


# saving the population aggregated hmis data
write_csv(hmis_pop_data_integrated, "data/processed/jan 2020-mar 2026/jan-2020-mar-2026-woreda-cleaned-pop-integrated.csv")

unique(hmis_pop_data_integrated$zone) #92

unique(hmis_pop_data_integrated$woreda) #1019


