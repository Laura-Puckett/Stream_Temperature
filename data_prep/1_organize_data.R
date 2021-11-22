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

sites_sub = site_data %>% 
  mutate(huc_cd = as.numeric(huc_cd)) %>%
  filter(end_date>= "2021-08-01" & begin_date <= "2010-04-01") %>%
  filter(count_nu > 1000) %>%
  filter(huc_cd >= 17000000 & huc_cd < 18000000)

stream_temp_f = stream_temp %>% 
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
# create a column where all dates have year 2021 to easily
# plot multiple years of data on top of each other
lubridate::year(stream_temp_f$date_all_2021) = 2021

# ---------------------------------------------------
# 2. Filter Data and Remove Unused Columnns
# --------------------------------------------------
# filter(site_no %in% c(14138720,
#                       1421000) == F)

sites_with_enough_data = stream_temp_f %>%
  filter(year == 2021) %>%
  group_by(site_no) %>%
  dplyr::summarize(count = n()) %>%
  filter(count > 300) %>%
  dplyr::select(site_no)

plotData = stream_temp_f %>% 
  filter(site_no %in% sites_sub$site_no) %>%
  filter(site_no %in% sites_with_enough_data$site_no) %>%
  filter(tempF < 140) # remove really high outlier data for one site

plotData = plotData %>% 
  dplyr::select(site_no, dateTime, tempF, year, month,
                month_day, axis_date_minimal, date_all_2021)

sitesData = sites_sub %>%
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


