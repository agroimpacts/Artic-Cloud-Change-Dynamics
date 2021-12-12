# This script preprares the raster dataset inputs for the regression model.

#Steps:
# A. Load in datasets
# B. Match projection info
# C. Crop datasets to the region of interest (ROI)
# D. Resample rasters to match eachother (NOTE: this step is unnecessary here
#    for the demo model, but it's preserved for properly running a
#    pixel-by-pixel regression model. This demo will average over the ROI per
#    month to limit computation demands)
# E. Save monthly averaged variables
# F. Write data to a format suitable for input to XGBoost

# Load in libraries
library(sp)
library(tidyverse)
library(sf)
library(ncdf4)
library(raster)
library(rgdal)
library(ggspatial) #Requires ggplot2

# 1.
# DBO3 Shapefile for ROI
dbo3 <- "/Users/claregaffey/OneDrive - Clark University/R_Project/DBO3_shapefile/Dbo3.shp" %>%
  st_read()

# 2.
##############################
# Sea Ice Concentration example
si <- "/Volumes/My Passport/RProject2021/SeaIce_MonthlySB2/SB2_1978_12_month.rst"
# create raster brick
var.sictif <- brick(si)#varname="chlor_a")
#project
crs(var.sictif) <- "EPSG:3413"
#crop
sicrop <- crop(x = var.sictif, y = dbo3)
# Visualize the entire file and the ROI
ggplot() +
  layer_spatial(var.sictif, aes(fill = stat(band1))) +
  scale_fill_continuous(na.value = NA) + layer_spatial(dbo3)
# The cropped sea ice concentration to DBO3
ggplot() +
  layer_spatial(sicrop)
# Calculate the mean of DBO3 sea ice concentration for DBO3 on our sample date
cellStats(x = sicrop, stat = "mean")
#^^^^^^^^^^^^^^^^^^^^^^^
# Bring in all of the sea ice time series data
mystack <- stack()
files <- list.files(path="/Volumes/My Passport/RProject2021/SeaIce_MonthlySB2/",
                    pattern="*.rst", full.names=TRUE, recursive=FALSE)
for (x in files) {
  sicbrick <- brick(x) # create a raster brick
  crs(sicbrick) <- "EPSG:3413" # define projection
  mystack <- stack(mystack, sicbrick) #stack all of the bricks
}
var.sic <- brick(mystack) # create a brick from the stack

# 3.
#####################
#Chlorophyll
#^^^^^^^^^^^^^^^^^^^^^^^
# This code loads in chl netcdf, converts to a raster object, reprojects it to
# match the other files(SIC, DBO3 bounding box ROI), crops it to the DBO3 ROI,
# and visualizes the data.
## Clean version of chla:
chl <- "/Volumes/My Passport/RProject2021/MODIS_chl/A20031822003212.L3m_MO_CHL.x_chlor_a.nc"
chla <- nc_open(chl)
#check out the netcdf contents
chla
# create raster brick
var.chl<-brick(chl,varname="chlor_a")
crs(var.chl)
# reproejct chla data and crop
# (will only work if i plug in the index)
lay1_chl <- projectRaster(var.chl[[1]], crs = crs(var.sictif))
chldbo3varlay1 <- crop(x = lay1_chl, y = dbo3)
# The projected MODIS chlorophyll and our region of interest
ggplot() +
  layer_spatial(lay1_chl, aes(fill = stat(band1))) +
  scale_fill_continuous(na.value = NA) +
  layer_spatial(dbo3)
#the cropped DBO3 view
ggplot() +
  layer_spatial(chldbo3varlay1)

#^^^^^^^^^^^^^^^^^^^^^^^
# Bring in all of the chlorophyll time series data
mystack <- stack()
files <- list.files(path="/Volumes/My Passport/RProject2021/MODIS_chl/",
                    pattern="*.nc", full.names=TRUE, recursive=FALSE)
for (x in files) {
  chlbrick <- brick(x, varname="chlor_a") # create a raster brick
  mystack <- stack(mystack, chlbrick) #stack all of the bricks
}
var.chla <- brick(mystack) # create a brick from the stack



##########################
# Preprocess all datasets
##########################
# Function converts raster bricks into monthly averaged values over ROI in a csv.
# Note it does rely on files made from the SIC and CHL examples for reference.

NARR_dataprep <- function(NARR_brick, ROI) {
  ek <- dim(NARR_brick)
  time <- list()
  meanlcl <- list()
  counter <- 0
  for (i in 1:ek[3]){
    r <- subset(NARR_brick,i) %>% # running each time slice (works best)
      projectRaster(crs = crs(var.sictif))  %>% #will not work with EPSG#
      crop(y = ROI) #%>% # crop to the DBO3 extent
      #resample(y = chldbo3varlay1) # Resamples to the chlorophyll pixel extents
    counter <-  counter + 1 # keep track of which layer we are on in the console
    print(paste0(counter, " out of ", ek[3]))
    time <- append(time, names(r)) # add raster name to a list
    k <- cellStats(x = r, stat = "mean") # calculate a mean over ROI
    meanlcl <- append(meanlcl, k) # add averaged variable to a list
  }
  # make a dataframe with the raster name (time) and averaged variable lists
  nam <- paste0(deparse(substitute(NARR_brick)), ".csv") # for file naming
  df <- do.call(rbind, Map(data.frame, Time=time, Variable=meanlcl))
  names(df)[names(df) == 'Variable'] <- substr(nam,5,8) #rename var column
  df$Year.month.day <-  substr(df$Time,2,11) # new column for date info
  # export to a csv
  write.csv(df, file = paste("/Users/claregaffey/Documents/RClass/", nam),
            row.names = FALSE)#here::here(paste("external/data/", nam)))
  return(head(df)) # display some rows of our dataframe
}

# Run for all sea ice data
NARR_dataprep(var.sic, dbo3)

# Run for all chlorophyll data
NARR_dataprep(var.chla, dbo3)


##########################
# NARR Reanalysis datasets
##########################
# The following datasets are netcdfs with similar structures, and due to their
# consistency in file type, we can process them routinely.

# 4.
#####################
# Cloud data example
lcl <- "/Volumes/My Passport/RProject2021/lcdc.mon.mean.nc" #Users/claregaffey/Downloads/lcdc.mon.mean.nc"#/
lcdc <- nc_open(lcl)
#check out the netcdf contents
lcdc
# create raster brick
var.nc1<-brick(lcl,varname="lcdc")
# Check out the contents
var.nc1
# reproject raster data to match the other raster datasets
# (will only work if i plug in the index)
lay1_clo <- projectRaster(var.nc1[[1]], crs = crs(var.sictif))
# check that it reprojected
crs(lay1_clo)
# crop to DBO3 region of interest (ROI)
clodbo3varlay1 <- crop(x = lay1_clo, y = dbo3)
# The reprojected low cloud cover and our region of interest
ggplot() +
  layer_spatial(lay1_clo, aes(fill = stat(band1))) +
  scale_fill_continuous(na.value = NA) +
  layer_spatial(dbo3)
# The cropped DBO3 ROI of our cloud layer
ggplot() +
  layer_spatial(clodbo3varlay1)
## Resample to match pixels of chlorophyll raster
cloudresampled <- resample(x = clodbo3varlay1, y = chldbo3varlay1)
#view the resampled image
ggplot() +
  layer_spatial(cloudresampled)
# Calculate the mean over our cloud
cellStats(x = clodbo3varlay1, stat = "mean")
#^^^^^^^^^^^^^^^^^^^^^^^^^^^^
# To preprocess the dataset for the regression model:
NARR_dataprep(var.nc1, dbo3)

# 5.
##############################
# Evaporation

eva <- "/Volumes/My Passport/RProject2021/evap.mon.mean.nc"
evap <- nc_open(eva)
#check out the netcdf contents
evap
# create raster brick
var.eva<-brick(eva,varname="evap")
#plot(var.eva[[1]]) # to take a quick look at the dataset
# create the dataframe and exported csv
NARR_dataprep(var.eva, dbo3)

# 6.
##############################
# Air temperature

atem <- "/Volumes/My Passport/RProject2021/air.sfc.mon.mean.nc"
atemp <- nc_open(atem)
#check out the netcdf contents
atemp
# create raster brick
var.airT<-brick(atem,varname="air")
# create the dataframe and exported csv
NARR_dataprep(var.airT, dbo3)

# 7.
##############################
# Geopotential height

gph <- "/Volumes/My Passport/RProject2021/hgt.tropo.mon.mean.nc"
tropo <- nc_open(gph)
#check out the netcdf contents
tropo
# create raster brick
var.hgt<-brick(gph,varname="hgt")
# create the dataframe and exported csv
NARR_dataprep(var.hgt, dbo3)

# 8.
##############################
# Relative humidity

rhu <- "/Volumes/My Passport/RProject2021/rhum.2m.mon.mean.nc"
rhum <- nc_open(rhu)
#check out the netcdf contents
rhum
# create raster brick
var.rhum<-brick(rhu,varname="rhum")
# create the dataframe and exported csv
NARR_dataprep(var.rhum, dbo3)

# 9.
##############################
# Wind speed at 10m

win <- "/Volumes/My Passport/RProject2021/wspd.10m.mon.mean.nc"
winp <- nc_open(win)
#check out the netcdf contents
winp
# create raster brick
var.wspd<-brick(win,varname="wspd")
# create the dataframe and exported csv
NARR_dataprep(var.wspd, dbo3)

## NEXT STEPS
# Fine tune the visuals I want (titles, etc.) and save to pngs to call in vignette
# create one dataframe from my variable dataframes
# Move onto xgboost

#Note for xgboost:
# zeros are considered mssing data in the matrix
#so based on this convo
# potential solutions is: https://github.com/dmlc/xgboost/issues/4601
#"I 'd image if there are only a couple of non-missing zero values, one would be able to circumvent this behaviour by explicitly setting their values to 0.0 in the sparse matrix".
# also see last bit of: https://arfer.net/w/xgboost-sparsity
# or my book "We can also mark the values as a NaN and let the XGBoost framework treat the missing values as a distinct value for the feature."


