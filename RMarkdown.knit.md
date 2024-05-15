---
title: 'Spatial Analysis in R'
author: "M. Jordan and TA Gelmi-Candusso"
date: "2024-05-15"
output:
  pdf_document: default
  html_document: default
---



#  Spatial data  

Spatial data is any type of data that directly or indirectly references a specific geographical area or location. These can be, for example, geographic features on the landscape or environmental properties of an area such as temperature or air quality.

Spatial data can be continuous or discrete just like regular data, and in both cases it can be represented as a vector or a raster. The main difference being vector data uses points and lines to represent spatial data, while raster data represents data uses pixelled or gridded, where each pixel/cell represents a specific geographic location and the information therein. Raster data will be heavily influenced by the size of the pizels/cells, i.e. resolution.

![Figure showing difference between vectors and rasters](images/vectorvsraster_from_rsgislearn_blogspot_com.png "Vector data"){width=60%} 

Both vector and raster data are planar representations of the world, a 3-dimensional sphere, and as such are not perfect copies. Depending on how the planar representation is created it will distort more or less certain areas of the world, therefore many representations exist. These are called projections, as the representations project the 3 dimensional spheric image into a planar, 2-dimensional image.  

![Figure showing difference between vectors and rasters](images/map_projections.png "Vector data"){width=60%} 

Maps with different projections are not comparable and cannot be overlaid. Therefore, we need to make sure we work always on the same projection when using more maps. In addition, projections can have different coordinate systems and therefore when extracting distance information from maps, some projections (i.e. metric based projections e.g. Mercator projection or the Albers equal-area projection) will give a more accurate representation of the distance than others. To work around this, we can transform our maps between projections, in R we use EPSG codes to do this.

##  Vector data  

In this section we will read and manipulate vector data in R. 
* Vector data represents real world features within the GIS environment. A feature is anything you can see on the landscape. 
* Vector data is commonly stored as a shapefile and can contain either point data or polygon data. 
* Data contains information attached to each feature, we call these attributes.  

Features can be points (red) representing specific x,y locations, such as a trees or camera sites; polygons (white) representing areas, such as forests or residential areas; and lines (yellow/green and blue) representing continuous linear features, such as roads or rivers

![Figure showing polygons, points and lines in the landscape](images/vector_data_image_from_docs_qgis_org.png "Vector data"){width=80%}  

Vector data reads as a data frame would, each row is a feature and each column is an attribute, and contains usually a geometry column where the xy coordinates for the shapes are stored. Plotting these data will plot the points or shapes in the map using the xy coordinates stored for each feature.   


```
## Simple feature collection with 6 features and 3 fields
## Geometry type: POINT
## Dimension:     XY
## Bounding box:  xmin: -122.3607 ymin: 47.64339 xmax: -122.3607 ymax: 47.64339
## Geodetic CRS:  WGS 84
##     speciesname    locationid                date                   geometry
## 1 Procyon lotor SEWA_N01_DRP2 2019-07-03 05:02:21 POINT (-122.3607 47.64339)
## 2 Procyon lotor SEWA_N01_DRP2 2019-07-03 06:04:45 POINT (-122.3607 47.64339)
## 3 Procyon lotor SEWA_N01_DRP2 2019-07-03 06:12:10 POINT (-122.3607 47.64339)
## 4 Procyon lotor SEWA_N01_DRP2 2019-07-03 06:13:16 POINT (-122.3607 47.64339)
## 5 Procyon lotor SEWA_N01_DRP2 2019-07-05 03:55:53 POINT (-122.3607 47.64339)
## 6 Procyon lotor SEWA_N01_DRP2 2019-07-05 04:05:21 POINT (-122.3607 47.64339)
```
Packages used to read an manipulate data include the sf package, that reads the shapefile as a spatial data frame, and the terra package that reads the shapefiles as a Spatvector, previously there was also the raster package, but we will try to avoid it as it has been deprecated.  


```r
library(sf)
library(terra)
```

### Vector data: points

Point data can be obtained directly from a shapefile or a csv file where each row is a feature. In this case we will work with camera trap site data and the information collected at each site, i.e. point.

The camera trap sites here are located in Seattle, and have captured coyote and raccoon presence and absence from the 2019 spring season to the 2021 winter season.

The data is stored as a data frame in a csv. 


```r
captures.table <- read.csv("data/captures.csv")
print(head(captures.table))
```

```
##     speciesname    locationid                date latitude longitude
## 1 Procyon lotor SEWA_N01_DRP2 2019-07-03 05:02:21 47.64339 -122.3607
## 2 Procyon lotor SEWA_N01_DRP2 2019-07-03 06:04:45 47.64339 -122.3607
## 3 Procyon lotor SEWA_N01_DRP2 2019-07-03 06:12:10 47.64339 -122.3607
## 4 Procyon lotor SEWA_N01_DRP2 2019-07-03 06:13:16 47.64339 -122.3607
## 5 Procyon lotor SEWA_N01_DRP2 2019-07-05 03:55:53 47.64339 -122.3607
## 6 Procyon lotor SEWA_N01_DRP2 2019-07-05 04:05:21 47.64339 -122.3607
```
The coordinates are stored in the latitude and longitude, to be able to observe these points in the map, and extract environmental information based on their location, we will have to convert it to a spatial data frame object. We will use the st_as_sf() function from the sf package and we will specify the projection (crs). How do we know which projection our data is in? 

<>(This section will also introduce the idea of a CRS. Specifically introduce 4326 and 26910. Tell people how to find their UTM and state plane (others?))



```r
captures.spatial <- st_as_sf(captures.table,
                     coords = c("longitude","latitude"), 
                     crs = 4326)
print(head(captures.spatial))
```

```
## Simple feature collection with 6 features and 3 fields
## Geometry type: POINT
## Dimension:     XY
## Bounding box:  xmin: -122.3607 ymin: 47.64339 xmax: -122.3607 ymax: 47.64339
## Geodetic CRS:  WGS 84
##     speciesname    locationid                date                   geometry
## 1 Procyon lotor SEWA_N01_DRP2 2019-07-03 05:02:21 POINT (-122.3607 47.64339)
## 2 Procyon lotor SEWA_N01_DRP2 2019-07-03 06:04:45 POINT (-122.3607 47.64339)
## 3 Procyon lotor SEWA_N01_DRP2 2019-07-03 06:12:10 POINT (-122.3607 47.64339)
## 4 Procyon lotor SEWA_N01_DRP2 2019-07-03 06:13:16 POINT (-122.3607 47.64339)
## 5 Procyon lotor SEWA_N01_DRP2 2019-07-05 03:55:53 POINT (-122.3607 47.64339)
## 6 Procyon lotor SEWA_N01_DRP2 2019-07-05 04:05:21 POINT (-122.3607 47.64339)
```

We want our data to be in the NAD83 projection, because we need our data in the UTM coordinate system to be compatible with google map 
<>(I dont know if I understood correctly the comment below but wrote a draft anyways.)
<>( Transform to UTM. Will only plot on google map if it's in lat/lon, so we need to think about where we introduce this.)


```r
captures.utm <- st_transform(captures.spatial, crs = 26910)
print(head(captures.utm))
```

```
## Simple feature collection with 6 features and 3 fields
## Geometry type: POINT
## Dimension:     XY
## Bounding box:  xmin: 548015.5 ymin: 5276863 xmax: 548015.5 ymax: 5276863
## Projected CRS: NAD83 / UTM zone 10N
##     speciesname    locationid                date                 geometry
## 1 Procyon lotor SEWA_N01_DRP2 2019-07-03 05:02:21 POINT (548015.5 5276863)
## 2 Procyon lotor SEWA_N01_DRP2 2019-07-03 06:04:45 POINT (548015.5 5276863)
## 3 Procyon lotor SEWA_N01_DRP2 2019-07-03 06:12:10 POINT (548015.5 5276863)
## 4 Procyon lotor SEWA_N01_DRP2 2019-07-03 06:13:16 POINT (548015.5 5276863)
## 5 Procyon lotor SEWA_N01_DRP2 2019-07-05 03:55:53 POINT (548015.5 5276863)
## 6 Procyon lotor SEWA_N01_DRP2 2019-07-05 04:05:21 POINT (548015.5 5276863)
```
Let's observe the spatial distribution of the points by plotting them using the ggplot2 package. The geom_sf() function will allow us to plot the spatial data frame object. 


```r
library(ggplot2)
ggplot(captures.utm) + geom_sf()
```

![](RMarkdown_files/figure-latex/unnamed-chunk-5-1.pdf)<!-- --> 

There is no basemap in this plot, we want to add a reference so we can easily distinguish between locations. We will use google maps for this, first we load the ggmap package and register an api from google.
<>(Use an API key for the 'uwin-mapping' project that I created for this. <>(Describe in the Rmd how to get your own setup API key to use)


```r
library(ggmap)
my_api <- 'AIzaSyBt73bzxdvlS6ioit4OTCaIE6SrZJ9aWnA'
register_google(key = my_api)
```

We then get the map relevant to our region using the get_map() function. This can be done both using a bounding box with coordinate information if we want a specific study area, or just the city's name. 


```r
seattle <- get_map("seattle", source= "google", api_key = my_api)
ggmap(seattle)
```

![](RMarkdown_files/figure-latex/unnamed-chunk-7-1.pdf)<!-- --> 

If we use a bounding box, the code will look like this:


```r
seattle <- get_map(location = c(left = -122.5, bottom = 47.4,
                                right = -122.0, top = 47.8),
                   source ="google", api_key = my_api)
ggmap(seattle)
```

![](RMarkdown_files/figure-latex/unnamed-chunk-8-1.pdf)<!-- --> 

Now we can plot our camera site locations on the Seattle map
<>(note the original crs works with google, not the utm.)


```r
ggmap(seattle) +
  geom_sf(data=captures.spatial, inherit.aes = FALSE)
```

![](RMarkdown_files/figure-latex/unnamed-chunk-9-1.pdf)<!-- --> 
Now lets plot on a map the coyotes captured at each the camera trap sites. We will filter the data based on species name, using the dplyr package, and count detections at each site. We will then plot using the function seen above, but setting point size based on the number of detections at each site.


```r
library(dplyr)
coyotes <- filter(captures.spatial, speciesname == "Canis latrans") %>%
  group_by(locationid) %>%
  summarize(detections = n())
ggmap(seattle) +
  geom_sf(data = coyotes, inherit.aes = FALSE, aes(size = detections)) +
  ggtitle("Coyote detections") +
  labs(size = "Detection frequency") +
  scale_size_continuous(breaks=seq(100, 500, by=100))
```

![](RMarkdown_files/figure-latex/unnamed-chunk-10-1.pdf)<!-- --> 

Now try to do the same for raccoons. <>(we can hide code below using echo=FALSE, but depends on how we knit this document, maybe not a good idea for the pdf)


```r
raccoons <- filter(captures.spatial, speciesname == "Procyon lotor") %>%
  group_by(locationid) %>%
  summarize(detections = n())
ggmap(seattle) +
  geom_sf(data = raccoons, inherit.aes = FALSE, aes(size = detections)) +
  ggtitle("Coyote detections") +
  labs(size = "Detection frequency") +
  scale_size_continuous(breaks=seq(100, 500, by=100))
```

![](RMarkdown_files/figure-latex/unnamed-chunk-11-1.pdf)<!-- --> 

### Vector data: lines

We will look into vector data in the form of lines using the TIGER database for Washington, composed of primary and secondary roads. The spatial object will be read in the same way as we did the points, but in this case we will load directly the shapefile containing the features, downloaded from [here](https://catalog.data.gov/dataset/tiger-line-shapefile-2019-state-washington-primary-and-secondary-roads-state-based-shapefile)

The dataset contains 6 attributes (fields) for each feature.


```r
roads <- st_read("maps/roads/tl_2019_53_prisecroads.shp")
```

```
## Reading layer `tl_2019_53_prisecroads' from data source 
##   `C:\Users\tizge\Documents\Spatial Analysis in R Workshop\spatial_analysis_workshop_UWIN\maps\roads\tl_2019_53_prisecroads.shp' 
##   using driver `ESRI Shapefile'
## Simple feature collection with 2912 features and 4 fields
## Geometry type: LINESTRING
## Dimension:     XY
## Bounding box:  xmin: -124.6384 ymin: 45.55945 xmax: -117.0359 ymax: 49.00241
## Geodetic CRS:  NAD83
```

```r
print(head(roads))
```

```
## Simple feature collection with 6 features and 4 fields
## Geometry type: LINESTRING
## Dimension:     XY
## Bounding box:  xmin: -124.0058 ymin: 46.32205 xmax: -119.9736 ymax: 47.845
## Geodetic CRS:  NAD83
##        LINEARID          FULLNAME RTTYP MTFCC                       geometry
## 1  110569183105 State Rte 109 Byp     S S1200 LINESTRING (-123.9242 46.98...
## 2 1102219128828     US Hwy 97 Alt     U S1200 LINESTRING (-120.0899 47.83...
## 3 1102219128829     US Hwy 97 Alt     U S1200 LINESTRING (-120.3242 47.47...
## 4 1105007792960    US Hwy 101 Alt     U S1200 LINESTRING (-124.0055 46.33...
## 5 1103730584015     US Hwy 97 Alt     U S1200 LINESTRING (-119.9736 47.84...
## 6 1105008001942    US Hwy 101 Alt     U S1200 LINESTRING (-124.0058 46.32...
```
Let's plot the dataset to see how it looks, we will only plot one of the attributes, otherwise it will plot one map for each attribute


```r
plot(roads[,1])
```

![](RMarkdown_files/figure-latex/unnamed-chunk-13-1.pdf)<!-- --> 

Again, this dataset can be converted to a data frame, this is useful when dealing with large vector data that may be slow to manage.


```r
roads.df <- as.data.frame(roads)
print(head(roads.df))
```

```
##        LINEARID          FULLNAME RTTYP MTFCC                       geometry
## 1  110569183105 State Rte 109 Byp     S S1200 LINESTRING (-123.9242 46.98...
## 2 1102219128828     US Hwy 97 Alt     U S1200 LINESTRING (-120.0899 47.83...
## 3 1102219128829     US Hwy 97 Alt     U S1200 LINESTRING (-120.3242 47.47...
## 4 1105007792960    US Hwy 101 Alt     U S1200 LINESTRING (-124.0055 46.33...
## 5 1103730584015     US Hwy 97 Alt     U S1200 LINESTRING (-119.9736 47.84...
## 6 1105008001942    US Hwy 101 Alt     U S1200 LINESTRING (-124.0058 46.32...
```
We can estimate the length of these roads, which will come in handy when estimating road density in a certain area. First we will transform to a distance-friendly projection, and then I will use the st_length() function from the sf package to estimate the length of each road.  


```r
roads <- st_transform(roads, crs="EPSG:5070") 
roads$length <- sf::st_length(roads)
print(head(roads[,6]))
```

```
## Simple feature collection with 6 features and 1 field
## Geometry type: LINESTRING
## Dimension:     XY
## Bounding box:  xmin: -2130827 ymin: 2908853 xmax: -1789090 ymax: 2989999
## Projected CRS: NAD83 / Conus Albers
##            length                       geometry
## 1  2948.97485 [m] LINESTRING (-2103609 297704...
## 2    35.07614 [m] LINESTRING (-1797725 298956...
## 3 48720.08804 [m] LINESTRING (-1825003 295515...
## 4    74.62914 [m] LINESTRING (-2130537 290974...
## 5  9526.23736 [m] LINESTRING (-1789090 298793...
## 6   934.32284 [m] LINESTRING (-2130827 290885...
```
The unit will be automatically in meters, we can convert to numeric if we dont want the unit directly in the column using as.numeric()


```r
roads$length <- as.numeric(roads$length)
print(head(roads[,6]))
```

```
## Simple feature collection with 6 features and 1 field
## Geometry type: LINESTRING
## Dimension:     XY
## Bounding box:  xmin: -2130827 ymin: 2908853 xmax: -1789090 ymax: 2989999
## Projected CRS: NAD83 / Conus Albers
##        length                       geometry
## 1  2948.97485 LINESTRING (-2103609 297704...
## 2    35.07614 LINESTRING (-1797725 298956...
## 3 48720.08804 LINESTRING (-1825003 295515...
## 4    74.62914 LINESTRING (-2130537 290974...
## 5  9526.23736 LINESTRING (-1789090 298793...
## 6   934.32284 LINESTRING (-2130827 290885...
```
I can estimate total length for each road type, or following any other attribute, for example all roads within a certain county, or any polygon, such as camera trap buffer area. 


```r
road_lengths <- aggregate(length ~ RTTYP, data=roads, FUN="sum")
print(road_lengths)
```

```
##   RTTYP     length
## 1     C   12589.73
## 2     I 2471012.92
## 3     M 5794528.48
## 4     O   11446.29
## 5     S 9159988.42
## 6     U 3811870.92
```
With this information I can estimate the road density of each road type within Washington state. 


```r
road_lengths$road_density <- ((road_lengths$length)/1e+6)/184827
print(head(road_lengths))
```

```
##   RTTYP     length road_density
## 1     C   12589.73 6.811629e-08
## 2     I 2471012.92 1.336933e-05
## 3     M 5794528.48 3.135109e-05
## 4     O   11446.29 6.192975e-08
## 5     S 9159988.42 4.955980e-05
## 6     U 3811870.92 2.062399e-05
```

Sometimes it is useful to convert lines to polygons, for example when we want a better representation of the area a linear feature occupies. This might be good for connectivity analysis as road width might define crossing probability, or for considering impervious surface generated by roads. For this we use the st_buffer() function and decide a buffer size we will use for the linear feature expansion. 


```r
roads_p <- sf::st_buffer(roads, dist=12) #buffer to 12 meters
plot(roads_p[,1])
```

![](RMarkdown_files/figure-latex/unnamed-chunk-19-1.pdf)<!-- --> 

```r
print(head(roads_p)) #now our roads are a polygon map layer
```

```
## Simple feature collection with 6 features and 5 fields
## Geometry type: POLYGON
## Dimension:     XY
## Bounding box:  xmin: -2130839 ymin: 2908841 xmax: -1789078 ymax: 2990011
## Projected CRS: NAD83 / Conus Albers
##        LINEARID          FULLNAME RTTYP MTFCC                       geometry
## 1  110569183105 State Rte 109 Byp     S S1200 POLYGON ((-2103573 2977164,...
## 2 1102219128828     US Hwy 97 Alt     U S1200 POLYGON ((-1797762 2989559,...
## 3 1102219128829     US Hwy 97 Alt     U S1200 POLYGON ((-1824999 2955186,...
## 4 1105007792960    US Hwy 101 Alt     U S1200 POLYGON ((-2130535 2909763,...
## 5 1103730584015     US Hwy 97 Alt     U S1200 POLYGON ((-1792234 2988143,...
## 6 1105008001942    US Hwy 101 Alt     U S1200 POLYGON ((-2130824 2908883,...
##        length
## 1  2948.97485
## 2    35.07614
## 3 48720.08804
## 4    74.62914
## 5  9526.23736
## 6   934.32284
```

### Vector data: polygons

Polygon data, sometimes also multipolygon data, are data that delimits an area, the shape of this area might represent specific physical features, such as buildings, or it might delimit an area with similar characteristics, for example residential areas or parks, or forest. 

We will first load a shapefile with polygons delimiting urban wildlife habitat areas, a shapefile containing all trees in seattle, and then we will extract our own polygons from the OpenStreetMap database. 

We can read a polygon dataset, like points and lines, with either the sf package or the terra package. The main difference is only the speed at which certain processes happen, but most functions are found in equivalent versions in both packages. When we plot a Spatvector from terra, we dont need to specify one attribute, it draws only one map regardless. 


```r
habitat_sf <- sf::st_read("maps/Wildlife_habitat/ECA_Wildlife_Habitat.shp")
```

```
## Reading layer `ECA_Wildlife_Habitat' from data source 
##   `C:\Users\tizge\Documents\Spatial Analysis in R Workshop\spatial_analysis_workshop_UWIN\maps\Wildlife_habitat\ECA_Wildlife_Habitat.shp' 
##   using driver `ESRI Shapefile'
## Simple feature collection with 100 features and 8 fields
## Geometry type: MULTIPOLYGON
## Dimension:     XY
## Bounding box:  xmin: 1244211 ymin: 186072.4 xmax: 1291765 ymax: 271387.1
## Projected CRS: NAD83(HARN) / Washington North (ftUS)
```

```r
plot(habitat_sf[,1])
title("Sf object")
```

![](RMarkdown_files/figure-latex/unnamed-chunk-20-1.pdf)<!-- --> 



```r
library(terra)
habitat <- terra::vect("maps/Wildlife_habitat/ECA_Wildlife_Habitat.shp")
plot(habitat)
```

![](RMarkdown_files/figure-latex/unnamed-chunk-21-1.pdf)<!-- --> 
Let's check the projection before we go forward. It is NAD83 which works well for spatial measurements <>(we should double check the projections used across the document, choose one that we will use for measurements and stick to it)


```r
crs(habitat) #"EPSG:6152"
```

```
## [1] "PROJCRS[\"NAD83(HARN) / Washington North (ftUS)\",\n    BASEGEOGCRS[\"NAD83(HARN)\",\n        DATUM[\"NAD83 (High Accuracy Reference Network)\",\n            ELLIPSOID[\"GRS 1980\",6378137,298.257222101,\n                LENGTHUNIT[\"metre\",1]],\n            ID[\"EPSG\",6152]],\n        PRIMEM[\"Greenwich\",0,\n            ANGLEUNIT[\"Degree\",0.0174532925199433]]],\n    CONVERSION[\"unnamed\",\n        METHOD[\"Lambert Conic Conformal (2SP)\",\n            ID[\"EPSG\",9802]],\n        PARAMETER[\"Latitude of false origin\",47,\n            ANGLEUNIT[\"Degree\",0.0174532925199433],\n            ID[\"EPSG\",8821]],\n        PARAMETER[\"Longitude of false origin\",-120.833333333333,\n            ANGLEUNIT[\"Degree\",0.0174532925199433],\n            ID[\"EPSG\",8822]],\n        PARAMETER[\"Latitude of 1st standard parallel\",47.5,\n            ANGLEUNIT[\"Degree\",0.0174532925199433],\n            ID[\"EPSG\",8823]],\n        PARAMETER[\"Latitude of 2nd standard parallel\",48.7333333333333,\n            ANGLEUNIT[\"Degree\",0.0174532925199433],\n            ID[\"EPSG\",8824]],\n        PARAMETER[\"Easting at false origin\",1640416.66666667,\n            LENGTHUNIT[\"US survey foot\",0.304800609601219],\n            ID[\"EPSG\",8826]],\n        PARAMETER[\"Northing at false origin\",0,\n            LENGTHUNIT[\"US survey foot\",0.304800609601219],\n            ID[\"EPSG\",8827]]],\n    CS[Cartesian,2],\n        AXIS[\"(E)\",east,\n            ORDER[1],\n            LENGTHUNIT[\"US survey foot\",0.304800609601219,\n                ID[\"EPSG\",9003]]],\n        AXIS[\"(N)\",north,\n            ORDER[2],\n            LENGTHUNIT[\"US survey foot\",0.304800609601219,\n                ID[\"EPSG\",9003]]]]"
```

We can estimate the area of each wildlife habitat, and measure the total surface area of wildlife habitat and corridors in the city.


```r
library(ggplot2)
library(terra)
habitat$area <- terra::expanse(habitat) #in km2
total_ar <- sum(habitat$area/1000000)
# ggplot(habitat, aes(fill=area/1000000))+geom_spatvector()+
#   ggtitle(paste("Seattle: Total wildlife habitat", round(total_ar), "km2")) #24km2 of wildlife habitat sounds right??
```

The tree dataset comes from [the Seattle open data](https://data-seattlecitygis.opendata.arcgis.com/) and delimits tree crowns which found with LiDAr data. I have cropped this layer to a section of seattle given the document size. We will load and look at the attributes contained within, we can also do this for sf object, by using the str() function.



```r
trees <- st_read("maps/trees_seattle.shp")
```

```
## Reading layer `trees_seattle' from data source 
##   `C:\Users\tizge\Documents\Spatial Analysis in R Workshop\spatial_analysis_workshop_UWIN\maps\trees_seattle.shp' 
##   using driver `ESRI Shapefile'
## Simple feature collection with 1000 features and 7 fields
## Geometry type: POLYGON
## Dimension:     XY
## Bounding box:  xmin: -122.3744 ymin: 47.73252 xmax: -122.363 ymax: 47.73419
## Geodetic CRS:  WGS 84
```

```r
print(trees, n=3)
```

```
## Simple feature collection with 1000 features and 7 fields
## Geometry type: POLYGON
## Dimension:     XY
## Bounding box:  xmin: -122.3744 ymin: 47.73252 xmax: -122.363 ymax: 47.73419
## Geodetic CRS:  WGS 84
## First 3 features:
##   OBJECTID Hgt_Q98 Hgt_Q99   Radius       Type Shape__Are Shape__Len
## 1        1   94.06   94.89 32.39058 Coniferous   3295.562   203.5093
## 2        2   98.27   99.00 37.12950 Coniferous   4330.423   233.2838
## 3        3  116.91  120.27 31.80548 Coniferous   3177.577   199.8331
##                         geometry
## 1 POLYGON ((-122.3717 47.7326...
## 2 POLYGON ((-122.3736 47.7327...
## 3 POLYGON ((-122.3731 47.7329...
```
The dataset includes height with certain confidence levels, as it was obtained from machine learning algorithms, a tree crown radius for which we dont have a unit, and a tree type. Let's do some stats to understand the tree composition of the area we cropped.

We can count the number of trees in the area per tree type.


```r
tree_numbers <- aggregate(OBJECTID  ~ Type, data=trees, FUN="length")
print(tree_numbers)
```

```
##         Type OBJECTID
## 1 Coniferous      974
## 2  Deciduous       26
```
With the same function we can get statitistics with the attributes in the dataset. For example estimate the mean and max radius and height for each tree type.


```r
tree_numbers$mean_radius <- aggregate(Radius  ~ Type, data=trees, FUN="mean")[,2]
tree_numbers$max_radius <- aggregate(Radius  ~ Type, data=trees, FUN="max")[,2]
tree_numbers$mean_height <- aggregate(Hgt_Q99  ~ Type, data=trees, FUN="mean")[,2]
tree_numbers$max_height <- aggregate(Hgt_Q99  ~ Type, data=trees, FUN="max")[,2]

print(head(tree_numbers))
```

```
##         Type OBJECTID mean_radius max_radius mean_height max_height
## 1 Coniferous      974    18.23390   45.03986   108.32541     217.32
## 2  Deciduous       26    13.93828   22.48987    78.03423     109.73
```

We can do simple math using the attributes, for example use the crown radius to estimate the total tree cover in the area, pretending it was measured in inches and converting total cover to m2. We estimate the total area of each crown and then add them up.


```r
trees$cover <- (pi*((trees$Radius*0.0254)^2))  #converted from inch2 to in metres2
sum(trees$cover)
```

```
## [1] 741.4985
```

We can also add attributes to a polygon dataset as we would to a dataframe. In this case we will use the tidyterra package, to use a similar syntax we'd use with dplyr. We can also use base R for this. 

For this case we will first extract all the tallest trees into an object and then use this object to attribute a rank to all the trees in the dataset. This codes works for both sf objects and spatvectors.


```r
library(tidyterra)

#let's extract a set of features based on their attribute values. We can do this two ways:
tallest_trees <- trees[trees$Hgt_Q98>=150, ] 
#another way:
tallest_trees<- trees[which(trees$Hgt_Q98>=150),]

## add rank of 1 to trees in the tree dataset if they are in the tallest_trees dataset, using their tree ID
trees  <- trees %>% mutate(rank=ifelse(OBJECTID %in% tallest_trees$OBJECTID, 1, 0)) 
#we can also do this with base R
trees$rank<- ifelse(trees$OBJECTID %in% tallest_trees$OBJECTID, 1, 0)
```



We can plot the trees following the different attributes using plot


```r
plot(trees[,"Hgt_Q99"])
```

![](RMarkdown_files/figure-latex/unnamed-chunk-29-1.pdf)<!-- --> 

If we can also plot on a basemap as we did using ggmap in the points section, but we will use plet(), we just need to convert the sf object to a vector. plet() creates an interactive map you can explore, similar to what you would be able to do in QGIS or ArcGIS.


```r
#library(leaflet)
trees_T <- vect(trees)
plet(trees_T, "Hgt_Q98", 
     col=c("#00cd00", "#00b300", "#86B049","#7fbf7f", "#008000", "#02471a"),
     cex=1, lwd=0.1, border="black", popup=TRUE, label=FALSE, 
     tiles=c("Streets", "Esri.WorldImagery", "OpenTopoMap"), 
     wrap=TRUE, legend="topleft", collapse=FALSE, map=NULL)
```

![](RMarkdown_files/figure-latex/unnamed-chunk-30-1.pdf)<!-- --> 

Finally, we can convert the polygons to points, in this case working with polygons is slower, and tree locations as points would work faster than manipulating the tree crown polygon layer. 

With the points layer of trees I can estimate the size of the treed area we are analyzing by generating a polygon that encloses them, estimating the size of that polygon (the treed area) and then estimate the tree density within that area.



```r
trees_p <- st_centroid(trees) # we can also avoid this and just count the number of trees in total and later on within the buffer
perimeter <- trees_p %>% 
  summarise() %>% 
  concaveman::concaveman(concavity = 1)
#check crs before estimating area
perimeter <- st_transform(perimeter, crs="EPSG:5070")
treed_area <- st_area(perimeter)

nrow(trees_p)/(as.numeric(treed_area)/1e+6) #in trees/km2
```

```
## [1] 9046.067
```

We can convert a polygon to a raster, based on an attribute. First we need a template raster that defines the resolution and the size (extent) of the raster. Then we use the rasterize() function from terra.


```r
r <- rast(resolution=0.00025, extent=c(-122.3744, -122.363, 47.73252, 47.73419))
trees_height_R <- rasterize(vect(trees), r, "Hgt_Q98")
plot(trees_height_R)
```

![](RMarkdown_files/figure-latex/unnamed-chunk-32-1.pdf)<!-- --> 

We can use the points layer we created to generate a raster with tree counts within each cell, using the previous raster template.


```r
#tree_p <- st_centroids(trees)
trees_PR <- rasterize(trees_p, r, fun=sum) 
plot(trees_PR)
```

![](RMarkdown_files/figure-latex/unnamed-chunk-33-1.pdf)<!-- --> 



To save vector data into a shapefile we use the writeVector function from terra


```r
writeVector(vect(trees), "trees_output.shp")
```

To save our output raster to a .tif file, we use the writeRaster function from terra


```r
writeRaster(trees_PR, "tree_density.tif"
```

#### Vector data: Extracting data from OSM

First we need the table with the set of validated osm keys to make sure we dont miss any urban osm features, we will use the "keys" object in the next chunk.


```r
osm_kv <- read.csv("data/osm_key_values.csv")
osm_kv <- osm_kv %>% filter(!is.na(key))
keys <- unique(osm_kv$key)
```

Then we can extract the osm data for Seattle. Osm stores data both in several formats including points, lines and polygons, the ones that we are interested for this case are lines and polygons.


```r
Seattle_pol <- osmextract::oe_get("Seattle",
                             layer = "multipolygons", 
                             extra_tags=keys)
```

```
##   |                                                                              |                                                                      |   0%  |                                                                              |                                                                      |   1%  |                                                                              |=                                                                     |   1%  |                                                                              |=                                                                     |   2%  |                                                                              |==                                                                    |   2%  |                                                                              |==                                                                    |   3%  |                                                                              |==                                                                    |   4%  |                                                                              |===                                                                   |   4%  |                                                                              |===                                                                   |   5%  |                                                                              |====                                                                  |   5%  |                                                                              |====                                                                  |   6%  |                                                                              |=====                                                                 |   6%  |                                                                              |=====                                                                 |   7%  |                                                                              |=====                                                                 |   8%  |                                                                              |======                                                                |   8%  |                                                                              |======                                                                |   9%  |                                                                              |=======                                                               |   9%  |                                                                              |=======                                                               |  10%  |                                                                              |=======                                                               |  11%  |                                                                              |========                                                              |  11%  |                                                                              |========                                                              |  12%  |                                                                              |=========                                                             |  12%  |                                                                              |=========                                                             |  13%  |                                                                              |=========                                                             |  14%  |                                                                              |==========                                                            |  14%  |                                                                              |==========                                                            |  15%  |                                                                              |===========                                                           |  15%  |                                                                              |===========                                                           |  16%  |                                                                              |============                                                          |  16%  |                                                                              |============                                                          |  17%  |                                                                              |============                                                          |  18%  |                                                                              |=============                                                         |  18%  |                                                                              |=============                                                         |  19%  |                                                                              |==============                                                        |  19%  |                                                                              |==============                                                        |  20%  |                                                                              |==============                                                        |  21%  |                                                                              |===============                                                       |  21%  |                                                                              |===============                                                       |  22%  |                                                                              |================                                                      |  22%  |                                                                              |================                                                      |  23%  |                                                                              |================                                                      |  24%  |                                                                              |=================                                                     |  24%  |                                                                              |=================                                                     |  25%  |                                                                              |==================                                                    |  25%  |                                                                              |==================                                                    |  26%  |                                                                              |===================                                                   |  26%  |                                                                              |===================                                                   |  27%  |                                                                              |===================                                                   |  28%  |                                                                              |====================                                                  |  28%  |                                                                              |====================                                                  |  29%  |                                                                              |=====================                                                 |  29%  |                                                                              |=====================                                                 |  30%  |                                                                              |=====================                                                 |  31%  |                                                                              |======================                                                |  31%  |                                                                              |======================                                                |  32%  |                                                                              |=======================                                               |  32%  |                                                                              |=======================                                               |  33%  |                                                                              |=======================                                               |  34%  |                                                                              |========================                                              |  34%  |                                                                              |========================                                              |  35%  |                                                                              |=========================                                             |  35%  |                                                                              |=========================                                             |  36%  |                                                                              |==========================                                            |  36%  |                                                                              |==========================                                            |  37%  |                                                                              |==========================                                            |  38%  |                                                                              |===========================                                           |  38%  |                                                                              |===========================                                           |  39%  |                                                                              |============================                                          |  39%  |                                                                              |============================                                          |  40%  |                                                                              |============================                                          |  41%  |                                                                              |=============================                                         |  41%  |                                                                              |=============================                                         |  42%  |                                                                              |==============================                                        |  42%  |                                                                              |==============================                                        |  43%  |                                                                              |==============================                                        |  44%  |                                                                              |===============================                                       |  44%  |                                                                              |===============================                                       |  45%  |                                                                              |================================                                      |  45%  |                                                                              |================================                                      |  46%  |                                                                              |=================================                                     |  46%  |                                                                              |=================================                                     |  47%  |                                                                              |=================================                                     |  48%  |                                                                              |==================================                                    |  48%  |                                                                              |==================================                                    |  49%  |                                                                              |===================================                                   |  49%  |                                                                              |===================================                                   |  50%  |                                                                              |===================================                                   |  51%  |                                                                              |====================================                                  |  51%  |                                                                              |====================================                                  |  52%  |                                                                              |=====================================                                 |  52%  |                                                                              |=====================================                                 |  53%  |                                                                              |=====================================                                 |  54%  |                                                                              |======================================                                |  54%  |                                                                              |======================================                                |  55%  |                                                                              |=======================================                               |  55%  |                                                                              |=======================================                               |  56%  |                                                                              |========================================                              |  56%  |                                                                              |========================================                              |  57%  |                                                                              |========================================                              |  58%  |                                                                              |=========================================                             |  58%  |                                                                              |=========================================                             |  59%  |                                                                              |==========================================                            |  59%  |                                                                              |==========================================                            |  60%  |                                                                              |==========================================                            |  61%  |                                                                              |===========================================                           |  61%  |                                                                              |===========================================                           |  62%  |                                                                              |============================================                          |  62%  |                                                                              |============================================                          |  63%  |                                                                              |============================================                          |  64%  |                                                                              |=============================================                         |  64%  |                                                                              |=============================================                         |  65%  |                                                                              |==============================================                        |  65%  |                                                                              |==============================================                        |  66%  |                                                                              |===============================================                       |  66%  |                                                                              |===============================================                       |  67%  |                                                                              |===============================================                       |  68%  |                                                                              |================================================                      |  68%  |                                                                              |================================================                      |  69%  |                                                                              |=================================================                     |  69%  |                                                                              |=================================================                     |  70%  |                                                                              |=================================================                     |  71%  |                                                                              |==================================================                    |  71%  |                                                                              |==================================================                    |  72%  |                                                                              |===================================================                   |  72%  |                                                                              |===================================================                   |  73%  |                                                                              |===================================================                   |  74%  |                                                                              |====================================================                  |  74%  |                                                                              |====================================================                  |  75%  |                                                                              |=====================================================                 |  75%  |                                                                              |=====================================================                 |  76%  |                                                                              |======================================================                |  76%  |                                                                              |======================================================                |  77%  |                                                                              |======================================================                |  78%  |                                                                              |=======================================================               |  78%  |                                                                              |=======================================================               |  79%  |                                                                              |========================================================              |  79%  |                                                                              |========================================================              |  80%  |                                                                              |========================================================              |  81%  |                                                                              |=========================================================             |  81%  |                                                                              |=========================================================             |  82%  |                                                                              |==========================================================            |  82%  |                                                                              |==========================================================            |  83%  |                                                                              |==========================================================            |  84%  |                                                                              |===========================================================           |  84%  |                                                                              |===========================================================           |  85%  |                                                                              |============================================================          |  85%  |                                                                              |============================================================          |  86%  |                                                                              |=============================================================         |  86%  |                                                                              |=============================================================         |  87%  |                                                                              |=============================================================         |  88%  |                                                                              |==============================================================        |  88%  |                                                                              |==============================================================        |  89%  |                                                                              |===============================================================       |  89%  |                                                                              |===============================================================       |  90%  |                                                                              |===============================================================       |  91%  |                                                                              |================================================================      |  91%  |                                                                              |================================================================      |  92%  |                                                                              |=================================================================     |  92%  |                                                                              |=================================================================     |  93%  |                                                                              |=================================================================     |  94%  |                                                                              |==================================================================    |  94%  |                                                                              |==================================================================    |  95%  |                                                                              |===================================================================   |  95%  |                                                                              |===================================================================   |  96%  |                                                                              |====================================================================  |  96%  |                                                                              |====================================================================  |  97%  |                                                                              |====================================================================  |  98%  |                                                                              |===================================================================== |  98%  |                                                                              |===================================================================== |  99%  |                                                                              |======================================================================|  99%  |                                                                              |======================================================================| 100%
## 0...10...20...30...40...50...60...70...80...90...100 - done.
## Reading layer `multipolygons' from data source 
##   `C:\Users\tizge\AppData\Local\Temp\Rtmp4GwHl3\bbbike_Seattle.gpkg' 
##   using driver `GPKG'
## Simple feature collection with 564062 features and 44 fields
## Geometry type: MULTIPOLYGON
## Dimension:     XY
## Bounding box:  xmin: -122.46 ymin: 47.39 xmax: -122.01 ymax: 47.83
## Geodetic CRS:  WGS 84
```

```r
Seattle_lines <- osmextract::oe_get("Seattle",
                              layer = "lines", 
                              extra_tags=keys)
```

```
## 0...10...20...30...40...50...60...70...80...90...100 - done.
## Reading layer `lines' from data source 
##   `C:\Users\tizge\AppData\Local\Temp\Rtmp4GwHl3\bbbike_Seattle.gpkg' 
##   using driver `GPKG'
## Simple feature collection with 355001 features and 34 fields
## Geometry type: LINESTRING
## Dimension:     XY
## Bounding box:  xmin: -122.46 ymin: 47.39 xmax: -122.01 ymax: 47.83
## Geodetic CRS:  WGS 84
```

Now we can extract from the Seattle data extracted we can filter based on the land cover class or land features we are interested in. We will focus on forest areas, grass areas, and roads. Note that roads will be filtered from the lines layer.


```r
forest <- Seattle_pol %>% dplyr::filter(landuse %in% c("forest")|
                                              natural  %in% c("wood")|
                                              boundary %in% c("forest", "forest_compartment"))

grass <- Seattle_pol %>% dplyr::filter(landuse %in% c("park", "grass", "cemetery", "greenfield", "recreation_ground", "winter_sports")|
                                              (!is.na(golf) & !(golf %in% c("rough","bunker"))) |
                                              amenity %in% c("park") |
                                              leisure %in% c("park", "stadium", "playground", "pitch", "sports_centre", "stadium", "pitch", "picnic_table", "pitch", "dog_park", "playground")|
                                              sport %in% c("soccer")|
                                              power %in% c("substation")|
                                              surface %in% c("grass"))

grass<-sf::st_make_valid(grass) #eliminates self intersecting multipolygons

#linear features with low traffic (Residential roads)

res_roads	<- Seattle_lines %>% dplyr::filter(highway	%in% c("residential", "rest_area", "busway"))

plot(forest[,1])
```

![](RMarkdown_files/figure-latex/unnamed-chunk-38-1.pdf)<!-- --> 

```r
plot(grass[,1])
```

![](RMarkdown_files/figure-latex/unnamed-chunk-38-2.pdf)<!-- --> 

```r
plot(res_roads[,1])
```

![](RMarkdown_files/figure-latex/unnamed-chunk-38-3.pdf)<!-- --> 

We can look at the frequency of each feature attribute within a landscape class. For example what are the diffrent types of grass areas in Seattle and how much area they occupy.


```r
sf_use_s2(FALSE)
grass <- sf::st_transform(grass, crs="EPSG:5070")
grass <- grass %>% mutate(grass_area_km2 = as.numeric(st_area(grass))/1000^2)
freq_table <- aggregate(grass_area_km2 ~ leisure, data=grass, FUN="sum") #check proportion of urban gree types
```

We can save the polygons we extracted from OSM as shapefiles.


```r
sf::st_write(forest, "maps/Seattle_forest.shp")
sf::st_write(grass, "maps/Seattle_grass.shp")
sf::st_write(roads_low_traffic, "maps/Seattle_roads.shp")
```

OR we can convert them as rasters, either using binary values or proportion of pixel covered by the class


```r
r <- rast(resolution=0.00025, extent=c(-122.4599,-122.01,  47.39002,47.82995))
forest_r <- rasterize(forest, r, value=1)
forest_r <- ifel(is.na(forest_r),0,forest_r) #value has to be 0, not NA for the next to work
for_prop_n <- aggregate(forest_r, fact=10, fun="mean")
plot(forest_r)
```

![](RMarkdown_files/figure-latex/unnamed-chunk-41-1.pdf)<!-- --> 

```r
plot(for_prop_n)
```

![](RMarkdown_files/figure-latex/unnamed-chunk-41-2.pdf)<!-- --> 

## Raster data


