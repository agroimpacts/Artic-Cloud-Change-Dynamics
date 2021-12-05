### Clare's workbook - Please don't change anything in here!

### Figuring out how to insert pictures into Rmd that is saved in vignette source directory
# example from lyndon's class6.Rmd. No libraries were loaded prior to this:

b <- raster::brick(s3url)[[4:2]]
png(here::here("external/slides/figures/ghana_planet.png"), height = 4,
    width = 4, units  = "in", res = 300, bg = "transparent")
raster::plotRGB(b, stretch = "lin")
dev.off()

################################
##############################
#####################

# created the netcdf and flipped it using the https://rpubs.com/boyerag/297592
library(sp)
library(ncdf4) # package for netcdf manipulation
library(raster) # package for raster manipulation
library(rgdal) # package for geospatial analysis
library(ggplot2) # package for plotting
nc_data <- nc_open("/Users/claregaffey/Documents/RClass/hcdc.mon.mean.nc")
#KF <- nc_open("/Users/claregaffey/Downloads/R2202aRBRZBGCcnut04a.NO3allk1.pop.h.05.nc") #karen Frey's nc
lon <- ncvar_get(nc_data, "x")
lat <- ncvar_get(nc_data, "y", verbose = F)
t <- ncvar_get(nc_data, "time_bnds")
#^ this also worked t <- ncvar_get(nc_data, "time")

ndvi.array <- ncvar_get(nc_data, "hcdc") # store the data in a 3-dimensional array
dim(ndvi.array)
ndvi.slice <- ndvi.array[, , 1]  # pulling out the first time slice
dim(ndvi.slice) # checking that this first slice has the dimensions we would expect
# we can go ahead and save this data in a raster. Note that we provide the coordinate reference system “CRS” in the standard well-known text format. For this data set, it is the common WGS84 system.
r <- raster(t(ndvi.slice), xmn=min(lon), xmx=max(lon), ymn=min(lat),
            ymx=max(lat),
            crs=CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs+ towgs84=0,0,0"))
#We will need to transpose and flip to orient the data correctly. The best way to figure this out is through trial and error, but remember that most netCDF files record spatial data from the bottom left corner.
r <- flip(r, direction='y') #
par(mar = c(0, 0, 0, 4))
plot(r)

## Trying to make the map nicer

library(maptools)
sp::degAxis(side = 1)
sp::degAxis(side = 2,las = 2)
# shift = c(x,y) direction
Narrow1 <- maptools::elide(arrow1, shift = c(extent(nc_data)[2],extent(nc_data)[3]))

# add north arrow to current NH plot
plot(Narrow1, add = TRUE,col = "black")

# Make north arrow type 2
arrow2 <- layout.north.arrow(type = 2)

# shift the coordinates
# shift = c(x,y) direction
Narrow2 <- maptools::elide(arrow2, shift = c(extent(NH)[1]-0.5,extent(NH)[3]))

# add north arrow to current plot
plot(Narrow2, add = TRUE, col = "blue")

NO3.array <- ncvar_get(KF, "NO3") # store the data in a 3-dimensional array
dim(NO3.array)


######### #unused snippets from overview.rmd
tunits <- ncatt_get(nc_data,"time","units")
#### Trying to tease out time in their units
tunits <- ncatt_get(nc_data, "time", "units")
tunits
nt <- dim(t)
t2 <- ncvar_get(nc_data, "time")
tail( as.POSIXct(t2,origin='1880-01-01 00:00') )
tail( as.POSIXct(t,origin='1880-01-01 00:00') )





hcdc.array <- ncvar_get(nc_data, "hcdc") # store the data in a 3-dimensional array
dim(hcdc.array)
hcdc.slice <- hcdc.array[, , 49]  # pulling out the first time slice
dim(hcdc.slice) # checking that this first slice has the dimensions we would expect
# we can go ahead and save this data in a raster. Note that we provide the coordinate reference system “CRS” in the standard well-known text format. For this data set, it is the common WGS84 system.
r <- raster(t(hcdc.slice), xmn=min(lon), xmx=max(lon), ymn=min(lat),
            ymx=max(lat),
            crs=CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs+ towgs84=0,0,0"))
#We will need to transpose and flip to orient the data correctly. The best way to figure this out is through trial and error, but remember that most netCDF files record spatial data from the bottom left corner.
r <- flip(r, direction='y') #
par(mar = c(0, 0, 0, 4))
plot(r)

#Writing out geotiff
writeRaster(r, "hcdc1979.tif", "GTiff", overwrite=TRUE)


##########################################
##########################################
##########################################
##########################################
# reproject and crop datasets.

###########################################

library(sp)
library(tidyverse)
library(sf)
library(ncdf4) # package for netcdf manipulation
library(raster)
library(rgdal) # package for geospatial analysis
library(ggspatial) #Requires ggplot2

#Steps:
# Match projection info
# Crop datasets to the shapefile

# cloud data
lcl <- "/Volumes/My Passport/RProject2021/lcdc.mon.mean.nc"
lcdc <- nc_open(lcl)
#check out the netcdf contents
lcdc
# create raster brick
var.nc1<-brick(lcl,varname="lcdc")
var.nc1

#Recreate the boundary sharefile
coords <- cbind("x" = c(-180, -152, -152, -180, -180),
                "y" = c(75, 75, 50, 50, 75))
pol <- st_polygon(x = list(coords)) %>% st_sfc %>% st_sf(ID = 1, crs = 4326)

# reproject polygon to match lcdc
pol <- st_transform(pol, st_crs = var.nc1)

# crop brick to shapefile extent
clmvar <- crop(x = var.nc1[[1]], y = pol) #remove the [[]] to do all data
plot(clmvar)

dim(var.nc1[[1]])
dbo3_clo <- dbo3
lay1_clo <- projectRaster(var.nc1[[1]], crs = crs(var.sictif)) #will only work if i plug in the index
crs(lay1_clo)
clodbo3varlay1 <- crop(x = lay1_clo, y = dbo3_clo)
# The projected MODIS chlorophyll and our region of interest
ggplot() +
  layer_spatial(lay1_clo, aes(fill = stat(band1))) +
  scale_fill_continuous(na.value = NA) +
  layer_spatial(dbo3_chl)
ggplot() +
  layer_spatial(clodbo3varlay1)


#///////////\\\\\\\\\\\/\/\/\/\
m <- 1 #which time slice do we want to view (can use this to create a LOOP later) 1-504
#subset extracts a single layer from the raster brick
tmp_slice_r<-subset(var.nc1,m)
dim(tmp_slice_r)
plot(tmp_slice_r)

#loop building to keep things spatial:
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

lcl_mon_df <- as.data.frame(cellStats(x = mystack, stat = "mean"))
head(lcl_mon_df)
names(lcl_mon_df) <- c("Year_Month", "LCC") #change the second one to an input object for reproducibility
dim(lcl_mon_df)
# There's proboably an easier way to create this in my loop








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

## RESAMPLE THAT WORKS
cloudresampled <- resample(x = clodbo3varlay1, y = chldbo3varlay1) # keep this example chl target the same for all resampling
cellStats(x = lay1_clo2, stat = "mean")













#####################
# will need to build a loop to go over each file in this folder to read in as brick and crop
#and apply land mask and
# resampling and reprojecting may or may not be necessary - but I think it will be so I can
# have all inputs align into the xgboost (probably will need to make into a data.frame or tibble)
# Chl example
chl <- "/Volumes/My Passport/RProject2021/MODIS_chl/A20031822003212.L3m_MO_CHL.x_chlor_a.nc"
chla <- nc_open(chl)

#### I'l MAKE A NEW SHAPEFOLE AND TRANSFER THS CRS FROM THIS DATASET DIRECTLY
coords <- cbind("x" = c(-180, -152, -152, -180, -180),
                "y" = c(75, 75, 50, 50, 75))
pol <- st_polygon(x = list(coords)) %>% st_sfc %>% st_sf(ID = 1, crs = crs(var.nchl))

#check out the netcdf contents
chla
# create raster brick
var.chl<-brick(chl,varname="chlor_a")
crs(var.chl)
var.chl
dim(var.chl)
# reproejct chla data and crop
dbo3_chl <- dbo3
#dbo3_chl <- st_transform(x = dbo3_chl, st_crs = st_crs(var.chl))
#dbo3_chl %>% st_transform("+proj=longlat +datum=WGS84 +no_defs")
var.chl2 <- var.chl
lay1_chl <- projectRaster(var.chl[[1]], crs = crs(var.sictif)) #will only work if i plug in the index

var.chl[[1]] %>% projectRaster(crs = crs(var.sictif))
dim(var.chl2)
crs(lay1_chl)
crs(var.chl2[[1]])
st_crs(dbo3_chl)
st_crs(dbo3)
st_crs(var.chl[[1]])
plot(var.chl)
plot(dbo3_chl, add = TRUE)
# crop brick to shapefile extent
chldbo3var <- crop(x = var.chl[[1]], y = dbo3_chl) #will only work with [[1]] specified
chldbo3varlay1 <- crop(x = lay1_chl, y = dbo3_chl)
chldbo3var<- mask(x = var.chl[[1]], mask = dbo3_chl)
par(mar = c(4, 4, 4, 2))
plot(chldbo3varlay1)
plot(var.chl)
ggplot() +
  layer_spatial(lay1_chl) + layer_spatial(dbo3_chl)#(lay1_chl)#, aes(fill = stat(band1))) +
#scale_fill_continuous(na.value = NA)

ggplot() +
  layer_spatial(var.chl[[1]], aes(fill = stat(band1))) +
  scale_fill_continuous(na.value = NA) + layer_spatial(dbo3_chl)

#^^^^^^^^^^^^^^^^^^^^^^^
# This code loads in chl netcdf, converts to a raster object, reprojects it to
# match the other files(SIC, DBO3 bounding box ROI), crops it to the DBO3 ROI,
# and visualizes the data.
## Clean version of chla:
chl <- "/Volumes/My Passport/RProject2021/MODIS_chl/A20031822003212.L3m_MO_CHL.x_chlor_a.nc"
chla <- nc_open(chl)
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





#it only seems to work if i reproject the rasters to north pole stereo, when i reproject the shapefile thery cannot be plotted in the samme map

##############################
#Recreate the boundary sharefile
coords <- cbind("x" = c(-180, -152, -152, -180, -180),
                "y" = c(75, 75, 50, 50, 75))
sicpol <- st_polygon(x = list(coords)) %>% st_sfc %>% st_sf(ID = 1, crs = "EPSG:3413")#4326)
# SIC example
si <- "/Volumes/My Passport/RProject2021/SeaIce_MonthlySB2/SB2_1978_12_month.rst" #the rst
si_tif <- "/Users/claregaffey/Documents/RClass/SB2_1979_1_month_b1.tif"
# create raster brick
var.sic <- brick(si)#varname="chlor_a")
var.sictif <- brick(si_tif)

crs(var.sic)
crs(var.sictif) <- "EPSG:3413"#"+proj=stere +lat_0=90 +lat_ts=70 +lon_0=-45 +k=1 +x_0=0 +y_0=0 +datum=WGS84 +units=m +no_defs"

dim(var.sictif)
plot(var.sic)
# reproject polygon to match lcdc
sicpol <- st_transform(x = sicpol, st_crs = var.sictif)
crs(sicpol)
projectRaster(var.sictif, crs="EPSG:3413")
#st_crs(var.sic) <- st_crs(3413)


#//////////

#crs(var.sic) <- "+proj=stere +lat_0=90 +lat_ts=70 +lon_0=-45 +k=1 +x_0=0 +y_0=0 +a=6378273 +b=6356889.449 +units=m +no_defs "
st_crs(sicpol)
# Use the polar drive pre=projected bounding boxes for DBO,

#@@@@@@ This is what works:

dbo3 <- "/Users/claregaffey/OneDrive - Clark University/R_Project/DBO3_shapefile/Dbo3.shp" %>% st_read()

library(ggspatial)
#> Loading required package: ggplot2
ggplot() +
  layer_spatial(var.sictif, aes(fill = stat(band1))) +
  scale_fill_continuous(na.value = NA) + layer_spatial(dbo3)
ggplot() +
  layer_spatial(dbo3)



# crop brick to shapefile extent
smvar <- crop(x = var.sictif, y = dbo3) # can try [[1]] \
plot(smvar)
plot(var.sictif)
plot(sicpol, add= TRUE)
st_crs(sicpol)
### Zoom in to cropped area to check it out
par(mar = c(0, 0, 0, 2))
plot(var.sic, axes = FALSE, box = FALSE, ext = extent(pol))
districts %>% st_geometry %>% plot(add = TRUE)
districts %>% st_centroid %>% st_coordinates %>%
  text(x = ., labels = row.names(.))
###############################@#@#@#@#@#@@#@@#!$#@$#@#@$#@$#@$@#$#@#$@$@#!$@!$#@
