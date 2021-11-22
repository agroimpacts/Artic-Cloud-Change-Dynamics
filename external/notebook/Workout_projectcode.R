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


