# libraries
library(tidyverse)
library(lubridate)
library(janitor) 

# sourcing the zonal cleaning function Amir gave me
source("Archieved/functions/geog_cleaning_accessories.R")


# path for the file with reference region, zone, woreda, and kebele names  
ref_path = "Archieved/data/eth-admin3-v1082-clean-id.rds"

# path for the raw data to be cleaned
dat_path = "Archieved/data/processed/may 2026/may_2026_hmis_general_cleaning_completed.rds"

# path for pre-processed zone matches  
pre_path = "Archieved/data/preprocessed/region_names_corrected.csv"

# path for output cleaned data  
out_path = "Archieved/data/processed/may 2026/may_2026_hmis_region_cleaning_completed.rds"

rclean <- region_clean(dat_path = dat_path,
                       pre_path = pre_path,
                       ref_path = ref_path,
                       out_path = out_path)

# save unmatched names for further inclusion in the pre-processed file
write_csv(rclean$not_matched, 
          "data/processed/for_dashboard/unmatched_regions_jan_2020_mar_2026.csv") 

# save candidate names to be considered when including in the pre-processed file
write_csv(rclean$candidates, 
          "data/processed/for_dashboard/candidate_regions_jul_dec-latest.csv")

# sanity check
clean_region <- readRDS(out_path)

clean_region|>
  distinct()|>
  filter(data_type == "positives")|>
  summarise(sum(value, na.rm=T)) # 431506

general_clean <- readRDS(dat_path)

general_clean |>
  distinct()|>
  filter(data_type == "positives")|>
  summarise(sum(value, na.rm=T)) # 431506


# lets check if there are >1 pre processed names for the same old names
# in the preprocessed csv
pre_proc  <- read_csv(pre_path)
pre_proc |>
  group_by(old_name) |>
  filter(n_distinct(pre_proc_name) > 1) |>
  arrange(old_name) #0


