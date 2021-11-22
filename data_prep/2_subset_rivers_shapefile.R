library(rgdal); library(raster);

# read shapefile downloaded from Natural Earth at: file:///Users/laurapuckett/Downloads/ne_50m_rivers_lake_centerlines/ne_50m_rivers_lake_centerlines.README.html

rivers_all = readOGR('./data_prep/ne_50m_rivers_lake_centerlines_scale_rank/ne_50m_rivers_lake_centerlines_scale_rank.shp')

states_data = maps::map('state', regions=c('oregon', 'washington','idaho'), fill = T, plot = F)
e1 <- as(extent(states_data$range), 'SpatialPolygons')
rivers_sub = raster::intersect(rivers_all, e1)

saveRDS(rivers_sub, './shiny_app/rivers_sub')
