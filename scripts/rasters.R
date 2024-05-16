library(terra)

#rasters, numerical rasters
## downloading NDVI seattle
#https://earthexplorer.usgs.gov/
## downloading GHL building density
#https://human-settlement.emergency.copernicus.eu/download.php

# I previously cropped them to Washington State to reduce computational needs during the workshop
NDVI <-rast("maps/NDVI_Seattle.tif")
BUILT <- rast("maps/BUILT_Seattle.tif")
LULC <- rast("maps/LULC_Seattle.tif")


#transform to crs we are using
NDVI <- project(NDVI, "EPSG:4326")
BUILT <- project(BUILT, "EPSG:4326")
LULC <- project(LULC, "EPSG:4326")


#crop to seattle
r <- rast(resolution=0.001, extent=c(-122.4349, -122.2456, 47.60144, 47.73419 ))
NDVI_c <- crop(NDVI, r)
BUILT_c <- crop(BUILT, r)
LULC_c <- crop(LULC, r)

plot(NDVI_c)
plot(BUILT_c)
plot(LULC_c)

#we can stack them, but the objects extent dont match perfectly
c(NDVI_c, BUILT_c)

NDVI_c <- project(NDVI_c, BUILT_c)

#now we can stack them
stack <- c(NDVI_c, BUILT_c)

#resample to less coarse, we can do this directly to the stack of rasters
#set template raster with resolution and extent wanted
r <- rast(resolution=0.001, extent=c(-122.4349, -122.2456, 47.60144, 47.73419 ))
#resample to the resolution in r, method can be changed 
stack <- resample(stack, r, method="bilinear")
plot(stack)


#do math with rasters, nonesense example
stack_diff <- NDVI_c - BUILT_c
plot(stack_diff)

#save raster

## rasters with categorical data , e.g. land cover maps

#reclassify 

#we generate a matrix
ctoc <- read.csv("C:/Users/tizge/Documents/RedWolf/reclass_conus2008toconus1938.csv", )
ctoc1 <-as.matrix(ctoc[,1:2])
LULC_c_rec <- classify(LULC_c,ctoc1)
LULC_c_rec <- as.factor(LULC_c_rec)
plot(c(LULC_c, LULC_c_rec))

#let's change colors on the new map we made
library(RColorBrewer)
cols <- brewer.pal(9, "RdYlGn")
pal <- colorRampPalette(cols)
plot(c(LULC_c, LULC_c_rec), col=pal(12))
plot(LULC_c_rec, col=pal(12))

#let's make a better map using ggplot
#first convert raster to data frame and fix it a bit 
LULC_df <- as.data.frame(LULC_c_rec, xy = TRUE)
colnames(LULC_df)<- c("x","y","LULC")
LULC_df$LULC_num <- as.numeric(LULC_df$LULC)
head(LULC_df)

#this works with numerical values
ggplot(data = LULC_df) +
  geom_raster(aes(x = x, y = y, fill = LULC_num)) +
  scale_fill_viridis_c() +
  theme_void() +
  theme(legend.position = "bottom")+
  coord_equal() 


#with factorial values, we can define colors and labels
ggplot(data = LULC_df) +
  geom_raster(aes(x = x, y = y, fill = LULC)) +
  scale_fill_manual(values=c("#088da5", "#EC5C3B", "#F88A50", 
                             "#D4ED88","#AFDC70", "#83C966", "#51B25D", "#1A9850", 
                             "#FDB768","#FDDB87", "#FEF3AC",
                             "#F1F9AC", "#D4ED88"),
                    labels=c("open water",
                             "urban/developed",
                             "sand",
                             "deciduous forest",
                             "evergreen forest",
                             "mixed forest",
                             "grassland", 
                             "shrubland",
                             "cultivated cropland",
                             "hay/pasture",
                             "herbaceous wetland",
                             "woody wetland")) +
  theme_void() +
  theme(legend.position = "right")+
  coord_equal() 

