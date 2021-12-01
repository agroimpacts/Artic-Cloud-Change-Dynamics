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


hcdc_array <- ncvar_get(ncin, dname1)
dlname <- ncatt_get(ncin, dname1,"long_name")
dunits <- ncatt_get(ncin, dname1,"units")
fillvalue <- ncatt_get(ncin, dname1,"_FillValue")
dim(hcdc_array)

# get global attributes
title <- ncatt_get(ncin,0,"title")
institution <- ncatt_get(ncin,0,"institution")
datasource <- ncatt_get(ncin,0,"source")
references <- ncatt_get(ncin,0,"references")
history <- ncatt_get(ncin,0,"history")
Conventions <- ncatt_get(ncin,0,"Conventions")


# replace netCDF fill values with NA's
hcdc_array[hcdc_array==fillvalue$value] <- NA
length(na.omit(as.vector(hcdc_array[,,1])))


# get a single slice or layer (January)
m <- 1
hc_slice <- hcdc_array[,,m]

image(lon,lat,hc_slice, col=rev(brewer.pal(10,"RdBu")))

# levelplot of the slice
grid <- expand.grid(lon=lon, lat=lat)
cutpts <- c(-50,-40,-30,-20,-10,0,10,20,30,40,50)
levelplot(hc_slice ~ lon * lat, data=grid, at=cutpts, cuts=11, pretty=T,
          col.regions=(rev(brewer.pal(10,"RdBu"))))

# create dataframe -- reshape data
# matrix (nlon*nlat rows by 2 cols) of lons and lats
lonlat <- as.matrix(expand.grid(lon,lat))
dim(lonlat)

# vector of `HC` values
hc_vec <- as.vector(hc_slice)
length(hc_vec)

# create dataframe and add names
hc_df01 <- data.frame(cbind(lonlat,hc_vec))
names(hc_df01) <- c("lon","lat",paste(dname1,as.character(m), sep="_"))

head(na.omit(hc_df01), 10)
tail(na.omit(hc_df01), 10)

# reshape the array into vector
hc_vec_long <- as.vector(hcdc_array)
length(hc_vec_long)

# reshape the vector into a matrix
hc_mat <- matrix(hc_vec_long, nrow=nlon*nlat, ncol=nt)
dim(hc_mat)
hc_mat[1:12]

# create a dataframe
lonlat <- as.matrix(expand.grid(lon,lat))
hc_df02 <- data.frame(cbind(lonlat,hc_mat))
names(hc_df02) <- c("lon","lat","tmpJan","tmpFeb","tmpMar","tmpApr","tmpMay","tmpJun",
                     "tmpJul","tmpAug","tmpSep","tmpOct","tmpNov","tmpDec")
# options(width=96)
head(na.omit(hc_df02[3:14], 20))


# get the annual mean and min and max HC
hc_df02$maxhc <- apply(hc_df02[3:14],1,max) # max HC
hc_df02$minhc <- apply(hc_df02[3:14],1,min) # min HC
hc_df02$meanhc <- apply(hc_df02[3:14],1,mean) # annual (i.e. row) means
head(na.omit(hc_df02[516:518]))
#
# tmp.slice <- tmp.array[,,1]
# tas <- tmp.array[,,1]
#
# tmp_array[tmp_array==fillvalue$value] <- NA
#
#
# #raster brick to data frame
# var.nc <- brick(ncfname1, varname=dname1, layer="time") #reopen netcdf file as Raster brick for TIME variable
# var.nc
#
# #TIME: remove H M S from time format
# TIME <- as.POSIXct(substr(var.nc@data@names, start=2, stop=20), format="%Y.%m.%d")
# df <- data.frame(INDEX = 1:length(TIME), TIME=TIME)
# head(TIME)
# tail(TIME)
# head(df)
#
#
# library(ggplot2)
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



