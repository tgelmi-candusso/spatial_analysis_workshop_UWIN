#load rasters (need to make these smaller)
NDVI <-rast("NDVI/US_eMAH_NDVI.2022.263-269.QKM.VI_NDVI.006.2022272174543.tif")
BUILT <- rast("GHS/GHS_BUILT_S_E2030_GLOBE_R2023A_54009_100_V1_0_R4_C9.tif")
LULC <- rast("C:/Users/tizge/Documents/RedWolf/CONUS_2008/nlcd_2008_land_cover_l48_20210604.img")
WA_boundary <- vect("Washington_state_boundary/WA_State_Boundary.shp")

WA_boundary <- project(WA_boundary, LULC)
LULC <-  crop(LULC, WA_boundary)
writeRaster(LULC, "maps/LULC_Seattle.tif")

WA_boundary <- project(WA_boundary, NDVI)
NDVI <-  crop(NDVI, WA_boundary)
writeRaster(NDVI, "maps/NDVI_Seattle.tif")

WA_boundary <- project(WA_boundary, BUILT)
BUILT <-  crop(BUILT, WA_boundary)
writeRaster(BUILT, "maps/BUILT_Seattle.tif")

