
wor_geom = readRDS("data/eth-admin3-v1082-clean-id.rds")
#region_geom = readRDS("02.data-processing/shapefile/eth-admin1-v816-clean-id.RDS")

wor_input <- readRDS("data/processed/jan 2020-mar 2026/jan_2020_mar_2026_hmis_zone_cleaning_completed.rds")

# look up
#woreda_lookup <- read_csv("01.input-data/shapefile/lookup_1082_to_all.csv") |>
  #dplyr::select(id_1082, id_816)

## population
#pop <- read_csv( "02.data-processing/population-data/02.data-outputs/eth-woreda-population-v-1082-2011-2030.csv") |>
  #dplyr::select(-region, -zone, -woreda)


wor_id<- wor_geom |>
  sf::st_drop_geometry() 
  #left_join(woreda_lookup)


target_df <- crossing(wor_id, year = 2020:2026)






