library(data.table)
library(dplyr)
library(ggplot2)

#Change the directory
setwd("C:/Users/aandi/Desktop/Fall_2021/GEOG_346/Final_Project/Datasets/csvs/csvs_edited/")

#Set Up Months
#months <- seq.Date(from = as.Date("1979/1/1"), length.out = 514, by = "month")
#Change to your directory
#write.csv(months, file = "C:/Users/aandi/Desktop/Fall_2021/GEOG_346/Final_Project/Datasets/csvs/csvs_edited/dates.csv")

files <- list.files(pattern = ".csv")
temp <- lapply(files, fread, sep=",")
data <- bind_cols(temp)
narr_data <- data %>% select("Time" = x, "Air_temperature" = airT, "Chlorophyll" = chla, "Evaporation" = eva, "Geopotential_Height" = hgt, "Low_Cloud" = nc1, "Relative_Humidty" = rhum, "Sea_Ice" = var.sic, "Wind_Speed" = wspd)
data_df <- as_tibble(narr_data) %>% mutate(Month = format(narr_data$Time, "%m"),Year = format(narr_data$Time, "%Y"))


write.csv(dat, file = "C:/Users/aandi/Desktop/Fall_2021/GEOG_346/Final_Project/Datasets/csvs/csvs_edited/dates.csv")

#Example of Running the Plot for Month 01
dat <- data_df[data_df$Month == "01", ]
plot(x = dat$Time, y = dat$Air_temperature)


#Example of Plotting Annual Trends
dat2 <- data_df[data_df$Year == "1979", ]
plot(x = dat2$Time, y = dat2$Evaporation)




