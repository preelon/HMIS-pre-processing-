
# libraries
library(tidyverse)
library(lubridate)
library(janitor) 
library(sf)

# sourcing the zonal cleaning function Amir gave me
source("Archieved/functions/geog_cleaning_accessories.R")

# path for the file with reference region, zone, woreda, and kebele names  
ref_path = "Archieved/data/eth-admin3-v1082-clean-id.rds"

# path for the raw data to be cleaned
dat_path = "Archieved/data/processed/april 2026/may_2026_hmis_zone_cleaning_completed.rds"

# path for pre-processed zone matches  
pre_path = "Archieved/data/preprocessed/woreda_names_corrected.csv"

# path for output cleaned data  
out_path = "Archieved/data/processed/may 2026/may_2026_hmis_woreda_cleaning_completed.rds"

# clean woreda names
wclean <- woreda_clean(dat_path = dat_path,
                       pre_path = pre_path,
                       ref_path = ref_path,
                       out_path = out_path)  # 0unmatched

# save unmatched names for further inclusion in the pre-processed file
write_csv(wclean$not_matched, 
          "Archieved/data/processed/unmatched_woredas_may_2026_unmatched.csv") 

# save candidate names to be considered when including in the pre-processed file
write_csv(wclean$candidates, 
          "data/processed/candidate_woredas_apr_2026-latest.csv")
# ------------------------------------------------------------------------
# lets include id 1082 in the hmis data by joining it to the sf
clean_woredas <- readRDS(out_path)|>
  select(-region_old, -zone_old, -woreda_old, -non_zero_ever, -matched)

sf <- readRDS(ref_path)|>
  sf::st_drop_geometry()|>
  select(-region_old, -pop_2022)

final_out <- clean_woredas|>
  left_join(sf, by= c("region", "zone","woreda"))

# saving the final hmis with id_1082
saveRDS(final_out, out_path)


# just to see how many rows will there be up on aggregation
x <- final_out|>
  group_by(
    id_1082,
    region,
    zone,
    woreda,
    facility_type,
    greg_date,
    department,
    outcome,
    data_type
  ) |>
  summarise(
    value = sum(value, na.rm = TRUE),
    .groups = "drop"
  )
