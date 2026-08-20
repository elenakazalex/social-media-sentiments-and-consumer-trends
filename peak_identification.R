library(dplyr)
library(readxl)
library(tidyverse)

#loading data
df_mentions <- read_excel('raw_data_mentions.xlsx')

#statistics 
df_mentions %>% glimpse
df_mentions %>% summary
df_mentions %>% class

#renaming date columns
orig_names <- names(df_mentions)
converted_dates <- as.Date(as.numeric(orig_names), origin = "1899-12-30")
new_names <- ifelse(is.na(converted_dates), orig_names, as.character(converted_dates))
names(df_mentions) <- new_names

#creating a long df for future validation
df_long <- df_mentions %>%
  pivot_longer(
    cols = -c("brand", "category", "type"), 
    names_to = "date",
    values_to = "value"
  ) %>%
  mutate(date = as.Date(as.numeric(date), origin = "1899-12-30"))

#calculating brand-specific means and stdev to normalize data
brand_stat <- df_long %>%
  group_by(brand) %>%
  summarise(mean=ceiling(mean(value)), stdev = sd(value)) 

#joining the tables with statistics and detailed data
full_mentions <- left_join(df_long, brand_stat, by = 'brand')

#deriving z stat and constructing peak-defined table
peaks <- full_mentions %>%
  filter((value - mean) / stdev >= 1) %>%
  select(brand, date, value)

#selecting only specific peaks
isolated_peaks <- peaks %>%
  arrange(brand, date) %>%
  group_by(brand) %>%
  mutate(
    prev_date = lag(date),
    next_date = lead(date),
    
    has_previous = !is.na(prev_date) &
      date == prev_date %m+% months(1),
    
    has_next = !is.na(next_date) &
      next_date == date %m+% months(1)
  ) %>%
  filter(
    !has_previous
  ) %>%
  select(brand, date, value)

#removing inaccessible records
isolated_peaks <- isolated_peaks %>%
  filter(date > as.Date("2023-12-01")) %>%
  filter(date < as.Date("2025-11-01")) %>%
  filter(!(brand == "Balenciaga" & date == as.Date("2024-01-01"))) %>%
  filter(!(brand == "E.l.f. Cosmetics" & date == as.Date("2025-06-01"))) %>%
  filter(!(brand == "Rare Beauty" & date == as.Date("2025-06-01"))) %>%
  filter(!(brand == "SKIMS" & date == as.Date("2025-03-01"))) %>%
  filter(!(brand == "Sanex" & date == as.Date("2025-07-01"))) %>%
  filter(!(brand == "VeriSource" & date == as.Date("2024-04-01")))


# additional peaks (based on extended qualitative search)
additional <- full_mentions %>% 
  filter(
    (brand == "Amazon" & date == as.Date("2025-06-01")) |
      (brand == "American Eagle" & date == as.Date("2025-07-01")) |
      (brand == "L’Oréal" & date == as.Date("2025-07-01")) |
      (brand == "Rhode" & date == as.Date("2024-11-01")) |
      (brand == "Sanex" & date == as.Date("2025-08-01")) |
      (brand == "Swatch" & date == as.Date("2025-08-01")) | 
      (brand == "Quaker Oats" & date == as.Date("2024-01-01"))
  ) %>%
  select(brand, date, value)


# union the tables 
full_ds_mentions <- union(additional, isolated_peaks)
