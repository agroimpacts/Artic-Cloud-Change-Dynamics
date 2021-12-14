library(ncdf4)
library(chron)
#library(raster)
library(lattice)
library(RColorBrewer)

#Setting up the path to data

ppath <- "C:/Users/aandi/Desktop/Fall_2021/GEOG_399/Datasets/" # point to dataset folder, USE NOT HARD PATH
ncpath <- ppath

#High Cloud Area Fraction
ncname1 <- "hcdc.mon.mean"
ncfname1 <- paste(ncpath, ncname1, ".nc", sep="")
dname1 <- "hcdc"

# open a netCDF file
ncin <- nc_open(ncfname1)
ncin

lon <- ncvar_get(ncin, "x")
lat <- ncvar_get(ncin, "y")
nlon <- dim(lat)
nlat <- dim(lon)
time <- ncvar_get(ncin,"time")
time
tunits <- ncatt_get(ncin,"time","units")
nt <- dim(time)
nt
##############################################################################
##############################################################################
#raster brick to data frame
var.nc <- brick(ncfname1, varname=dname1, layer="time") #reopen netcdf file as Raster brick for TIME variable
var.nc

#TIME: remove H M S from time format
TIME <- as.POSIXct(substr(var.nc@data@names, start=2, stop=20), format="%Y.%m.%d")
df <- data.frame(INDEX = 1:length(TIME), TIME=TIME)
head(TIME)
tail(TIME)
head(df)


test1 <- var.nc[[1:5]]
plot(var.nc[[1:4]])

library(spatialEco)
rk <- raster.kendall(test1, p.values = TRUE)

test2 <- stack(var.nc)

test2 <- stack(var.nc)
test4 <- var.nc[[1:5]]
test30 <- stack(test4)
rk <- raster.kendall(test30, p.value = TRUE)

raster.kendall()


## library(ggplot2)
# library(tidyverse)
#
# mapCDFtemp <- function(lat,lon,tas) #model and perc should be a string
#
# {
#
#   titletext <- "title"
#
#   expand.grid(lon, lat) %>%
#
#     rename(lon = Var1, lat = Var2) %>%
#
#      mutate(lon = ifelse(lon > 180, -(360 - lon), lon),
#
#            tas = as.vector(tas)) %>%
#
#      ggplot() +
#
#     geom_point(aes(x = lon, y = lat, color = tas),
#
#                size = 0.8) +
#
#     borders("world", colour="black", fill=NA) +
#
#     scale_color_viridis(na.value="white",name = "Temperature") +
#
#     theme(legend.direction="vertical", legend.position="right", legend.key.width=unit(0.4,"cm"), legend.key.heigh=unit(2,"cm")) +
#
#     coord_quickmap() +
#
#     ggtitle(titletext)
#
# }
#

#
# m <- 1 #which time slice do we want to view (can use this to create a LOOP later) 1-504
# #subset extracts a single layer from the raster brick
# tmp_slice_r<-subset(var.nc1,m)
# dim(tmp_slice_r)
# #plot(tmp_slice_r)
#
# #create color palettes:
# temp.palette <- rev(colorRampPalette(c("darkred","red","orange",
#                                        "lightyellow","white","azure",
#                                        "cyan","blue","darkblue"))(100))
#
# TIME <- as.POSIXct(substr(var.nc1@data@names, start=2, stop=20), format="%Y.%m.%d")
#
# #Create a title for plot: take TIME[m] string and how many characters from the left to keep in title? 7 or 10
# ttl <- paste(dname1,"_", substr(TIME[m], 1, 7),sep="")
#
# #test it
# spplot(tmp_slice_r,  main = ttl, col.regions=temp.palette)
#
# tmp_slice_dm <- data.matrix(var.nc1)
#



