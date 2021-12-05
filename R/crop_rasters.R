# This script preprares the raster dataset inputs for the regression model.

library(sp)
library(tidyverse)
library(sf)
library(ncdf4)
library(raster)
library(rgdal)
library(ggspatial) #Requires ggplot2 FYI

#Steps:
# A. Load in datasets
# B. Match projection info
# C. Crop datasets to the region of interest (ROI)
# D. Resample rasters to match eachother

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
dbo3_chl <- dbo3
lay1_chl <- projectRaster(var.chl[[1]], crs = crs(var.sictif)) #will only work if i plug in the index
chldbo3varlay1 <- crop(x = lay1_chl, y = dbo3_chl)
# The projected MODIS chlorophyll and our region of interest
ggplot() +
  layer_spatial(lay1_chl, aes(fill = stat(band1))) +
  scale_fill_continuous(na.value = NA) +
  layer_spatial(dbo3_chl)
#the cropped DBO3 view
ggplot() +
  layer_spatial(chldbo3varlay1)

#^^^^^^^^^^^^^^^^^^^^^^^

#Need CHL LOOP




# 4.
#####################
# Cloud data
lcl <- "/Volumes/My Passport/RProject2021/lcdc.mon.mean.nc" #Users/claregaffey/Downloads/lcdc.mon.mean.nc"#/
lcdc <- nc_open(lcl)
#check out the netcdf contents
lcdc
# create raster brick
var.nc1<-brick(lcl,varname="lcdc")
# Check out the contents
var.nc1
#make NARR copy of shapefile (not necessary, but good to preserve the original)
dbo3_clo <- dbo3
# reproject raster data to match the other raster datasets
lay1_clo <- projectRaster(var.nc1[[1]], crs = crs(var.sictif))#will only work if i plug in the index
# check that it reprojected
crs(lay1_clo)
# crop to DBO3 region of interest (ROI)
clodbo3varlay1 <- crop(x = lay1_clo, y = dbo3_clo)
# The reprojected low cloud cover and our region of interest
ggplot() +
  layer_spatial(lay1_clo, aes(fill = stat(band1))) +
  scale_fill_continuous(na.value = NA) +
  layer_spatial(dbo3_chl)
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
################ Next: build a loop for iterate for all months of data.
# Specifically, reproject, crop, resample to chlorophyll level as a raster
# with year and month (or date) preserved in its name (so maybe save it to its own file and rename on aseparate line)
# looped over all months in the netcdf


m <- 1:3
var.ncl22<-subset(var.nc1,m)
var.ncl22 <- var.nc1[m] #second way of doing the same thing



# MY loop: This is GOOD BUT I NEED TO FIGURE OUT WHAT FORMAT I WANT MY OUTPUT AS
# XGBOOST WIILL TAKE MATRIX OR I CAN CONVERT RASTER STACK TO TIBBLE BUT I WANT TO KEEP
# ALL OF THE CLOUD DATA TOGETHER AND NOT HAVE 514 LOOSE TIBBLES THAT REPRESENT CLOUD FILES
# IN DIFFERENT MONTHS..OTHERWISE HOW AM I GOING TO INDICATE IN XGBOOST MODEL THAT THESE ARE
# ALL REPRESENTING THE SAME VARIABLE

#This works:
tmp <- subset(var.nc1,2)
r <-tmp %>%
  projectRaster(crs = crs(var.sictif))  %>%
  crop(y = dbo3_clo) %>%
  resample(y = chldbo3varlay1)
ggplot() +
  layer_spatial(r)
# So why doesn't my loop create plottable data?
dbo3_clo <- dbo3
var.ncl22 <- var.nc1
#var.ncl22 <- var.eva[[1:2]] # Biulding a test
ek <- dim((var.ncl22))#var.nc1)
mystack <- stack()

for (i in 1:ek[3]){
  r <- subset(var.ncl22,i) %>%
  projectRaster(crs = crs(var.sictif))  %>%
  crop(y = dbo3_clo) %>%
  resample(y = chldbo3varlay1)
  print(i)
  # I should stack them, then create 1 tibble outside of the loop
  mystack <- stack(mystack, r)
}
tmp <- "/Users/claregaffey/Desktop/"
b <- brick(mystack)#If i want  to convert the stack back to a brick
writeRaster(b, filename=file.path(tmp, "lcdc_netCDF.nc"), format="CDF", overwrite=TRUE)
# Create a tibble for input for xgboost
prepped_lcdc <- getValues(mystack) %>%
  as_tibble()
write.table(prepped_lcdc , file = "/Users/claregaffey/Desktop/prepped_lcdc.csv")

#Exploring the datasets
outlcdc <- "/Users/claregaffey/Desktop/lcdc_netCDF.nc"
outlc <- nc_open(outlcdc)
lclcsv <- read_csv("/Users/claregaffey/Desktop/prepped_lcdc.csv")
head(lclcsv)
prepped_lcdcDF <- as.data.frame(prepped_lcdc)
prepped_lcdcDF[10000,5:10]
dim(prepped_lcdc)
newbricklcl <- brick(outlcdc) # similar to b, but without CRS. But maybe i don't need projection for my next ste[ anywya]
projectRaster(newbricklcl, crs = crs(sictif))
crs(newbricklcl) <- "EPSG:3413"

plot(newbricklcl[260]) # WHY doesn't this work?
ggplot() +
  layer_spatial(mystack[1]) # WHY doesn't this work?
ggplot() +
  layer_spatial(newbricklcl[260]) # WHY doesn't this work?
crs(mystack)
ggplot() +
  layer_spatial(b[260])# WHY doesn't this work?
plot(b[204])
#but maybe i dont need to plot them again anyway.
#Next steps: see exactly what do i want for xgboost inputs
#tailor the saved outputs of the loop to that
# Write that loop into a function
# Apply that function to all datasets (mi might need to include a if/else statement for chloroophyyll for files where there is no data within the roi)
# Fine tune the visuals I want (titles, etc.) and save to pngs to call in vignette
# Move onto xgboost


#messing aorund
mew <- var33 %>% projectRaster(crs = crs(var.sictif)) %>% crop(y = dbo3_clo)  %>% resample(y = chldbo3varlay1)
ggplot() +
  layer_spatial(var.ncl22[[514]]) + layer_spatial(m)
ggplot() +
   layer_spatial(var.eva[2])#(var.nc1[2])
par(mar = c(1, 1, 1, 1))
plot(var.nc1[2])













#///////////\\\\\\\\\\\/\/\/\/\
m <- 1 #which time slice do we want to view (can use this to create a LOOP later) 1-504
#subset extracts a single layer from the raster brick
tmp_slice_r<-subset(var.nc1,m)
dim(tmp_slice_r)
plot(tmp_slice_r)
plot(var.nc1[[2]])

#///////////////////////////////////
pat <- seq(as.Date("1979/1/1"), by = "month", length.out = 504)
#create color palettes:
temp.palette <- rev(colorRampPalette(c("darkred","red","orange",
                                       "lightyellow","white","azure",
                                       "cyan","blue","darkblue"))(100))

TIME <- as.POSIXct(substr(var.nc1@data@names, start=2, stop=20), format="%Y.%m.%d")

#Create a title for plot: take TIME[m] string and how many characters from the left to keep in title? 7 or 10
ttl <- paste("Low cloud cover","_", substr(TIME[m], 1, 7),sep="")

#test it
spplot(tmp_slice_r,  main = ttl, col.regions=temp.palette)

tmp_slice_dm <- data.matrix(var.nc1)

test1 <- ts(data = var.nc1, start = 1, end = 504, frequency = 1, names = pat)
#//////////////////////////////////

# 5.
##############################
# Evaporation

eva <- "/Volumes/My Passport/RProject2021/evap.mon.mean.nc"
evap <- nc_open(eva)
#check out the netcdf contents
evap
# create raster brick
var.eva<-brick(eva,varname="evap")
plot(var.eva[[1]])
plot(var.eva[[2]])










