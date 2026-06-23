#rm(list = ls())

# libraries
library(tidyverse)
library(lubridate)
library(janitor) 

# sourcing the zonal cleaning function Amir gave me
source("functions/geog_cleaning_accessories.R")

# path for the file with reference region, zone, woreda, and kebele names  
ref_path = "data/eth-admin3-v1082-clean-id.rds"

# path for the raw data to be cleaned
dat_path = "data/processed/april 2026/apr_2026_hmis_region_cleaning_completed.rds"

# path for pre-processed zone matches  
pre_path = "data/preprocessed/zone_names_corrected.csv"

# path for output cleaned data  
out_path = "data/processed/april 2026/apr_2026_hmis_zone_cleaning_completed.rds"

# clean the zonal names
zclean <- zone_clean(dat_path,
                     pre_path,
                     ref_path,
                     out_path) 


# save unmatched names for further inclusion in the pre-processed file
write_csv(zclean$not_matched, 
          "data/processed/unmatched_zones_apr_2026_unmatched_zones.csv") #1 zone unmatched

# save candidate names to be considered when including in the pre-processed file
write_csv(zclean$candidates, 
          "data/processed/candidate_zones_jul_2020_mar_2026-latest.csv")


# sanity check
clean_zones <- readRDS(out_path)

clean_zones|>
  distinct()|>
  filter(value >0)|>
  filter(data_type=="positives")|>
  summarise(sum(value,na.rm = T)) #344016

clean_regions <- readRDS(dat_path)

clean_regions |>
  filter(data_type=="positives")|>
  summarise(sum(value,na.rm = T)) #344016, correct

# lets check if there are >1 pre processed names for the same old names
# in the preprocessed csv
pre_proc  <- read_csv(pre_path)
pre_proc |>
  group_by(old_name) |>
  filter(n_distinct(pre_proc_name) > 1) |>
  arrange(old_name) #0

