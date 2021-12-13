library(data.table)
library(dplyr)
library(ggplot2)
library(date)
library(here)
here::here()
# set working directory
setwd(here::here("external/data/"))
chl <- read.csv("var.chla.csv")
sic <- read.csv("var.sic.csv")

files <- list.files(pattern = ".csv") # list of all the variable csvs
files <- files[!grepl("var.chla.csv",unlist(files))] # remove chla
files <- files[!grepl("var.sic.csv",unlist(files))] # remove sic
temp <- lapply(files, read_csv, sep=",")
NARRdata <- bind_cols(temp) # combine NARR datesets

# define dates
chl <- chl %>% mutate(Year = substr(Year.month.day, 1, 4)) %>%
  mutate(JulianDay = substr(Year.month.day, 6, 8))

jul <- as.numeric(chl$JulianDay)
ek <- list()
for (i in 1:211) { #Convert julian day to month
  print(jul[i])
  k <- date.mdy(jul[i], weekday = FALSE)
  unlist(k)
  print(k)
  ek <- append(ek, k$month)
}
ek <- unlist(ek)
chl <- chl %>% mutate(Month = ek) # add back into the dataframe
chl <- chl %>% # some years have two Februaries, so adjust to make one January
  mutate(modified_months = ifelse(as.numeric(JulianDay) < 032, 1, Month)) %>%
  mutate(Year_month = paste0(Year, "_", modified_months))

# Create year and month columns for the NARR dataset
NARRdata <- NARRdata %>% mutate(Year = as.numeric(substr(Year.month.day...3, 1, 4))) %>%
  mutate(Month = as.numeric(substr(Year.month.day...3, 6, 7))) %>%
  mutate(Year_month = paste0(Year, "_", Month))

# Create year and month columns for sea ice concentration
sic <- sic %>% mutate(Year = as.numeric(substr(Year.month.day, 4, 7))) %>%
  mutate(Month = as.numeric(gsub("_", "", substr(Year.month.day, 9, 10)))) %>%
  mutate(Year_month = paste0(Year, "_", Month))

# Merge all datasets
Alldata <- left_join(NARRdata, sic, by = "Year_month")
Alldata <- left_join(Alldata, chl, by = "Year_month")

# reduce our data table to the columns we want
columns <- c('Year.x', 'Month.x', 'Year_month', 'airT', 'evap', 'rhum', 'wspd', 'hgt',
             'chla', 'var.sic', 'LowCloud')
New <- Alldata[, columns, with=FALSE]

# write it out to a csv
fwrite(New, "ArcticDynamicsVariables.csv")

