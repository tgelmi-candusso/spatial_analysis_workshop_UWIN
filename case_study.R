

#generate buffer areas around camera traps####
coyotes_NAD <- sf::st_transform(coyotes, crs="EPSG:5070")
coyotes_buff <- sf::st_buffer(coyotes_NAD, dist=500)
plot(coyotes_buff)
####estimate road density within buffer ####

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

#estimate number of trees, mean height of trees and mean radius
#match crs 
trees <- sf::st_transform(trees, crs="EPSG:5070") #might have to save all files already on this transformation otherwise it can take time we dont want to waste during the workshop
tree.int <- st_intersection(trees, coyotes_buff) #has the

tree_numbers <- aggregate(OBJECTID  ~ locationid, data=tree.int, FUN="length") #check proportion of urban gree types
#we could do tree density from this
tree_height <- aggregate(Height  ~ locationid, data=tree.int, FUN="mean") #check proportion of urban gree types
tree_radius <- aggregate(Radius  ~ locationid, data=tree.int, FUN="mean") #check proportion of urban gree types

#estimate proportion of tree type
tree_numbers <- aggregate(Type  ~ locationid, data=tree.int, FUN="length") #check proportion of urban gree types

### Now 