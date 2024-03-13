# Load libraries
library(sf)
library(ggplot2)

# Import data
# Introduce the data set: All coyote and raccoon captures in Seattle spring 2019
# through early 2021.
# Talk about read.csv. This should be familiar
captures.table <- read.csv("captures.csv")


# Introduce the concept of spatial data. Point out that
# the data in captures.table has two columns, but those could be any old
# number and we need to convert them to a spatial data type.
# This section will also introduce the idea of a CRS
# Specifically introduce 4326 and 26910.
# Tell people how to find their UTM and state plane (others?)

# Convert to spatial data frame
captures.spatial <- st_as_sf(captures.table,
                             coords = c("longitude","latitude"), 
                             crs = 4326)
    
# Transform to UTM
captures <- st_transform(captures.spatial,26910)

# All of of the above in one step
# Point out that this is a common procedure, to do in one step
# 1. Import non-spatial data
# 2. Make it spatial using the CRS in which it was saved
# 3. Reproject it into the CRS you want to use for your analysis
captures <- read.csv("captures.csv") %>%
  st_as_sf(coords = c("longitude","latitude"), crs = 4326) %>%
  st_transform(26910)
  
# Show all the points on a map
# ggplot should be familiar but the geom_sf() argument will be new.
ggplot(captures) + geom_sf()

# Make a map of coyote captures on a google map
# Inlcude some preamble about breaking down this step into substeps
# 1. Just the coyotes
# 2. How to get the google background
# 3. Putting it all together