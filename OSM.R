library(sf)
library(dplyr)

# Get keys for the right features
osm_kv <- read.csv("data/osm_key_values.csv")
osm_kv <- osm_kv %>% filter(!is.na(key))
keys <- unique(osm_kv$key)

# Extract OSM data in our project's bounding box
bbox <- st_sfc(st_point(c(-122.5,47.35)),st_point(c(-122.0,47.8)))
wa_pol <- osmextract::oe_get(bbox,
                             layer = "multipolygons",
                             extra_tags=keys)
wa_pol <- st_make_valid(wa_pol)

# Filter then crop the forest layer
forest <- wa_pol %>% dplyr::filter(landuse %in% c("forest") |
                                                    natural  %in% c("wood") |
                                                    boundary %in% c("forest", "forest_compartment"))
forest <- st_crop(forest,xmin = -122.5, ymin = 47.35, xmax = -121.9, ymax = 47.8)

# Filter then crop the grass layer
grass <- wa_pol %>% dplyr::filter(landuse %in% c("park", "grass", "cemetery", "greenfield", "recreation_ground", "winter_sports")|
                                         (!is.na(golf) & !(golf %in% c("rough","bunker"))) |
                                         amenity %in% c("park") |
                                         leisure %in% c("park", "stadium", "playground", "pitch", "sports_centre", "stadium", "pitch", "picnic_table", "pitch", "dog_park", "playground")|
                                         sport %in% c("soccer")|
                                         power %in% c("substation")|
                                         surface %in% c("grass"))
grass <- st_crop(grass,xmin = -122.5, ymin = 47.35, xmax = -121.9, ymax = 47.8)


# Save these as shapefiles
st_write(forest, "maps/Seattle_forest.shp",append=FALSE)
st_write(grass, "maps/Seattle_grass.shp",append=FALSE)
