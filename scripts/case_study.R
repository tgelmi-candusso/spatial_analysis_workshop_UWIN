
library(dplyr)
library(osmextract)
library(sf)
library(terra)

#generate buffer areas around camera traps####
coyotes_NAD <- sf::st_transform(coyotes, crs="EPSG:5070")
coyotes_buff <- sf::st_buffer(coyotes_NAD, dist=500)

plot(coyotes_buff)
####estimate road density within buffer ####

#estimate number of trees, mean height of trees and mean radius
#match crs 
coyotes_buff_t <- sf::st_transform(coyotes_buff, crs="EPSG:4326") #might have to save all files already on this transformation otherwise it can take time we dont want to waste during the workshop
st_crs(coyotes_buff_t)
crs(trees)
#crs match
trees_p <- vect("maps/trees_seattle_points_cropped.shp")
tree.int <- intersect(trees_p, vect(coyotes_buff_t)) #has the
plot(tree.int)

tree_numbers <- aggregate(OBJECTID  ~ locationid, data=tree.int, FUN="length") #check proportion of urban gree types
#we could do tree density from this
tree_height <- aggregate(Hgt_Q99  ~ locationid, data=tree.int, FUN="mean") #check proportion of urban gree types
tree_radius <- aggregate(Radius  ~ locationid, data=tree.int, FUN="sum") #check proportion of urban gree types

#estimate proportion of tree type
tree_numbers <- aggregate(Type  ~ locationid, data=tree.int, FUN="length") #check proportion of urban gree types
tree_numbers <- left_join(tree_numbers, buff_area)
tree_numbers$tree_density <-  tree_numbers$Type / tree_numbers$buffer_area_km2

#estimate road segment length 
roads_low_traffic1$length <- sf::st_length(roads_low_traffic1)

#intersect buffers with road segments
car.int <- st_intersection(coyotes_buff, roads_low_traffic1) #has the
car.int$length.int <- sf::st_length(car.int)

#sum all road segment lengths in km within each buffer
car.sum <- aggregate(length.int ~ locationid, data = car.int, FUN = sum) #total length of roads in  buffer
car.sum<- car.sum %>% mutate(car_length_km = round(as.numeric(length.int)/1000)) #conver to km

#estimate buffer area in km2
coyotes_buff$buffer_area_km2 <- as.numeric(st_area(coyotes_buff))/1000000 #in km2 units
buff_area <- coyotes_buff %>% select("locationid", "buffer_area_km2")

car.sum <- left_join(car.sum, coyotes_buff) #left_join in case some sites are missing in the main map

#do the math for road density (total length/total area)
car.sum <- car.sum %>% mutate(road_density_km2 = (car_length_km/buffer_area_km2)*100) #Road density is the ratio of the length of the country's total road network to the country's land area per 100 square kilometer
road_density <- car.sum %>% dplyr::select(locationid, road_density_km2)

## Estimate total forest and grass surface area ####
gra.int <- st_intersection(grass, coyotes_buff) #has the
gra.int <- gra.int %>% mutate(grass_area_km2.int = as.numeric(st_area(gra.int))/1000^2) #recalc area with the new segments
grass_area <- aggregate(grass_area_km2.int ~ locationid, data = gra.int, FUN = "sum")

for.int <- st_intersection(forest, coyotes_buff) #has the
for.int <- for.int %>% mutate(forest_area_km2.int = as.numeric(st_area(for.int))/1000^2) #recalc area with the new segments
forest_area <- aggregate(forest_area_km2.int ~ locationid, data = for.int, FUN = "sum")


### Now we will get analyse the NDVI and built values within the buffer and decide which stats works better for us
#let's use what would be considered zonal statistics in arcgis
names(NDVI) <- "NDVI"
names(BUILT) <- "BUILT"
NDVI <- ifel(NDVI<0, NA, NDVI)
coyotes_buff_t$NDVI_mean <- extract(NDVI, coyotes_buff_t, fun='mean', na.rm=TRUE, exact=TRUE)[,2]

BUILT <- ifel(BUILT<0, NA, BUILT)
coyotes_buff_t$BUILT_mean <- extract(BUILT, coyotes_buff_t, fun='mean', na.rm=TRUE, exact=TRUE)[,2]
#or  ex <- extract(s, poly, fun='mean', na.rm=TRUE, exact=TRUE)

#does NDVI reflect tree density? #coastal sites have lower NDVI because the mean is affected by any water within the buffer
#we need to exclude water, that means using a cookie-cutter polygon to mask the raster, and convert those low NDVI cells to NA. 

tree_den <- tree_numbers %>% select("locationid", "tree_density")
ndvi_values <- coyotes_buff_t %>% as.data.frame() %>% select("locationid", "NDVI_mean")
comp_table <- left_join(coyotes_buff_t, tree_numbers, by = "locationid")
comp_table <- left_join(coyotes_buff_t, tree_radius, by = "locationid")

plot(comp_table$NDVI_mean, comp_table$Radius)


