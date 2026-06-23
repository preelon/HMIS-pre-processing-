rm(list = ls())

# libraries
library(tidyverse)
library(lubridate)
library(janitor) 
library(sf)
library(stringr)

# read the combined hmis data
combined_hmis <- readRDS("data/raw/April 2026 hmis/combined-hmis-apr_2026.rds")


combined_hmis|>
  filter(woreda== "Bule Town Adminstration Health Office")

# standardization
combined_hmis <- combined_hmis |>
  janitor::clean_names() |>
  mutate(region= gsub("Region", "", region),
         region= gsub("region", "", region),
         region= gsub("City Administration", "" , region),
         region= gsub("al Health Bureau" , "", region),
         region= gsub("Ethiopian", "", region),
         region= gsub("Ethiopia", "", region),
         region= gsub("  ", " ", region),
         region= str_trim(region)) |>
  mutate(zone = gsub("Health Office","", zone),
         zone = gsub("Zone","",zone),
         zone= gsub("City Administration","", zone),
         zone= gsub("Zone Health Department","", zone),
         zone= gsub("Health Department","", zone),
         zone= gsub("Health department","", zone),
         zone= gsub("Woreda","", zone),
         zone = gsub("Zonal", "", zone),
         woreda = gsub("Town Adminstration", "", woreda),
         woreda= gsub("Health Office", "", woreda)) |>
  mutate(woreda = str_squish(woreda))
         #iconv(woreda, to = "ASCII//TRANSLIT"))


#lets see unique zones
unique(combined_hmis$zone) #164


# checking if there are NA zones
combined_hmis |>
  filter(is.na(zone)) #0

#checking the periods for the hmis
unique(combined_hmis$period) #Miazia 2018 

#looking at the variables
names(combined_hmis)


# checking the unique values for outcome and department
table(combined_hmis$outcome,useNA = "ifany")

table(combined_hmis$department,useNA = "ifany")

#--------------------------------------------------------------------------------------------
# checking the data_types in the HMIS
unique(combined_hmis$data_type)

# creating vectors of data elements
pf_conf <- c("B50-196 Malaria (Plasmodium falciparum malaria)", "B50-197 Malaria (Plasmodium falciparum malaria with cerebral complications)",
             "B50-198 Malaria (Other severe and complicated Plasmodium falciparum malaria)",
             "B50-199 Malaria (Plasmodium falciparum malaria unspecified)",
             "ESV-ICD11 1F40 - Malaria due to Plasmodium falciparum",
             "ESV-ICD11 1F44 - Other parasitologically confirmed malaria",
             "B50-203 Mixed Malaria (Other parasitologically confirmed malaria)"
)

pv_conf <- c("B50-200 Malaria (Plasmodium vivax malaria)", "B50-201 Malaria (Plasmodium vivax malaria with other complications)",
             "B50-202 Malaria (Plasmodium vivax malaria without complication)",
             "ESV-ICD11 1F41 - Malaria due to Plasmodium vivax"
)

mixed_conf <- c("ESV-ICD11 1F40/1F41 -  Malaria due to Plasmodium falciparum associated with Malaria due to Plasmodium Vivax (Mixed Malaria)",
                "B50-203 Mixed Malaria (Other parasitologically confirmed malaria)"
)

pm_conf <- c("ESV-ICD11 1F42 - Malaria due to Plasmodium malariae")

po_conf <- c("ESV-ICD11 1F43 - Malaria due to Plasmodium ovale")

clinical_malaria <- c("B50-204 Malaria (Unspecified malaria)",
                      "ESV-ICD11 1F45 - Malaria without parasitological confirmation")

tested <- c("MAL_Slides or RDT performed for malaria diagnosis", 
            "-2017_Total number of slides or RDT performed for malaria diagnosis")

positives <- c("MAL_Slides or RDT Positive")

actual_reports <- c("08.1 - Malaria, NTD, NCD | Basic Health post | Monthly - Actual reports",
                    "08.2 - Malaria, NTD, NCD | Hospital, Health center, Clinic | Monthly - Actual reports",
                    "08.3 - Malaria, NTD, NCD | Comprehensive HP | Monthly - Actual reports")

actual_on_time <- c("08.1 - Malaria, NTD, NCD | Basic Health post | Monthly - Actual reports on time",
                    "08.2 - Malaria, NTD, NCD | Hospital, Health center, Clinic | Monthly - Actual reports on time",
                    "08.3 - Malaria, NTD, NCD | Comprehensive HP | Monthly - Actual reports on time")


expected <- c("08.1 - Malaria, NTD, NCD | Basic Health post | Monthly - Expected reports",
              "08.2 - Malaria, NTD, NCD | Hospital, Health center, Clinic | Monthly - Expected reports",
              "08.3 - Malaria, NTD, NCD | Comprehensive HP | Monthly - Expected reports")

#Harmonizing data element names
combined_hmis <- combined_hmis |>
  mutate(
    data_type = case_when(data_type %in% pf_conf ~ "pf_conf",
                          data_type %in% pv_conf ~ "pv_conf",
                          data_type %in% positives ~ "positives",
                          data_type %in% tested ~ "tested",
                          data_type %in% clinical_malaria ~ "clinical",
                          data_type %in% mixed_conf ~ "mixed_conf",
                          data_type %in% po_conf ~ "po_conf",
                          data_type %in% pm_conf ~ "pm_conf",
                          data_type %in% actual_reports ~ "actual_reports",
                          data_type %in% actual_on_time ~ "actual_reports_ontime",
                          data_type %in% expected ~ "expected_reports",
                          TRUE ~ data_type
    )
  )


#rechecking the data types
unique(combined_hmis$data_type) #corrected

#-----------------------------------------------------------------------------------------
#lets change the period YMD form
#1st-lets create a month look up
# Month lookup (Ethiopian → month number)
unique(combined_hmis$period)

eth_months <- c("Meskerem", "Tikemet","Hidar","Tahesas",
                "Tir","Yekatit","Megabit","Miazia",
                "Ginbot","Sene","Hamle","Nehase")

#step 3 creating the respective greg months
greg_months <- c(9,10,11,12,1,2,3,4,5,6,7,8) # approx Gregorian months


month_map <- setNames(1:12, eth_months)

combined_hmis <- combined_hmis %>%
mutate(
eth_month = str_extract(period, "^[^ ]+"),
eth_year  = as.integer(str_extract(period, "\\d+$")),

eth_month_num = month_map[eth_month],

  greg_year = if_else(eth_month_num <= 4,
                   eth_year + 7,
                 eth_year + 8),

  greg_month = greg_months[eth_month_num],

 greg_date = make_date(greg_year, greg_month, 1)
)

# keeping only the cols i want
combined_hmis <- combined_hmis |>
  mutate(greg_month= month(greg_date, label = T),
         greg_year = year(greg_date),
         month_year = paste(greg_month,"-", greg_year)) |>
  select(region, zone, woreda, eth_month, eth_year,
         greg_date, greg_month, greg_year, month_year, 
         facility_type, department, outcome,data_type, value)

# sanity check
combined_hmis |>
  filter(data_type == "positives")|>
  summarise(total= sum(value, na.rm = T)) #344016

# checking if regions are matched or not
# 1st read the geo lookup
geo_lookup <- readRDS("data/eth-admin3-v1082-clean-id.rds")|>
  sf::st_drop_geometry()

# 2nd check if there are unmatched regions
data.frame(regions = unique(combined_hmis$region)) |>
  filter(!regions %in% unique(geo_lookup$region)) #0


# saving the hmis for geographic cleaning
saveRDS(combined_hmis, "data/processed/april 2026/apr_2026_hmis_general_cleaning_completed.rds")

#-----------------------------END-----------------------------------------------------------

