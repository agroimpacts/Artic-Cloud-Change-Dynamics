library(data.table)
library(dplyr)
library(ggplot2)

setswd <- here::here("external/data/narr_variables")

#Set Up Months
months <- seq.Date(from = as.Date("1979/1/1"), length.out = 514, by = "month")
write.csv(months, file = tempdir())

files <- list.files(pattern = ".csv")
temp <- lapply(files, fread, sep=",")
data <- bind_cols(temp)
narr_data <- data %>% select(
  "Time" = x,
  "Air_temperature" = airT,
  "Chlorophyll" = chla,
  "Evaporation" = eva,
  "Geopotential_Height" = hgt,
  "Low_Cloud" = nc1,
  "Relative_Humidty" = rhum,
  "Sea_Ice" = var.sic,
  "Wind_Speed" = wspd)

data_df <- as_tibble(narr_data) %>%
  mutate(Month = format(narr_data$Time, "%m"),Year = format(narr_data$Time, "%Y"))
write.csv(dat, file = tempdir())

#Example of Running the Plot for Month 01
dat <- data_df[data_df$Month == "01", ]
plot(x = dat$Time, y = dat$Air_temperature)

#Example of Plotting Annual Trends
dat2 <- data_df[data_df$Year == "1979", ]
plot(x = dat2$Time, y = dat2$Evaporation)

#Creating Line Plots

data_df  %>%
  ggplot() + geom_line(mapping = aes(x = Time, y = Evaporation, color = Month)) +
  scale_color_manual(values = c("red", "blue", "green", "black", "pink", "purple", "brown", "grey", "yellow", "orange", "cyan", "darkred")) +
  xlab("Year") + ylab("Evaporation Rates") +
  ggtitle("Evaporation Rates in DBO 3 (1979-2021)")

data_df  %>%
  ggplot() + geom_line(mapping = aes(x = Time, y = Geopotential_Height, color = Month)) +
  scale_color_manual(values = c("red", "blue", "green", "black", "pink", "purple", "brown", "grey", "yellow", "orange", "cyan", "darkred")) +
  xlab("Year") + ylab("Geopotential Height Rates") +
  ggtitle("Geopotential_Height Rates per Month in DBO 3 (1979-2021)")

data_df  %>%
  ggplot() + geom_line(mapping = aes(x = Time, y = Wind_Speed, color = Month)) +
  scale_color_manual(values = c("red", "blue", "green", "black", "pink", "purple", "brown", "grey", "yellow", "orange", "cyan", "darkred")) +
  xlab("Year") + ylab("Wind_Speed") +
  ggtitle("Wind_Speed per Month in DBO 3 (1979-2021)")

data_df  %>%
  ggplot() + geom_line(mapping = aes(x = Sea_Ice, y = Low_Cloud, color = Month)) +
  scale_color_manual(values = c("red", "blue", "green", "black", "pink", "purple", "brown", "grey", "yellow", "orange", "cyan", "darkred")) +
  xlab("Year") + ylab("Sea Ice Vs Low Cloud") +
  ggtitle("DBO 3 (1979-2021)")

#Plotting Correlation between Sea Ice and Cloud Cover for Month of May
dat <- data_df[data_df$Month == "05", ]
plot(x = dat$Sea_Ice, y = dat$Low_Cloud)


#Monthly Correlation Plot
data_df  %>%
  ggplot() + geom_point(mapping = aes(x = Sea_Ice, y = Low_Cloud, color = Month)) +
  scale_color_manual(values = c("red", "blue", "green", "black", "pink", "purple", "brown", "grey", "yellow", "orange", "cyan", "darkred")) +
  xlab("Sea Ice ") + ylab("Low Cloud") +
  ggtitle("Sea Ice VS Cloud DBO 3 (1979-2021)")


#Calculating Mann Kendall value for month of May
SILC_mk_Value <- cor(x = dat$Sea_Ice, y = dat$Low_Cloud, use = "everything",
    method = c("pearson", "kendall", "spearman"))


