library(readxl)
library(tidyverse)
library(ggthemes)

#loading data
df_mentions <- read_excel('raw_data_mentions.xlsx')

#quick peek into the structure of the df
df_mentions %>% glimpse
df_mentions %>% summary
str(df_mentions)

df_mentions %>% group_by(category) %>% count()

#renaming date columns
orig_names <- names(df_mentions)
converted_dates <- as.Date(as.numeric(orig_names), origin = "1899-12-30")
new_names <- ifelse(is.na(converted_dates), orig_names, as.character(converted_dates))
names(df_mentions) <- new_names

#long pivot date columns to ensure the df is usable for validation
df_long <- df_mentions %>%
  pivot_longer(
    cols = -c("brand", "category", "type"), 
    names_to = "date",
    values_to = "value"
  ) ##%>%
  ##mutate(date = as.Date(as.numeric(date), origin = "1899-12-30"))

#calculating brand-specific means and stdev to normalize data
brand_stat <- df_long %>%
  group_by(brand) %>%
  summarize(mean=ceiling(mean(value)), stdev = sd(value), median = median(value)) #rounding up the average for integer output

#joining the tables with statistics and detailed data
full_mentions <- left_join(df_long, brand_stat, by = 'brand')

#5 brands with the highest mean of mentions
highest_mentioned <- full_mentions %>% slice_max(order_by = mean, n = 120)


#5 brands with the lowest mean of mentions
least_mentioned <- full_mentions %>% slice_min(order_by = mean, n = 120)


#EDA via visualization 
ggplot(highest_mentioned, aes(x=brand,y = as.numeric(value))) + geom_boxplot(outlier.colour = "red") + theme_tufte() +   labs(y = NULL, x = NULL, title = "Distribution of monthly mentions count for 5 most mentioned brands on average")

ggplot(least_mentioned, aes(x=brand,y = as.numeric(value))) + geom_boxplot(outlier.colour = "red") + theme_tufte() +   labs(y = NULL, x = NULL, title = "Distribution of monthly mentions count for 5 least mentioned brands on average")




#deriving z stat and constructing peak-defined table
peaks <- full_mentions %>%
  filter((value - mean) / stdev >= 1) %>%
  select(brand, date, value)


#selecting only specific peaks
isolated_peaks <- peaks %>%
  mutate(date = as.Date(date)) %>%
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
  filter(!(brand == "Kylie Cosmetics" & date == as.Date("2025-09-01"))) %>%
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
      (brand == "Kylie Cosmetics" & date == as.Date("2025-10-01")) | 
      (brand == "Quaker Oats" & date == as.Date("2024-01-01"))
  ) %>%
  select(brand, date, value) %>%
  mutate(date = as.Date(date))


# union the tables 
full_ds_mentions <- union(additional, isolated_peaks)

########### search data ########### 

#loading data
df_search <- read_excel('raw_data_search.xlsx')

#quick peek into the structure of the df
df_search %>% glimpse
df_search %>% summary
df_search %>% class

#renaming date columns
names(df_search) <- new_names

#pivot long
df_long_search <- df_search %>%
  pivot_longer(
    cols = -c("brand", "category", "type"), 
    names_to = "date",
    values_to = "value"
  ) %>%
  mutate(date = as.Date(date))


#add t-1, t0, t+1, t+2 
df_dates <- full_ds_mentions %>%
  mutate(
    date = as.Date(date),
    date_t_minus1 = date %m-% months(1),
    date_t0        = date,
    date_t_plus1   = date %m+% months(1),
    date_t_plus2   = date %m+% months(2)
  ) %>%
  pivot_longer(
    cols = c(date_t_minus1, date_t0, date_t_plus1, date_t_plus2),
    names_to = "period",
    values_to = "search_date"
  )

#join search and mentions
df_selected <- df_dates %>%
  left_join(
    df_long_search,
    by = c(
      "brand" = "brand",
      "search_date" = "date"
    )
  ) 

#selecting necessary columns - full df  
df_full <- df_selected %>% select(brand, date, value.x, period, search_date,
                                  value.y) %>%
  rename(peak_date = date, peak_mentions_volume = value.x, search_volume = value.y)


########### transforming into an event-based df ########### 

#pivot wide first to transform into the necessary structure 
df_wide <- df_full %>% 
  select(brand, peak_date, period, search_volume) %>%
  pivot_wider(
    names_from = period,
    values_from = search_volume
  )

#transforming search change into a percentage change from the pre-event baseline
df_transformed <- df_wide %>% mutate(baseline = date_t_minus1 - date_t_minus1, change_t0 = ((date_t0/date_t_minus1)*100)-100,
                                     change_t1 = ((date_t_plus1/date_t_minus1)*100)-100,
                                     change_t2 = ((date_t_plus2/date_t_minus1)*100)-100) %>%
  select(brand, peak_date, baseline, change_t0, change_t1, change_t2)

########### adding sentiment dimensions to the df ########### 

#loading sentiment dimensions df and joining dfs
df_sentiments <- read_excel('sentiment_dimensions.xlsx')

df_peaks <- df_transformed %>% left_join(
  df_sentiments,
  by = c(
    "brand" = "brand",
    "peak_date" = "peak_of_mentions"
  )
) 

#calculating expression intensity
df_peaks <- df_peaks %>% mutate(expressive_share = rowSums(pick(positive_ment, neg_ment), na.rm = TRUE),
                                all_mentions = rowSums(pick(expressive_share, neutral_ment), na.rm = TRUE),
                                expression_intensity = (expressive_share/all_mentions),
                                across(expression_intensity, round, 3))


#calculating quantiles of expression intensity
quantiles_df <- df_peaks %>%
  reframe(
    quant = c(0.25, 0.50, 0.75, 1),
    value = quantile(expression_intensity, probs = quant, na.rm = TRUE)*100
  )

# plotting right skeweness
ggplot(df_peaks, aes(sample = expression_intensity)) +
  stat_qq() +
  stat_qq_line(color = "red") +
  labs(title = "Q-Q plot for expression intensity variable",
       x = "theoretical quantiles",
       y = "sample quantiles") +
  theme_tufte()

ggplot(df_peaks, aes(x='',y = as.numeric(expression_intensity))) + geom_boxplot(outlier.colour = "red") + theme_tufte() +   labs(y = NULL, x = NULL, title = "Distribution of expression intensity variable")



########### creating segments ########### 
df_peaks <- df_peaks %>% mutate(
  intensity_level = case_when(
    expression_intensity == 0 ~ "Non-expressive",
    expression_intensity < 0.03 ~ "Minimally expressive",
    expression_intensity < 0.1 ~ "Weakly expressive",
    expression_intensity < 0.2 ~ "Moderately expressive",
    expression_intensity < 0.4 ~ "Highly expressive",
    expression_intensity >= 0.4 ~ "Extremely expressive",
    TRUE ~ NA_character_
  )
)

#test the difference between levels
test_min_weak <- df_peaks %>%
  filter(
    intensity_level %in% c(
      "Non-expressive",
      "Extremely expressive"
    )
  ) %>%
  wilcox.test(
    change_t0 ~ intensity_level,
    data = .,
    exact = FALSE
  )

test_min_weak

#creating a summary table
peaks_summary <- df_peaks %>% 
  group_by(intensity_level) %>%
  summarise(baseline = mean(baseline, na.rm=TRUE),
            mean_changet0 = mean(change_t0, na.rm=TRUE), 
            mean_changet1 = mean(change_t1, na.rm=TRUE), 
            mean_changet2 = mean(change_t2, na.rm=TRUE)) %>%
  pivot_longer(!intensity_level, names_to = "time", values_to = "change")

#visualizing segments 
ggplot(peaks_summary, aes(x = time, y = change, group=intensity_level, color=intensity_level)) + 
  geom_point() + geom_line() + theme_tufte()

#higher lvl segments
higher_intensity <- peaks_summary %>% filter(intensity_level == "Extremely expressive" | intensity_level == "Highly expressive") 

ggplot(higher_intensity, aes(x = time, y = change, group=intensity_level, color=intensity_level)) +
  geom_point() + geom_line() + theme_tufte() + 
  scale_x_discrete(labels=c('t-1', 't0', 't+1', 't+2')) + 
  scale_y_continuous(labels = scales::percent_format(scale=1)) +
  labs(y='average change in search volume', color = NULL, title = 'Higher levels of expression intensity search behavior', subtitle = 'Average % change in search volume from the pre-peak search volume') +
  theme(legend.position = "bottom", plot.subtitle = element_text(color='grey'))

#lower lvl segments
lower_intensity <- peaks_summary %>% filter(!(intensity_level == "Extremely expressive" | intensity_level == "Highly expressive"))
lower_intensity$intensity_level <- factor(lower_intensity$intensity_level, levels=c('Non-expressive', 'Minimally expressive', 'Weakly expressive', 'Moderately expressive'))

ggplot(lower_intensity, aes(x = time, y = change, group=intensity_level, color=intensity_level)) +
  geom_point() + geom_line() + theme_tufte() +
  scale_x_discrete(labels=c('t-1', 't0', 't+1', 't+2')) + 
  scale_y_continuous(labels = scales::percent_format(scale=1), limits = c(-10,30)) +
  labs(y='average change in search volume', color = NULL, title = 'Lower levels of expression intensity search behavior', subtitle = 'Average % change in search volume from the pre-peak search volume') +
  theme(legend.position = "bottom", plot.subtitle = element_text(color='grey')) 

########### validating LM ###########

#pivoting original df longer 
peaks_long <- df_peaks %>%
  pivot_longer(cols=c(change_t0, change_t1, change_t2),
               names_to="time",
               values_to = "change") %>%
  select(brand, expression_intensity, intensity_level, time, change) %>%
  drop_na()

#preparing variables
peaks_long$time <- factor(peaks_long$time, levels = c("change_t0","change_t1","change_t2"))
peaks_long$expression_intensity <- as.numeric(peaks_long$expression_intensity)

lm_peaks <- lm(change ~ time + expression_intensity, data = peaks_long)
summary(lm_peaks)

########### search dimensions ###########
library(janitor)

df_search_types <- read_excel('raw_data_search_categories.xlsx')
df_search_types <- df_search_types %>% clean_names()

#handling 0 values for transactional queries
df_search_types <- df_search_types %>% 
  mutate(trans_t_1 = if_else(trans_t_1 == 0 & trans_t0 != 0, 1, trans_t_1))

#transforming search change into a percentage change from the pre-event baseline
df_search_types_redef <- df_search_types %>% mutate(change_trans_t0 = ((trans_t0/trans_t_1)*100)-100,
                                     change_trans_t1 = ((trans_t_1_2/trans_t_1)*100)-100,
                                     change_trans_t2 = ((trans_t_2/trans_t_1)*100)-100,
                                     change_info_t0 = ((info_t0/info_t_1)*100)-100,
                                     change_info_t1 = ((info_t_1_2/info_t_1)*100)-100,
                                     change_info_t2 = ((info_t_2/info_t_1)*100)-100) %>%
  select(brand, peak_of_mentions, change_trans_t0, change_trans_t1, change_trans_t2, change_info_t0, change_info_t1, change_info_t2) %>%
  mutate(across(where(is.numeric), ~replace(., is.nan(.), 0)))

df_complete <- df_peaks %>% left_join(
  df_search_types_redef,
  by = c(
    "brand" = "brand",
    "peak_date" = "peak_of_mentions"
  )
) %>%
  select(brand, peak_date, expression_intensity, intensity_level, baseline, change_trans_t0, change_trans_t1, change_trans_t2, change_info_t0, change_info_t1, change_info_t2)

#summary table for transactional
#creating a summary table
peaks_summary_all <- df_complete %>% 
  group_by(intensity_level) %>%
  summarise(baseline = mean(baseline, na.rm=TRUE),
            mean_changet0_trans = mean(change_trans_t0, na.rm=TRUE), 
            mean_changet1_trans = mean(change_trans_t1, na.rm=TRUE), 
            mean_changet2_trans = mean(change_trans_t2, na.rm=TRUE),
            mean_changet0_info = mean(change_info_t0, na.rm=TRUE), 
            mean_changet1_info = mean(change_info_t1, na.rm=TRUE), 
            mean_changet2_info = mean(change_info_t2, na.rm=TRUE)) %>%
  pivot_longer(!intensity_level, names_to = "time", values_to = "change")

#reshaping df to ensure 2 separate types of search 
library(stringr)

plot_data <- peaks_summary_all %>%
  mutate(
    period = case_when(
      time == "baseline" ~ "t-1",
      str_detect(time, "t0") ~ "t0",
      str_detect(time, "t1") ~ "t+1",
      str_detect(time, "t2") ~ "t+2"
    ),
    
    type = case_when(
      str_detect(time, "trans") ~ "transactional",
      str_detect(time, "info") ~ "informational",
      time == "baseline" ~ "both"
    )
  )

baseline <- plot_data %>%
  filter(time == "baseline") %>%
  mutate(type = "transactional")

baseline_info <- plot_data %>%
  filter(time == "baseline") %>%
  mutate(type = "informational")

plot_data <- plot_data %>%
  filter(time != "baseline") %>%
  bind_rows(baseline, baseline_info) %>%
  mutate(
    period = factor(
      period,
      levels = c("t-1", "t0", "t+1", "t+2")
    )
  )


#non-expressive
non_expressive <- plot_data %>% 
  filter(intensity_level == "Non-expressive")

ggplot(non_expressive, aes(x=period, y = change, group=type, color=type)) + geom_point() + geom_line() +
  theme_tufte() +
  scale_y_continuous(labels = scales::percent_format(scale=1), limits = c(-10,145)) +
  labs(y='average change in search volume', color = NULL, title = 'Non-expressive peaks of mentions: search activity', subtitle = 'Average % change in search volume from the pre-peak search volume') +
  theme(legend.position = "bottom", plot.subtitle = element_text(color='grey')) +
  scale_color_brewer(palette = "Set1")

#minim expr
min_expr <- plot_data %>% 
  filter(intensity_level == "Minimally expressive")

ggplot(min_expr, aes(x=period, y = change, group=type, color=type)) + geom_point() + geom_line() +
  theme_tufte() +
  scale_y_continuous(labels = scales::percent_format(scale=1), limits = c(-10,145)) +
  labs(y='average change in search volume', color = NULL, title = 'Minimally expressive peaks of mentions: search activity', subtitle = 'Average % change in search volume from the pre-peak search volume') +
  theme(legend.position = "bottom", plot.subtitle = element_text(color='grey')) +
  scale_color_brewer(palette = "Set1")

#weakly expr
weakly_expr <- plot_data %>% 
  filter(intensity_level == "Weakly expressive")

ggplot(weakly_expr, aes(x=period, y = change, group=type, color=type)) + geom_point() + geom_line() +
  theme_tufte() +
  scale_y_continuous(labels = scales::percent_format(scale=1), limits = c(-10,145)) +
  labs(y='average change in search volume', color = NULL, title = 'Weakly expressive peaks of mentions: search activity', subtitle = 'Average % change in search volume from the pre-peak search volume') +
  theme(legend.position = "bottom", plot.subtitle = element_text(color='grey')) +
  scale_color_brewer(palette = "Set1")

#moderately expr
mod_expr <- plot_data %>% 
  filter(intensity_level == "Moderately expressive")

ggplot(mod_expr, aes(x=period, y = change, group=type, color=type)) + geom_point() + geom_line() +
  theme_tufte() +
  scale_y_continuous(labels = scales::percent_format(scale=1), limits = c(-10,145)) +
  labs(y='average change in search volume', color = NULL, title = 'Moderately expressive peaks of mentions: search activity', subtitle = 'Average % change in search volume from the pre-peak search volume') +
  theme(legend.position = "bottom", plot.subtitle = element_text(color='grey')) +
  scale_color_brewer(palette = "Set1")

#highly expr
highly_expr <- plot_data %>% 
  filter(intensity_level == "Highly expressive")

ggplot(highly_expr, aes(x=period, y = change, group=type, color=type)) + geom_point() + geom_line() +
  theme_tufte() +
  scale_y_continuous(labels = scales::percent_format(scale=1), limits = c(0,1700)) +
  labs(y='average change in search volume', color = NULL, title = 'Highly expressive peaks of mentions: search activity', subtitle = 'Average % change in search volume from the pre-peak search volume') +
  theme(legend.position = "bottom", plot.subtitle = element_text(color='grey')) +
  scale_color_brewer(palette = "Set1")

#extr expr
extr_expr <- plot_data %>% 
  filter(intensity_level == "Extremely expressive")

ggplot(extr_expr, aes(x=period, y = change, group=type, color=type)) + geom_point() + geom_line() +
  theme_tufte() +
  scale_y_continuous(labels = scales::percent_format(scale=1), limits = c(0,1700)) +
  labs(y='average change in search volume', color = NULL, title = 'Extremely expressive peaks of mentions: search activity', subtitle = 'Average % change in search volume from the pre-peak search volume') +
  theme(legend.position = "bottom", plot.subtitle = element_text(color='grey')) +
  scale_color_brewer(palette = "Set1")
