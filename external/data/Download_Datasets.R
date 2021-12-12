## Script to download the datasets for Arctic-Cloud-Change-Dynamics

# Install libraries

if (!("stringr" %in% installed.packages())) {
  install.packages("stringr")
}
if (!("here" %in% installed.packages())) {
  install.packages("here")
}
library(stringr)
library(here) # set up working directory
here::here() # set working directory for images

#####################################################################

## NARR Reanalysis Data Download

####################################################################

# To download one at a time (example):

#high cloud
url <-  "https://downloads.psl.noaa.gov/Datasets/NARR/Monthlies/monolevel/hcdc.mon.mean.nc"
x <- str_sub(url,-16,-1)
destfile <- here::here(paste("external/data/", x,  sep = ""))
browseURL(url)

# Or download all NARR variables at once:

urls <- list(
  #high cloud
  "https://downloads.psl.noaa.gov/Datasets/NARR/Monthlies/monolevel/hcdc.mon.mean.nc",
  #medium cloud
  "https://downloads.psl.noaa.gov/Datasets/NARR/Monthlies/monolevel/mcdc.mon.mean.nc",
  #air temp
  "https://downloads.psl.noaa.gov/Datasets/NARR/Monthlies/monolevel/air.sfc.mon.mean.nc",
  #low cloud
  "https://downloads.psl.noaa.gov/Datasets/NARR/Monthlies/monolevel/lcdc.mon.mean.nc",
  #wind speed at 10 m
  "https://downloads.psl.noaa.gov/Datasets/NARR/Monthlies/monolevel/wspd.10m.mon.mean.nc",
  #Pressure
  "https://downloads.psl.noaa.gov/Datasets/NARR/Monthlies/monolevel/pres.sfc.mon.mean.nc",
  #accumulated total evaporation
  "https://downloads.psl.noaa.gov/Datasets/NARR/Monthlies/monolevel/evap.mon.mean.nc",
  #geopotential height
  "https://downloads.psl.noaa.gov/Datasets/NARR/Monthlies/monolevel/hgt.tropo.mon.mean.nc",
  #relative humidity at 2 m
  "https://downloads.psl.noaa.gov/Datasets/NARR/Monthlies/monolevel/rhum.2m.mon.mean.nc"
)

for (url in urls) {
  download.file(url,
                destfile = here::here(paste("external/data/", basename(url))),
                method="curl", extra="-k")
  #if that doesn't download, use browseURL instead by uncommenting this line:
  #browseURL(url)
}

####################################################################

## MODIS Chlorophyll Data Download

####################################################################

# Need to scrape the ocean color website to get chlorophyll data
if (!("rvest" %in% installed.packages())) {
  install.packages("rvest")
}
if (!("dplyr" %in% installed.packages())) {
  install.packages("dplyr")
}
library(rvest)
library(dplyr)
#####
#Step 1

# The year of data download will have to be changed manually
# because we cannot insert an object
# Even though I tried with:
# m <- 2002
# iter <- paste("//a[contains(@href, '", m, "')]")
# and substituting xml2::xml_find_all

# So Change the year in the URL and the xml2::xml_find_all on each run

URL <- "https://oceandata.sci.gsfc.nasa.gov/directaccess/MODIS-Aqua/L3SMI/2002/"
web <- read_html(URL)
rank <- web %>%
  rvest::html_nodes('body') %>%
  xml2::xml_find_all("//a[contains(@href, '2002')]") %>% #<Change the year here
  str_sub(.,-64,-25)
rank <- rank[-1] # delete the first element which does not point to data
rank <- rank[-2] #number 153 went to a missing page, remove any that do this.
head(rank)
root <- "https://oceandata.sci.gsfc.nasa.gov"
stem <- "/ob/getfile/"

#Step 2
# Download chl_a_9km.nc from each day of that year
# Note that you might need to first log in to EarthData to run this
# uncomment the below to go log in:
#browseURL("https://oceandata.sci.gsfc.nasa.gov/directaccess/MODIS-Aqua/L3SMI/2002/001/")

for (url in rank) {
  url <- paste(root, url, sep = "")
  #go to deeper url get file name
  web2 <- read_html(url)
  rank2 <- web2 %>% rvest::html_nodes('body') %>%
    xml2::xml_find_all("//a[contains(@href, 'CHL_chlor_a_9km')]") %>%
    str_sub(.,-45,-5)
  #create new url name for the 9km chla data netcdf
  newurl <- paste(root, stem, rank2, sep = "")
  #download file
  download.file(newurl,
                destfile = here::here(paste("external/data/", basename(newurl))))
  #if that doesn't download, use browseURL instead by uncommenting this line:
  #browseURL(newurl)
}

####################################################################

## Sea ice concentration

####################################################################

# Monthly RST are saved here
browseURL("https://clarkuedu-my.sharepoint.com/:f:/g/personal/cgaffey_clarku_edu/EgVcDbETKIpNs1jdFO9IDX0Bq5JM51hTJ_I06kjTO7aINQ?e=0Ajnmn")



# If starting from scratch:
# We could download the data using HTTPS and adjusting the above
# to accomodate https://n5eil01u.ecs.nsidc.org/PM/NSIDC-0051.001/ as the url
# and the file names. However, this method downloads the global Arctic region
# at daily time intervals (monthly is not an option).

# Therefore, the easiest way to do this is through the website GUI
# Following the link to get started:
# https://nsidc.org/data/nsidc-0051
#browesURL("https://nsidc.org/data/nsidc-0051")


####################################################################

## DBO3 shapefile

####################################################################

browseURL("https://clarkuedu-my.sharepoint.com/:f:/g/personal/cgaffey_clarku_edu/EsUkVh4Sb3JKl-dLJdzVJK8BHRIBAlmUA5cwEmQMhbWGbA?e=AdD3sH")
