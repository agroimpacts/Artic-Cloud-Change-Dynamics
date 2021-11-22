# Script to download the datasets for Arctic-Cloud-Change-Dynamics
library(stringr)
library(here) # set up working direcoty
here::here() # set working directory for images



#high cloud
url <-  "https://downloads.psl.noaa.gov/Datasets/NARR/Monthlies/monolevel/hcdc.mon.mean.nc"
x <- str_sub(url,-16,-1)
destfile <- here::here(paste("external/data/", x))
browseURL(url)

 ## MAKE THIS A LIST AND THE ABOVE A FUNCTION FOR DOWNLOADING IT
#medium cloud
"https://downloads.psl.noaa.gov/Datasets/NARR/Monthlies/monolevel/mcdc.mon.mean.nc"
#air temp
"https://downloads.psl.noaa.gov/Datasets/NARR/Monthlies/monolevel/air.sfc.mon.mean.nc"

#low cloud
"https://downloads.psl.noaa.gov/Datasets/NARR/Monthlies/monolevel/lcdc.mon.mean.nc"
#wind speed at 10 m
"https://downloads.psl.noaa.gov/Datasets/NARR/Derived/monolevel/wspd.10m.mon.ltm.nc"
#Pressure
"https://downloads.psl.noaa.gov/Datasets/NARR/Monthlies/monolevel/pres.sfc.mon.mean.nc"
#accumulated total evaporation
"https://downloads.psl.noaa.gov/Datasets/NARR/Monthlies/monolevel/evap.mon.mean.nc"
#geopotential height
"https://downloads.psl.noaa.gov/Datasets/NARR/Monthlies/monolevel/hgt.tropo.mon.mean.nc"
#relative humidity at 2 m
"https://downloads.psl.noaa.gov/Datasets/NARR/Monthlies/monolevel/rhum.2m.mon.mean.nc"


#chlorophyll
#sea ice concentration

