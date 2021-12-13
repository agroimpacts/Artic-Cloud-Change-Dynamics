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
if (!("rlist" %in% installed.packages())) {
  install.packages("rlist")
  # auto install some packages that might not be common
}
if (!("ggspatial" %in% installed.packages())) {
  install.packages("ggspatial")
}
if (!("ncdf4" %in% installed.packages())) {
  install.packages("ncdf4")
}
if (!("rgdal" %in% installed.packages())) {
  install.packages("rgdal")
}
library(rlist)
library(sp)
library(tidyverse)
library(sf)
library(ncdf4)
library(raster)
library(rgdal)
library(ggspatial)
library(here) # set up working directory
here::here() # set working directory for images

# 1.
# DBO3 Shapefile for ROI
# plug in where you saved it from Download_datasets.R and remove the comment
dbo3 <- here::here("external/data/YOURFILEHERE.png") %>% st_read()

# 2.
##############################
# Sea Ice Concentration example
# plus in the path to one of the sea ice .rst files
si <- here::here("external/data/SB2_1978_12_month.rst")
# create raster brick
var.sictif <- brick(si)#varname="chlor_a")
#project
crs(var.sictif) <- "EPSG:3413"
#crop
sicrop <- crop(x = var.sictif, y = dbo3)
# Visualize the entire file and the ROI
ggplot() +
  layer_spatial(var.sictif, aes(fill = stat(band1))) +
  scale_fill_continuous(na.value = NA) + layer_spatial(dbo3) +
  ggtitle("Sea Ice Concentration") + labs(fill = "SIC (%)")
# The cropped sea ice concentration to DBO3
ggplot() +
  layer_spatial(sicrop) +
  ggtitle("Sea Ice Concentration of DBO3 (Chukchi Sea)") + labs(fill = "SIC (%)")
# Calculate the mean of DBO3 sea ice concentration for DBO3 on our sample date
cellStats(x = sicrop, stat = "mean")
#^^^^^^^^^^^^^^^^^^^^^^^
# Bring in all of the sea ice time series data
mystack <- stack()
files <- list.files(path="/external/data/SeaIce_MonthlySB2_YOUR_SEA_ICE_FOLDER",
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

# plus in the path to one of the chlorophyll nc files
chl <- here::here("external/data/A20031822003212.L3m_MO_CHL.x_chlor_a.nc")
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
files <- list.files(path="external/data/YOUR_CHLOROPHYLL_FOLDER",
                    pattern="*.nc", full.names=TRUE, recursive=FALSE)
for (x in files) {
  chlbrick <- brick(x, varname="chlor_a") # create a raster brick
  mystack <- stack(mystack, chlbrick) #stack all of the bricks
}
var.chla <- brick(mystack) # create a brick from the stack

substr(files,53,59) # checking out the dates of the files
pat <- seq(1:11) #chlorophyll has 11 months of data per year
paste0(substr(list.skip(files, 4),53,56), "_", pat)
#for checking the dates during the data merge
# (skipping the first incomplete year)

# Modified function to accomodate the chlorophyll file dates
CHL_dataprep <- function(NARR_brick, ROI) {
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
  df$Year.julianday <- paste0(substr(files, 53, 56), "_",
                              substr(files, 57, 59))
  # export to a csv
  write.csv(df, file = paste("/external/data/", nam),
            row.names = FALSE)#here::here(paste("external/data/", nam)))
  return(head(df)) # display some rows of our dataframe
}
# Run for all chlorophyll data
CHL_dataprep(var.chla, dbo3)


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
  write.csv(df, file = paste("/external/data/", nam),
            row.names = FALSE)#here::here(paste("external/data/", nam)))
  return(head(df)) # display some rows of our dataframe
}

# Run for all sea ice data
NARR_dataprep(var.sic, dbo3)




##########################
# NARR Reanalysis datasets
##########################
# The following datasets are netcdfs with similar structures, and due to their
# consistency in file type, we can process them routinely.

# 4.
#####################
# Cloud data example
lcl <- "/external/data/lcdc.mon.mean.nc"
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
  layer_spatial(dbo3) +
  ggtitle("NARR Low Cloud Concentration for North America") +
  labs(fill = "CC (%)")
# The cropped DBO3 ROI of our cloud layer
ggplot() +
  layer_spatial(clodbo3varlay1) +
  ggtitle("Low Cloud Concentration of DBO3 (Chukchi Sea)") +
  labs(fill = "CC (%)")
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

eva <- "/external/data/evap.mon.mean.nc"
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

atem <- "/external/data/air.sfc.mon.mean.nc"
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

gph <- "/external/data/hgt.tropo.mon.mean.nc"
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

rhu <- "/external/data/rhum.2m.mon.mean.nc"
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

win <- "/external/data/wspd.10m.mon.mean.nc"
winp <- nc_open(win)
#check out the netcdf contents
winp
# create raster brick
var.wspd<-brick(win,varname="wspd")
# create the dataframe and exported csv
NARR_dataprep(var.wspd, dbo3)
