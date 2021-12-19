library(ncdf4)
library(chron)
#library(raster)
library(lattice)
library(RColorBrewer)

# set path and filename

ppath <- "C:/Users/aandi/Desktop/Fall_2021/GEOG_399/Datasets/" # point to dataset folder, USE NOT HARD PATH
ncpath <- ppath

#High Cloud Area Fraction
ncname1 <- "hcdc.mon.mean"
ncfname1 <- paste(ncpath, ncname1, ".nc", sep="")
dname1 <- "hcdc"

# open a netCDF file
ncin <- nc_open(ncfname1)
print(ncin)

# get x's and y's
x <- ncvar_get(ncin,"x")
xlname <- ncatt_get(ncin, "x", "long_name")
xunits <- ncatt_get(ncin, "x", "units")
nx <- dim(x)
head(x)

y <- ncvar_get(ncin,"y")
ylname <- ncatt_get(ncin, "y", "long_name")
yunits <- ncatt_get(ncin, "y", "units")
ny <- dim(y)
head(y)

print(c(nx, ny))

# get time
time <- ncvar_get(ncin, "time")
time

tunits <- ncatt_get(ncin, "time", "units")
nt <- dim(time)
nt


# get high cloud fraction
hcdc_array <- ncvar_get(ncin, dname1)
dlname <- ncatt_get(ncin, dname1, "long_name")
dunits <- ncatt_get(ncin, dname1, "units")
fillvalue <- ncatt_get(ncin, dname1, "_FillValue")
dim(hcdc_array)

#Slice of first 12 months
hcdc_slice12 <- hcdc_array[,,1:12] #Changing the 1:2, changes the number of time bands we are using
dim(hcdc_slice12)

lon <- ncvar_get(ncin, "lon")
dim(lon)
lat <- ncvar_get(ncin, "lat")
dim(lat)


# replace netCDF fill values with NA's
hcdc_array[hcdc_array==fillvalue$value] <- NA
length(na.omit(as.vector(hcdc_array[,,1])))


# get a single slice or layer (January)
m <- 1
hc_slice <- hcdc_array[,,m]

# create dataframe -- reshape data
# matrix (nlon*nlat rows by 2 cols) of lons and lats
lonlat <- as.matrix(expand.grid(lon,lat))
dim(lonlat)

# vector of `HC` values
hc_vec <- as.vector(hc_slice)
length(hc_vec)

