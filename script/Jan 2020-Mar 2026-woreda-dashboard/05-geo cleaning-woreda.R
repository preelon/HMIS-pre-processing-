
# libraries
library(tidyverse)
library(lubridate)
library(janitor) 
library(sf)

# sourcing the zonal cleaning function Amir gave me
source("functions/geog_cleaning_accessories.R")

# path for the file with reference region, zone, woreda, and kebele names  
ref_path = "data/eth-admin3-v1082-clean-id.rds"

# path for the raw data to be cleaned
dat_path = "data/processed/jan 2020-mar 2026/jan_2020_mar_2026_hmis_zone_cleaning_completed.rds"

# path for pre-processed zone matches  
pre_path = "data/preprocessed/woreda_names_corrected.csv"

# path for output cleaned data  
out_path = "data/processed/jan 2020-mar 2026/jan_2020_mar_2026_hmis_woreda_cleaning_completed.rds"

# clean woreda names
wclean <- woreda_clean(dat_path = dat_path,
                       pre_path = pre_path,
                       ref_path = ref_path,
                       out_path = out_path)  #1683 unmatched

# save unmatched names for further inclusion in the pre-processed file
write_csv(wclean$not_matched, 
          "data/processed/unmatched_woredas_jan_2020_mar_2026_unmatched.csv") 

# save candidate names to be considered when including in the pre-processed file
write_csv(wclean$candidates, 
          "data/processed/candidate_woredas_jul_2020_mar_2026-latest.csv")

# MANDATORY BEFORE PROCEEDING TO THE NEXT LEVEL
# lets include id 1082 in the hmis data by joining it to the sf
clean_woredas <- readRDS(out_path)|>
  select(-region_old, -zone_old, -woreda_old)

sf <- readRDS(ref_path)|>
  sf::st_drop_geometry()|>
  select(-region_old, -pop_2022)

final_out <- clean_woredas|>
  left_join(sf, by= c("region", "zone","woreda"))

# saving the final hmis with id_1082
saveRDS(final_out, out_path)

#-------------------------------END-------------------------------------



# what Amir and I tried (crossing) as a solution for large number of unmathed woreda
ref <- readRDS(ref_path) |>
  sf::st_drop_geometry()

joined <- clean_woredas |>
  left_join(ref)

final_out <- target_df |>
  left_join(joined, by= c("year"= "greg_year",
                          "id_1082"))

# -----------------------------------------------------------------------
# sanity check
unmatched<- read_csv("data/processed/unmatched_woredas_jan_2020_mar_2026_unmatched.csv")

#unmatched_hmis <- clean_woredas |>
 # filter(woreda %in% unique(unmatched$woreda))|>
 # filter(data_type %in% c("positives", "tested")) #0

# at this point I ensured that the remaining unmatched woredas are all with 
# NA value, therefore I excluded them from the hmisas followed
#clean_woredas <- clean_woredas |>
#  filter(!woreda %in% unmatched$woreda)

# sanity check
clean_woredas |>
  filter(data_type == "positives") |>
  summarise(total = sum(value, na.rm = T)) #28357118 

# saving the hmis with unmatched woredas excluded
saveRDS(clean_woredas , "data/processed/jan 2020-mar 2026/jan_2020_mar_2026_hmis_woreda_cleaning_completed.rds")

#-----------------------------------------------------------------------

# previously, before i cleaned the woredas with non-NA value the below 
# code was true and used

unmatched_0ormore_value <-unmatched_hmis|>
  filter(value>= 0)|> 
  distinct(region, zone, woreda)

unmatched_value_na <- unmatched_hmis |>
  filter(!woreda%in%unique(unmatched_0ormore_value$woreda))|>
  distinct(region, zone, woreda)

# lets save the above (na)
#write_csv(unmatched_value_na, "data/processed/unmatched_woredas_with_na_value.csv")

# lets save the above (>=0
#write_csv(unmatched_0ormore_value, "data/processed/unmatched_woredas_with_numeric_value.csv")

# lets check how many tests and cases those facilities contribute
unmatched_hmis|>
  group_by(data_type) |>
  summarise(total = sum(value, na.rm = T)) ##395 has 0 or more value

unique(unmatched_hmis$woreda)

clean_woredas |>
  filter(data_type=="positives")|>
  summarise(sum(value,na.rm = T)) #28356824

clean_woredas |>
  filter(value== 0)

clean_zone <- readRDS(dat_path) 

clean_zone |>
  distinct() |>
  filter(data_type=="positives")|>
  summarise(sum(value,na.rm = T))

# lets check if there are >1 pre processed names for the same old names
# in the preprocessed csv
pre_proc  <- read_csv(pre_path)
pre_proc %>%
  group_by(old_name) %>%
  filter(n_distinct(pre_proc_name) > 1) %>%
  arrange(old_name)

