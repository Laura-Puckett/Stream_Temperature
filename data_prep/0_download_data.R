# ---------------------------------------------------
# 0. Load Packages, set directory and parameters
# --------------------------------------------------
library(dataRetrieval);
setwd('~/Documents/portfolio/Pacific_Northwest_Heatwave/Stream_Temperature/')

startDate = '2000-01-01'
endDate = '2021-11-01'
states = c("OR","WA","ID")

# ---------------------------------------------------
# 1. Define Functions
# --------------------------------------------------

# function to download site metadata by state
dl_site_data = function(state){
  print(state)
  sites <- whatNWISdata(stateCd = state, parameterCd="00010", siteType="ST")
  saveRDS(sites, paste('./Rdata/sites', state, sep = '_'))
  return(sites)
}

# function to download stream temperature data by state
dl_temp_data = function(state, startDate, endDate){
  print(paste(state, startDate, endDate))
  streamtemp <- readNWISdata(stateCd = state, service="dv", startDate = startDate,
                             endDate = endDate,parameterCd="00010", siteType="ST")
  streamtemp = streamtemp %>%
    dplyr::select(agency_cd, site_no, dateTime, X_00010_00003, tz_cd)
  saveRDS(streamtemp, paste('./Rdata/streamtemp', startDate, endDate, state, sep = '_'))
  
  return(streamtemp)
}

# ---------------------------------------------------
# 1. Download Data
# --------------------------------------------------

# Download Site Metadata
for(state in states){
  # download data or read existing file
  if(file.exists(paste('./Rdata/sites', state, sep = '_'))){
    state_sites = readRDS(paste('./Rdata/sites',  state, sep = '_'))
  }else{
    state_sites = dl_site_data(state)
  }
  # append data from multiple states into single dataframe
  if(state == states[1]){
    site_data = state_sites
  }else{
    site_data = rbind(site_data, state_sites)
    saveRDS(site_data, './Rdata/site_data.rds')
  }
}

# Download Stream Data
for(state in states){
  # download data or read existing file
  if(file.exists(paste('./Rdata/streamtemp', startDate, endDate, state, sep = '_'))){
    state_data = readRDS(paste('./Rdata/streamtemp', startDate, endDate, state, sep = '_'))
  }else{
    state_data = dl_temp_data(state, startDate, endDate)
  }
  # append data from multiple states into single dataframe
  if(state == states[1]){
    temp_data = state_data
  }else{
    temp_data = rbind(temp_data, state_data)
    saveRDS(temp_data, './Rdata/streamtemp_data.rds')
  }
}
