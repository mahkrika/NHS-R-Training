
#####################################################################
# Intro to R - Wrangling
# - Reshaping or transforming data into a format which is
#   easier to work with.
#   (for later visualisation, modelling, or computing of statistics)
#####################################################################

# Tidyverse functions work best with tidy data:
# 1. Each variable forms a column
# 2. Each observation forms a row

# The tool: dplyr
# dplyr is a language for data manipulation
# Most wrangling can be solved with 5 dplyr verbs:
# Arrange;
# Filter;
# Mutate;
# Group_By;
# Summarise. 
#####################################################################

# Exploring mental health (MH) inpatient capacity
# - Conduct an analysis of Mental Health inpatient capacity in England.
# - The data: KH03 returns (bed numbers and occupancy) by organisation,
#   published by NHSE:
#   https://www.england.nhs.uk/statistics/statistical-work-areas/bed-availability-and-occupancy/bed-data-overnight/

library(tidyverse)

# Load the data; but(!) use the Import Dataset tool - this data is not tidy
# Problem with the data - there is metadata above the data we want as the headers ("KH03 returns").
# Solution is to skip 3 rows
# Then note that the data column is currently set as a character - change this to date (%d/%m/%y)
library(readr)
beds_data <- read_csv("beds_data.csv", col_types = cols(date = col_date(format = "%d/%m/%Y")), 
                      skip = 3)
View(beds_data)

# Observations are quarterly. beds_av == mean number of beds available at midnight over the 3-month period
#                             beds_oc == as above, occupied.
# Real data - there are problems (NA, etc.)

# Consider dplyr as working with a recipe, take an input then perform functions using pipes

# Q1: Which organisation provided the highest number of MH beds?
# 1. arrange - reorder rows based on selected variable
beds_data %>%
  arrange(desc(beds_av)) #defaults to asc like SQL

# Q2: Which organisations provided the highest number of MH beds in Sept. 2018?
# We'll use arrange as in Q1
beds_data %>%
  arrange(desc(beds_av)) %>%
  filter(date == "2018-09-01")

# Q3: Which 5 organisations had the highest percentage occupancy in Sept. 2018?
# Don't have this, so use mutate
beds_data %>%
  mutate(perc_occ = occ_av / beds_av) %>% # Create new variable perc_occ
  filter(date == "2018-09-01") %>%
  arrange(desc(perc_occ)) # Sort by newly created variable


# Q4: What was the mean number of beds (across all trusts) for each date of value?
# Use summarise

beds_data %>%
  summarise(mean_beds = mean(beds_av)) # Problem! There are NA so this would just produce NA

beds_data %>%
  summarise(mean_beds = mean(beds_av, na.rm = T)) # So we remove the NA
# The above has given a mean overall, a single summary. Now we need to group for the each date element:

beds_data %>%
  group_by(date) %>%
  summarise(mean_beds = mean(beds_av, na.rm = T)) %>%
  ungroup() # Safest to ungroup after use

# Q5: Which 5 organisations have the highest mean % bed occupancy (over the 5 year period)?
beds_data %>%
  mutate(bed_occ = occ_av / beds_av) %>%
  group_by(org_name) %>%
  summarise(mean_bed_occ = mean(bed_occ, na.rm = T)) %>%
  arrange(desc(mean_bed_occ))
# Extension: how many columns associated with each observation?
beds_data %>%
  mutate(bed_occ = occ_av / beds_av) %>%
  group_by(org_name) %>%
  summarise(mean_bed_occ = mean(bed_occ, na.rm = T),
            number = n()) %>%
  arrange(desc(mean_bed_occ))

###############
# Also a sixth verb: select

# Select a subset of variables from existing dataset:
beds_data %>%
  select(org_code, org_name)

# Select a subset of variables from existing dataset:
beds_data %>%
  select(-org_code) # To remove a column

# Select a subset of variables from existing dataset:
beds_data %>%
  select(1:3) # Columns 1 to 3

# Select a subset of variables from existing dataset:
beds_data %>%
  select(org_name, everything()) # Put org_name at the start of the data frame