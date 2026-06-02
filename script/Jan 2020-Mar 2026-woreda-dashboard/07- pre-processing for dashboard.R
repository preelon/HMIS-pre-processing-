# this script is prepared to preprocess the hmis data before taking it to the 
# app

rm(list = ls())

#libraries
library(tidyverse)
library(lubridate)
library(sf)

# reading the cleaned hmis data
hmis <- readRDS("data/processed/jan 2020-mar 2026/jan_2020_mar_2026_hmis_woreda_cleaning_completed.rds")

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
saveRDS(geo_lookup, "data/processed/jan 2020-mar 2026/geo_lookup.rds")

# create a population lookup
pop_lookup <- read_csv("data/eth-admin3-v1082-clean-id_with_pop_2030.csv")|>
  filter(year %in% c(2020:2026))|>
  select(-region_old)

# save population lookup
saveRDS(pop_lookup, "data/processed/jan 2020-mar 2026/population_lookup.rds")

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
    greg_year_num = year(greg_date),
    
    greg_month = month(
      greg_date,
      label = TRUE,
      abbr = TRUE
    ),
    
   greg_year_ui = factor(
        greg_year_num,
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
      greg_year_num - 7,
      greg_year_num - 8
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
saveRDS(time_lookup,"data/processed/jan 2020-mar 2026/time_lookup.rds")


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
saveRDS(hmis, "data/processed/jan 2020-mar 2026/clean_hmis_2020_2026.rds" )


#-------------------------------------------------------------------
hmis |> 
  count(id_1082, greg_date, data_type, facility_type) |>
  filter(n > 1)












  
  # ===============================
# Type safety
# ===============================
mutate(
  region = as.character(region),
  zone   = as.character(zone),
  woreda = as.character(woreda)
) |>
  
  # ===============================
# Gregorian components
# ===============================
mutate(
  greg_month_num = lubridate::month(greg_date),
  greg_year      = lubridate::year(greg_date)
) |>
  
  # ===============================
# TRUE EFY YEAR (KEY FIX)
# EFY = Gregorian year - 8 (Ethiopian calendar shift)
# Example:
# Jul 2024–Jun 2025 = 2017 EFY
# ===============================
mutate(
  efy_year = if_else(
    greg_month_num >= 7,
    greg_year - 7,
    greg_year - 8
  )
) |>
  
  # ===============================
# EFY LABEL FOR FILTERS/UI
# ===============================
mutate(
  efy = paste0(efy_year, " EFY")
) |>
  
  # ===============================
# EFY MONTH INDEX (1–12)
# Jul = 1 ... Jun = 12
# ===============================
mutate(
  efy_month_num = ((greg_month_num - 7) %% 12) + 1
) |>
  
  # ===============================
# EFY TIME AXIS (IMPORTANT FIX)
# This preserves correct chronological order
# ===============================
mutate(
  efy_time = paste0(
    efy_year, "-",
    sprintf("%02d", efy_month_num)
  )
) |>
  
  # ===============================
# Gregorian month-year (fallback axis)
# ===============================
mutate(
  month_year = format(greg_date, "%b-%Y")
)|>
  mutate(
    greg_year_num = year(greg_date)
  )

efy_levels <- hmis |>
  distinct(efy_year, efy) |>
  arrange(efy_year) |>
  pull(efy)

efy_time_order <- hmis |>
  distinct(efy_year, efy_month_num, efy_time) |>
  arrange(efy_year, efy_month_num) |>
  pull(efy_time)

month_yr_levels <- hmis |>
  distinct(greg_date, month_year) |>
  arrange(greg_date) |>
  pull(month_year)

efy_levels <- hmis |>
  distinct(efy_year, efy) |>
  arrange(efy_year) |>
  pull(efy) |>
  unique()

hmis <- hmis |>
  mutate(
    efy = factor(efy, levels = efy_levels)
  )

# factoring efy_time
efy_time_order <- hmis |>
  distinct(efy_year, efy_month_num, efy_time) |>
  arrange(efy_year, efy_month_num) |>
  pull(efy_time) |>
  unique()

hmis <- hmis |>
  mutate(
    efy_time = factor(efy_time, levels = efy_time_order)
  )

# factoring month year
month_yr_levels <- hmis |>
  distinct(greg_date, month_year) |>
  arrange(greg_date) |>
  pull(month_year) |>
  unique()

hmis <- hmis |>
  mutate(
    month_year = factor(month_year, levels = month_yr_levels)
  )

# ordering greg months
greg_month_levels <- c(
  "Jan","Feb","Mar","Apr","May","Jun",
  "Jul","Aug","Sep","Oct","Nov","Dec"
)

hmis <- hmis |>
  mutate(
    greg_month = factor(greg_month, levels = greg_month_levels)
  )

# ordering greg ui year
greg_year_ui_levels <- hmis |>
  distinct(greg_year) |>
  arrange(greg_year) |>
  pull(greg_year) |>
  unique()

hmis <- hmis |>
  mutate(
    greg_year_ui = factor(greg_year, levels = greg_year_ui_levels)
  )


# region ordering
region_levels <- hmis |>
  distinct(region) |>
  arrange(region) |>
  pull(region)

hmis <- hmis |>
  mutate(
    region = factor(region, levels = region_levels)
  )

#zone ordering
zone_levels <- hmis |>
  distinct(zone) |>
  arrange(zone) |>
  pull(zone)

hmis <- hmis |>
  mutate(
    zone = factor(zone, levels = zone_levels)
  )

# woreda ordering
woreda_levels <- hmis |>
  distinct(woreda) |>
  arrange(woreda) |>
  pull(woreda)

hmis <- hmis |>
  mutate(
    woreda = factor(woreda, levels = woreda_levels)
  )



# creating zone population from the hmis
woreda_population <- hmis |>
  distinct(region, zone,woreda, greg_year_num,population) |> 
  mutate(
    population = as.numeric(population)  
  )

# saving woreda population
write_csv(woreda_population, "data/processed/jan 2020-mar 2026/woreda_pop.csv")

# # Region-Zone-woreda Lookup 
region_zone_woreda_lookup <- hmis |>
  distinct(region, zone, woreda) |>
  arrange(region, zone, woreda)

# saving geographic look up
write_csv(woreda_population, "data/processed/jan 2020-mar 2026/geo lookup.csv")
