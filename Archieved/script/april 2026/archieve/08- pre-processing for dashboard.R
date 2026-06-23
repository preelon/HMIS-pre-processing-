# this script is prepared to preprocess the hmis data before taking it to the 
# app

rm(list = ls())

#libraries
library(tidyverse)
library(lubridate)
library(sf)

# reading the cleaned hmis data
hmis <- readRDS("data/processed/april 2026/april_mar_2026_hmis_woreda_cleaning_completed.rds")

# read sf
sf <- readRDS("data/eth-admin3-v1082-clean-id.rds")|>
  sf::st_drop_geometry()


# prepare a geo look up
geo_lookup <- hmis %>%
  distinct(
    id_1082,
    region,
    zone,
    woreda
  ) %>%
  arrange(region, zone, woreda)

# save the geo look up
saveRDS(geo_lookup, "data/processed/april 2026/geo_lookup.rds")

# create a population lookup
pop_lookup <- read_csv("data/eth-admin3-v1082-clean-id_with_pop_2030.csv")|>
  filter(year %in% c(2020:2026))|>
  select(-region_old)

# save population lookup
#saveRDS(pop_lookup, "data/processed/population_lookup.rds")

# creating time lookup
time_lookup <- tibble(
  greg_date = seq(
    from = as.Date("2020-01-01"),
    to = as.Date("2030-12-01"),
    by = "month"
  )
)

# create gregorian variable
time_lookup <- time_lookup %>%
  mutate(
    greg_year = year(greg_date),
    
    greg_month = month(
      greg_date,
      label = TRUE,
      abbr = TRUE
    ),
    
   greg_year_ui = factor(
        greg_year,
        levels = 2020:2026
      ),
    
    greg_month_num = month(greg_date),
    
    month_year = format(
      greg_date,
      "%b-%Y"
    )
  )

# create EFY variable
time_lookup <- time_lookup %>%
  mutate(
    
    efy = ifelse(
      greg_month_num >= 7,
      greg_year - 7,
      greg_year - 8
    ),
    
    efy_month_num = case_when(
      greg_month_num >= 7 ~ greg_month_num - 6,
      TRUE ~ greg_month_num + 6
    )
  )


# creating EFY display label
time_lookup <- time_lookup %>%
  mutate(
    efy_time = month_year
  )

# convert to factor
time_lookup <- time_lookup %>%
  mutate(
    
    greg_month = factor(
      greg_month,
      levels = c(
        "Jan","Feb","Mar","Apr",
        "May","Jun","Jul","Aug",
        "Sep","Oct","Nov","Dec"
      )
    ),
    
    month_year = factor(
      month_year,
      levels = format(
        greg_date,
        "%b-%Y"
      )
    )
  )

# save the time lookup
#saveRDS(time_lookup,"data/processed/time_lookup.rds")


# join timelookup to hmis
hmis <- hmis %>%
  left_join(
    time_lookup,
    by = "greg_date"
  )

# selecting the columns i need before saving
hmis <- hmis |>
  select(id_1082, region, zone, woreda, greg_date, greg_year = greg_year.y, 
         greg_month = greg_month.y, greg_month_num, month_year = month_year.y,
         efy, greg_year_ui,efy_month_num, efy_time, facility_type, department, outcome,
         data_type, value)

# saving the clean hmis for app use
saveRDS(hmis, "data/processed/april 2026/clean_apr_2026.rds" )

