library(dplyr)
library(osmextract)
library(sf)
library(terra)

#shapefiles can be read either through the sf package or the terra package, we will use both here because sometimes one is faster than the other. so it's important to know how to use both.

#### Start with adding a shapefile we obtained from the web
### add external shapefile from Seattle open data https://data-seattlecitygis.opendata.arcgis.com/
##Seattle Tree Canopy 2021 Tree Crowns 
#layer made from Lidar data
#https://seattle.gov/documents/Departments/OSE/Urban%20Forestry/2021%20Tree%20Canopy%20Assessment%20Report_FINAL_230227.pdf
trees <- st_read("Tree_Canopy/Seattle_Tree_Canopy_2021_Tree_Crowns.shp")

#check its projection. 
crs(trees) #it's WGS84
# we need them in Albers equal-distace
# it’s impossible to show the surface of the Earth accurately on a flat map, therefore people resorted to projections:
# Different projections distort different areas, maps have to match the same projection.
# Some projections are better for measuring distances e.g. the Albers equal-area projection.
#projections are identified by the code EPSG.
#We will convert from WGS84 "EPSG:4326" to Albers equal-area "EPSG:5070" when we need to measure distances


#check the information contained within
str(trees) #structure of the dataset

#plot a subset to check the layer
plot(trees[1:10,1]) #polygon shapes based on sites, lets convert them into points so we can get density of trees later on

#interctive plot
plet(trees(1:10,1))

#convert polygons to centroids (only a few - time constraint)
trees_p <- st_centroid(trees[1:100,]) # we can also avoid this and just count the number of trees in total and later on within the buffer

#count total number of trees
total_trees <- nrow(trees)  #total number of trees, each row is one tree in this shapefile

#count number of features by attribute (number of trees per tree type)
tree_numbers <- aggregate(OBJECTID  ~ Type, data=trees, FUN="length") #check proportion of urban gree types

#let's do some match and create new attributes 
#information inside would allow us to check the total cover, if we knew the units
# if each tree has a cover area of πr2, crown area given the radius, we can estimate the total area in the city covered by tree branches
trees$cover <- (pi*((trees$Radius*0.0254)^2))  #converted from inch2 to in metres2
sum(trees$cover)

#do some stats with the layer's attributes
hist(trees$Radius)
mean_radius <- aggregate(Radius  ~ Type, data=trees, FUN="mean") #check proportion of urban gree types
max_height <- aggregate(Height  ~ Type, data=trees, FUN="max") #Maximum tree height per tree type
sum_height <- aggregate(Height  ~ Type, data=trees, FUN="sum") #if we piled all trees how far into the atmosphere would we go?

#let's separate the layer into two, one with coniferous and one with deciduous
trees_con <- trees %>% dplyr::filter(Type == "Coniferous")
trees_dec <- trees %>% dplyr::filter(Type == "Deciduous")

#let's save the tree layer with just the heigh attribute into a dataframe and save it as csv.
trees.red<-trees %>% dplyr::select("","")
trees_df <- as.data.frame(trees.red)
write.csv(trees_df, "trees_df.csv")

#convert trees layer to vector, maybe it will be faster to work with for certain things
vect(trees)

sf_use_s2(FALSE)

## extract polygons from OSM database

# key values from characterized set of urban features in manuscript

osm_kv <- read.csv("C:/Users/tizge/Documents/StructuralconnectivityDB/osm_key_values.csv") #table with the key-value pairs to be extracted I nded up doing it by hand though, so we can hard code it
colnames(osm_kv)
osm_kv <- osm_kv %>% filter(!is.na(key))
keys <- unique(osm_kv$key)

#get forest(dense vegetation) stands, grass stands, and residential roads from the OSM database 

Seattle <- osmextract::oe_get("Seattle",
                             layer = "multipolygons", 
                             extra_tags=keys)
forest <- Seattle %>% dplyr::filter(landuse %in% c("forest")|
                                              natural  %in% c("wood")|
                                              boundary %in% c("forest", "forest_compartment"))

grass <- Seattle %>% dplyr::filter(landuse %in% c("park", "grass", "cemetery", "greenfield", "recreation_ground", "winter_sports")|
                                              (!is.na(golf) & !(golf %in% c("rough","bunker"))) |
                                              amenity %in% c("park") |
                                              leisure %in% c("park", "stadium", "playground", "pitch", "sports_centre", "stadium", "pitch", "picnic_table", "pitch", "dog_park", "playground")|
                                              sport %in% c("soccer")|
                                              power %in% c("substation")|
                                              surface %in% c("grass"))
grass<-sf::st_make_valid(grass) #eliminates self intersecting polygons

#linear features
Seattle_l <- osmextract::oe_get("Seattle",
                              layer = "lines", 
                              extra_tags=keys)
roads_low_traffic1	<- Seattle_l %>% dplyr::filter(highway	%in% c("residential", "rest_area", "busway"))



#### CHECK PROJECTION ####
crs(grass) #= WGS84, EPSG: 4326

grass <- sf::st_transform(grass, crs="EPSG:5070") #we'll use the North America focuses Albers equal-area
forest <- sf::st_transform(forest, crs="EPSG:5070") 
roads_low_traffic1 <- sf::st_transform(roads_low_traffic1, crs="EPSG:5070") 


## ESTIMATE length of roads (before buffering into polygons)
#intersect with buffer
roads_low_traffic1$length <- sf::st_length(roads_low_traffic1)

#transform to lines to polygons
#generate buffer along streets so we get polygons
roads_low_traffic <- sf::st_buffer(roads_low_traffic1, dist=12) #buffer to 12 meters
plot(roads_low_traffic[1:1000,1])

#estimate surface area of forest and grass
#convert to equal area projection
forest <- forest %>% mutate(forest_area_km2 = as.numeric(st_area(forest))/1000000)
total_forest <- sum(forest$forest_area_km2)

#estimate area of grass and then estimate area of the different types of leisure urban areas
grass <- grass %>% mutate(grass_area_km2 = as.numeric(st_area(grass))/1000^2)
freq_table <- aggregate(grass_area_km2 ~ leisure, data=grass, FUN="sum") #check proportion of urban gree types
#estimate proportion of grass type

##save shapefiles
sf::st_write(forest, "E:/OSM_in_R/Seattle_forest.shp")
sf::st_write(grass, "E:/OSM_in_R/Seattle_grass.shp")
sf::st_write(roads_low_traffic, "E:/OSM_in_R/Seattle_roads.shp")

##using terra , faster for some things, some functions to revise, next step: to integrate this into the workflow, using them to further manipulate osm data
#let's convert the spatial dataframe into a vector from terra
vect(trees)
#extract attribute
p$NAME_2
#subset 
p[, "NAME_2"]
#add attribute
p$lets <- sample(letters, nrow(p))
#merge vector layers
pm <- merge(p, dfr, by.x=c('NAME_1', 'NAME_2'), by.y=c('District', 'Canton'))
#select records by attributes
i <- which(p$NAME_1 == 'Grevenmacher')
#aggregate polygons by 
pa <- aggregate(p, by='NAME_1')
#without dissolving borders
zag <- aggregate(z, dissolve=FALSE)
#erase part of vectors
e <- erase(p, z2)
#intersect polygons: #intersect returns new (intersected) geometries with the attributes of both input datasets.
i <- intersect(p, z2)
#crop a polygon 
e <- ext(6, 6.4, 49.7, 50)
pe <- crop(p, e)
#get the union of two polygons # union appends the geometries and attributes of the input. 
u <- union(p, z)
#cover returns the intersection and appends the other geometries and attributes of both datasets.
cov <- cover(p, z[c(1,4),])
#dfference between two polygon layers
dif <- symdif(z,p)
#query polygon areas from raster
extract(spts, p)


#for case study
# 4) estimate distance to closest polygon from point
# 4) generate buffer polygons from the points and estimate surface area from polygons


