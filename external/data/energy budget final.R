#Load package
library(ncdf4)
library(here)

#Download and create path to data- netCDF file
destfile <- here::here("external/data/data.nc")
url <- "https://iridl.ldeo.columbia.edu/SOURCES/.NASA/.ASDC-DAAC/.CERES/.EBAF-TOA/.Ed2p8/datasetdatafiles.html"

#load NASA CERES datasets
NASA_data <- nc_open(here("external/data/data.nc"))

#extract variable from dataset
Solar_Insolation <- ncvar_get(NASA_data, "solar_mon")
OutgoingLongwave <- ncvar_get(NASA_data, "toa_lw_all_mon")
OutgoingShortwave <- ncvar_get(NASA_data, "toa_sw_all_mon")
NetEnergy <- ncvar_get(NASA_data, "toa_net_all_mon")
Solar_mon <- ncvar_get(NASA_data, "solar_mon")

#Type in console dim(Solar_mon) which gives the 3 dimensions in the data set
# longitude, latitude, and time

#Type in console Solar_mon[long,lat,time component]
#In console, it will give the amount of insolation reaching the top of the
#atmosphere
#example Solar_mon[285,90,91] = 427.9 W/m^2

#Solar_mon variable has 360 longitude grid boxes and 180 latitude grid boxes
#spanning the surface of the earth
#Each grid is assigned a data value from Solar_mon which corresponds to a
#specific latitude and longitude values measured in degrees

#positive longitudes represent degrees east and negative longitudes represent degrees west.
#positive latitudes represent degrees north and negative latitudes represent degrees south.
#do not enter negative values for lat/long

#time component: from March 2000 to May 2015
# the number 1 correponds to time grid box 1 at the starting point of the
#dataset at March 2000 and goes up to 183 which is the end point of the time
#component of the data set in May 2015.

#equation: Net Energy = Solar_Insolation - OutgoingLongwave - OutgoingShortwave

#Type in console NetEnergy[long,lat,time component] to get the energy budget for
#different locations on Earth

#With our boundaries for shape file, (north = 75, south = 50, west = -180,
#east = -152), we can determine NetEnergy for a specific location
#within the boundary

#For example at 180 longitude and 60 latitude on June 13th (160) the net energy
#was -94.41 W/m^2
#type in console NetEnergy[180,60,160]

































