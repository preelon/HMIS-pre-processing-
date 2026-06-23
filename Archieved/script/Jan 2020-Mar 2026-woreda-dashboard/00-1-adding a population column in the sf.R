
library(dplyr)
library(stringr)
library(readr)

sf_pop <- read_csv("data/eth_shape_file_updated.csv") |>
  mutate(
    woreda = woreda |>
      str_replace_all("[/-]", " ") |>  
      str_squish()                     
  )|>
  mutate(zone= case_when(zone== "Mirab Omo" ~ "West Omo",
                           zone== "Finfine Special" ~ "Shager City",
                           TRUE ~ zone))
         
sf_geom <- readRDS("data/eth-admin3-v1082-clean-id.rds")

# join them
sf_fin <- sf_geom |>
  left_join(sf_pop, by= c("id_1082", "region","zone", "woreda"))

# sanity check
sf_fin |>
  filter(is.na(pop_2022)) #0

# save the sf with pop_2022
saveRDS(sf_fin, "data/eth-admin3-v1082-clean-id.rds")

