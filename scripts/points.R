# Load libraries
library(sf)
library(dplyr)
library(ggmap)
library(ggplot2)

# Import data
# Introduce the data set: All coyote and raccoon captures in Seattle spring 2019
# through early 2021.
# Talk about read.csv. This should be familiar
captures.table <- read.csv("data/captures.csv")


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
# Will only plot on google map if it's in lat/lon, so we need to think about
# where we introduce this.
captures.utm <- st_transform(captures.spatial,26910)

# All of of the above in one step
# Point out that this is a common procedure, to do in one step
# 1. Import non-spatial data
# 2. Make it spatial using the CRS in which it was saved
# 3. Reproject it into the CRS you want to use for your analysis
captures <- read.csv("data/captures.csv") %>%
  st_as_sf(coords = c("longitude","latitude"), crs = 4326)

captures.utm <- read.csv("data/captures.csv") %>%
  st_as_sf(coords = c("longitude","latitude"), crs = 4326) %>%
  st_transform(26910)
  
# Show all the points on a map
# ggplot should be familiar but the geom_sf() argument will be new.
ggplot(captures) + geom_sf()

# Make a map of coyote captures on a google map
# Include some preamble about breaking down this step into substeps
# 1. Just the coyotes
coyotes <- filter(captures, speciesname == "Canis latrans") %>%
  group_by(locationid) %>%
  summarize(detections = n())

# 2. How to get the google background
# Use an API key for the 'uwin-mapping' project that I created for this
# Describe in the Rmd how to get your own
# setup API key to use `ggmap`
my_api <- 'AIzaSyBt73bzxdvlS6ioit4OTCaIE6SrZJ9aWnA'
register_google(key = my_api)

# use package function `get_map` to extract relevant mapping data using a regions names or bounding box with coordinate information (this allows us to be more specific)
seattle <- get_map("seattle", source= "google", api_key = my_api)
ggmap(seattle)

# With a different boundary
seattle <- get_map(location = c(left = -122.5, bottom = 47.4,
                                right = -122.0, top = 47.8),
                   source ="google", api_key = my_api)
ggmap(seattle)

# 3. Putting it all together
ggmap(seattle) +
  geom_sf(data = coyotes, inherit.aes = FALSE, aes(size = detections)) +
  ggtitle("Coyote detections") +
  labs(size = "Detection frequency") +
  scale_size_continuous(breaks=seq(100, 500, by=100))
# This is cutting off a few of the points, so I still need to tinker with it.

# Now ask them to do the same for raccoons
# Hide this using the method from the UWIN tutorial
# https://github.com/urbanwildlifeinstitute/UWIN_tutorials/blob/main/tutorials/Detection%20Mapping/detection_mapping.md?plain=1
# Starting at line 351
raccoons <- filter(captures, speciesname == "Procyon lotor") %>%
  group_by(locationid) %>%
  summarize(detections = n())

# 2. How to get the google background
# ??? Include this? It requires a complicated step of getting a google API key
# 3. Putting it all together
ggmap(seattle) +
  geom_sf(data = raccoons, inherit.aes = FALSE, aes(size = detections)) +
  ggtitle("Raccoon detections") +
  labs(size = "Detection frequency") +
  scale_size_continuous(breaks=seq(100, 500, by=100))
