library(ncdf4) # package for netcdf manipulation
library(rgdal) # package for geospatial analysis
library(tidyverse) # to manipulate for plotting


#Setting up the path to data

ppath <- "C:/Users/aandi/Desktop/Fall_2021/GEOG_399/Datasets/" # point to dataset folder
ncpath <- ppath

#High Cloud Area Fraction
ncname1 <- "hcdc.mon.mean"
ncfname1 <- paste(ncpath, ncname1, ".nc", sep="")
dname1 <- "hcdc"

# open a netCDF file
ncin <- nc_open(ncfname1)
ncin

#Using a Raster Brick
#grab time slice from raster brick instead of array:
var.nc1<-brick(ncfname1,varname=dname1)
var.nc1
#plot(var.nc1[[1:12]]) #plot first 12 maps
pat <- seq(as.Date("1979/1/1"), by = "month", length.out = 504)


m <- 1 #which time slice do we want to view (can use this to create a LOOP later) 1-504
#subset extracts a single layer from the raster brick
tmp_slice_r<-subset(var.nc1,m)
dim(tmp_slice_r)
#plot(tmp_slice_r)

#create color palettes:
temp.palette <- rev(colorRampPalette(c("darkred","red","orange",
                                       "lightyellow","white","azure",
                                       "cyan","blue","darkblue"))(100))

TIME <- as.POSIXct(substr(var.nc1@data@names, start=2, stop=20), format="%Y.%m.%d")

#Create a title for plot: take TIME[m] string and how many characters from the left to keep in title? 7 or 10
ttl <- paste(dname1,"_", substr(TIME[m], 1, 7),sep="")

#test it
spplot(tmp_slice_r,  main = ttl, col.regions=temp.palette)

tmp_slice_dm <- data.matrix(var.nc1)

test1 <- ts(data = var.nc1, start = 1, end = 504, frequency = 1, names = pat)


