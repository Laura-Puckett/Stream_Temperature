# ---------------------------------------------------
# 0. Load Packages, set directory and parameters
# --------------------------------------------------

library(dplyr)

setwd('~/Documents/portfolio/Pacific_Northwest_Heatwave/Stream_Temperature/')
startDate = '2000-01-01'
endDate = '2021-11-01'

# ---------------------------------------------------
# 1. Read Data
# --------------------------------------------------
stream_temp = readRDS('./data_prep/Rdata/streamtemp_data.rds')
site_data = readRDS('./data_prep/Rdata/site_data.rds')

# ---------------------------------------------------
# 2. Organize Data
# --------------------------------------------------
site_data %>% head()

stream_temp = stream_temp %>% 
  # convert Celsius to Fahrenheit
  rename(tempC = X_00010_00003) %>% 
  mutate(tempF = tempC*(9/5)+32,
         year = lubridate::year(dateTime),
         month = lubridate::month(dateTime),
         month_name = lubridate::month(dateTime, label = T),
         day = lubridate::day(dateTime),
         # reformat dates for plot axes
         month_day = paste0(month_name, day, sep = "-"),
         axis_date_minimal = ifelse(day %in% c(1,15), month_day,""),
         date_all_2021 = dateTime)
# create a dummy column with 2021 as the year for all to easily
# plot multiple years of data on top of each other
lubridate::year(stream_temp$date_all_2021) = 2021

# ---------------------------------------------------
# 2. Filter Data and Remove Unused Columnns
# --------------------------------------------------
sites_with_enough_2021_data = stream_temp %>%
  filter(year == 2021) %>%
  group_by(site_no) %>%
  dplyr::summarize(count = n()) %>%
  filter(count > 300) %>%
  dplyr::select(site_no)

# subset for sites with desired data
sites_sub = site_data %>%   
  filter(site_no %in% sites_with_enough_2021_data$site_no) %>%
  mutate(huc_cd = as.numeric(huc_cd)) %>%
  filter(end_date>= "2021-08-01" & begin_date <= "2010-04-01") %>%
  filter(count_nu > 1000) %>% 
  filter(huc_cd >= 17000000 & huc_cd < 18000000) # Colombia River Basin hucs


plotData = stream_temp %>% 
  filter(site_no %in% sites_sub$site_no) %>%
  filter(tempF < 140) # remove really high outlier data for one site

plotData = plotData %>% 
  dplyr::select(site_no, dateTime, tempF, year, month,
                month_day, axis_date_minimal, date_all_2021)

sitesData = sites_sub %>%
  filter(site_no %in% sites_with_enough_2021_data$site_no) %>%
  dplyr::select(site_no, station_nm, dec_lat_va, dec_long_va)

data_for_plot1 = plotData %>%
  filter(dateTime < '2021-09-30' & dateTime > '2021-04-01') %>%
  inner_join(sitesData %>% dplyr::select(site_no, station_nm)) %>%
  unique() %>%
  group_by(site_no)


data_for_plot2 = plotData %>%
  filter(month >= 4 & month <= 9) %>%
  mutate(color_group = "other years",
         color_group = ifelse(year == 2021, 2021, color_group),
         color_group = ifelse(year == 2015, 2015, color_group)) %>%
  inner_join(sitesData %>% dplyr::select(site_no, station_nm)) %>%
  unique() %>%
  group_by(year)

# ---------------------------------------------------
# 2. Write output files
# --------------------------------------------------
saveRDS(plotData, './data_prep/Rdata/plotData.rds')
saveRDS(sitesData, './shiny_app/sitesData.rds')
saveRDS(data_for_plot1, './shiny_app/data_for_plot1')
saveRDS(data_for_plot2, './shiny_app/data_for_plot2')
